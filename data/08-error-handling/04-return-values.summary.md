## Checking Return Values

**Always check return values of commands and function calls with informative error messages. While `set -e` helps, explicit checking provides better control over error handling and messaging.**

**Rationale:**
- **Better Error Messages**: Explicit checks allow contextual error messages
- **Controlled Recovery**: Some failures need cleanup or fallback logic, not immediate exit
- **`set -e` Limitations**: Doesn't catch pipeline failures (except last command), command substitution in assignments, or commands in conditionals
- **Partial Failure Handling**: Some operations continue after non-critical failures

**When `set -e` is insufficient:**

```bash
# set -e doesn't catch these:

# 1. Non-final pipeline commands
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails!

# 2. Commands in conditionals
if command_that_fails; then
  echo "This runs even though command failed"
fi

# 3. Command substitution in assignments
output=$(failing_command)  # Doesn't exit!
```

**Basic checking patterns:**

**Pattern 1: Explicit if check (most informative)**

```bash
#  Best for critical operations needing context
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move $source_file to $dest_dir"
  error "Check permissions and disk space"
  exit 1
fi
```

**Pattern 2: || with die (concise)**

```bash
#  Good for simple cases
mv "$source_file" "$dest_dir/" || die 1 "Failed to move $source_file"
cp "$config" "$backup" || die 1 "Failed to backup $config to $backup"
```

**Pattern 3: || with command group (for cleanup)**

```bash
#  Good when failure requires cleanup
mv "$temp_file" "$final_location" || {
  error "Failed to move $temp_file to $final_location"
  rm -f "$temp_file"
  exit 1
}

process_file "$input" || {
  error "Processing failed: $input"
  restore_backup
  cleanup_temp_files
  return 1
}
```

**Pattern 4: Capture and check return code**

```bash
#  When you need the return code value
local -i exit_code
command_that_might_fail
exit_code=$?

if ((exit_code != 0)); then
  error "Command failed with exit code $exit_code"
  return "$exit_code"
fi

#  Different actions for different exit codes
wget "$url"
case $? in
  0) success "Download complete" ;;
  1) die 1 "Generic error" ;;
  2) die 2 "Parse error" ;;
  3) die 3 "File I/O error" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error code: $?" ;;
esac
```

**Pattern 5: Function return value checking**

```bash
# Define function with meaningful return codes
validate_file() {
  local -- file="$1"

  [[ -f "$file" ]] || return 2  # Not found
  [[ -r "$file" ]] || return 5  # Permission denied
  [[ -s "$file" ]] || return 22  # Invalid (empty)

  return 0  # Success
}

# Check function return value
if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config file not found: $config_file" ;;
    5)  die 5 "Cannot read config file: $config_file" ;;
    22) die 22 "Config file is empty: $config_file" ;;
    *)  die 1 "Config validation failed: $config_file" ;;
  esac
fi
```

**Edge case: Pipelines**

```bash
# Problem: set -e only checks last command in pipeline
cat missing_file | grep pattern  # Continues even if cat fails!

#  Solution 1: Use PIPEFAIL (from set -euo pipefail)
set -o pipefail  # Now entire pipeline fails if any command fails
cat missing_file | grep pattern  # Exits if cat fails

#  Solution 2: Check PIPESTATUS array
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then
  die 1 "cat failed"
elif ((PIPESTATUS[1] != 0)); then
  info "No matches found (grep returned non-zero)"
elif ((PIPESTATUS[2] != 0)); then
  die 1 "sort failed"
fi

#  Solution 3: Avoid pipeline, use process substitution
grep pattern < <(cat file1)
```

**Edge case: Command substitution**

```bash
# Problem: Command substitution failure not caught
declare -- output
output=$(failing_command)  # Doesn't exit even with set -e!

#  Solution 1: Check after assignment
output=$(command_that_might_fail) || die 1 "Command failed"

#  Solution 2: Explicit check in separate step
declare -- result
if ! result=$(complex_command arg1 arg2); then
  die 1 "complex_command failed"
fi

#  Solution 3: Use set -e with inherit_errexit (Bash 4.4+)
shopt -s inherit_errexit  # Command substitution inherits set -e
output=$(failing_command)  # NOW exits with set -e
```

**Edge case: Conditional contexts**

```bash
# Commands in if/while/until don't trigger set -e

# Problem: This doesn't exit even with set -e
if some_command; then
  echo "Command succeeded"
else
  echo "Command failed but script continues"
fi

#  Solution: Explicit check after conditional
if some_command; then
  process_result
else
  die 1 "some_command failed"
fi
```

**Complete example with comprehensive error checking:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Messaging functions
error() {
  >&2 echo "[$SCRIPT_NAME] ERROR: $*"
}

die() {
  local -i exit_code=$1
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

info() {
  echo "[$SCRIPT_NAME] $*"
}

# Validate prerequisites
check_prerequisites() {
  local -- cmd
  local -a required_commands=('tar' 'gzip' 'sha256sum')

  info 'Checking prerequisites...'

  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      die 1 "Required command not found: $cmd"
    fi
  done

  info 'Prerequisites check passed'
}

# Create backup with error checking
create_backup() {
  local -- source_dir="$1"
  local -- backup_file="$2"
  local -- temp_file
  local -i exit_code

  info "Creating backup: $source_dir -> $backup_file"

  # Check source exists
  if [[ ! -d "$source_dir" ]]; then
    error "Source directory not found: $source_dir"
    return 2
  fi

  # Check destination writable
  if [[ ! -w "${backup_file%/*}" ]]; then
    error "Cannot write to directory: ${backup_file%/*}"
    return 5
  fi

  # Create backup with error handling
  temp_file="${backup_file}.tmp"

  # Create tar archive
  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error "Failed to create tar archive"
    rm -f "$temp_file"
    return 1
  fi

  # Verify archive
  if ! tar -tzf "$temp_file" >/dev/null; then
    error "Backup verification failed"
    rm -f "$temp_file"
    return 1
  fi

  # Move to final location
  if ! mv "$temp_file" "$backup_file"; then
    error "Failed to move backup to final location"
    rm -f "$temp_file"
    return 1
  fi

  # Create checksum
  if ! sha256sum "$backup_file" > "${backup_file}.sha256"; then
    error "Failed to create checksum"
    # Non-fatal - backup is still valid
    return 0
  fi

  info "Backup created successfully: $backup_file"
  return 0
}

# Process multiple files with return value checking
process_files() {
  local -a files=("$@")
  local -- file
  local -i success_count=0
  local -i fail_count=0

  for file in "${files[@]}"; do
    if create_backup "$file" "/backup/${file##*/}.tar.gz"; then
      ((success_count+=1))
      info "Success: $file"
    else
      ((fail_count+=1))
      error "Failed: $file (return code: $?)"
    fi
  done

  info "Results: $success_count successful, $fail_count failed"

  # Return non-zero if any failures
  ((fail_count == 0))
}

main() {
  check_prerequisites

  local -a source_dirs=('/etc' '/var/log')

  if ! process_files "${source_dirs[@]}"; then
    die 1 "Some backups failed"
  fi

  info "All backups completed successfully"
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - ignoring return values
mv "$file" "$dest"
#  Correct
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"

#  Wrong - checking $? too late
command1
command2
if (($? != 0)); then  # Checks command2, not command1!
#  Correct - check immediately
command1
if (($? != 0)); then
  die 1 "command1 failed"
fi

#  Wrong - generic error message
mv "$file" "$dest" || die 1 "Move failed"
#  Correct - specific error with context
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"

#  Wrong - not checking command substitution
checksum=$(sha256sum "$file")
#  Correct
checksum=$(sha256sum "$file") || die 1 "Failed to compute checksum for $file"

#  Wrong - not cleaning up after failure
cp "$source" "$dest" || exit 1
#  Correct
cp "$source" "$dest" || {
  rm -f "$dest"
  die 1 "Failed to copy $source to $dest"
}

#  Wrong - assuming set -e catches everything
set -e
output=$(failing_command)  # Doesn't exit!
cat missing_file | grep pattern  # Doesn't exit if cat fails!
#  Correct
set -euo pipefail
shopt -s inherit_errexit
output=$(failing_command) || die 1 "Command failed"
cat file | grep pattern  # Now exits if cat fails (pipefail)
```

**Summary:**
- Always check return values of critical operations
- Use `set -euo pipefail` as baseline plus explicit checks for control
- Provide context in error messages (what failed, with what inputs)
- Check command substitution: `output=$(cmd) || die 1 "cmd failed"`
- Use PIPEFAIL to catch pipeline failures
- Handle different exit codes appropriately (0=success, 1=general, 2=usage)
- Clean up on failure: `|| { cleanup; exit 1; }`
- Test error paths to ensure failures are caught

**Key principle:** Defensive programming assumes operations can fail. Check return values, provide informative errors, handle failures gracefully. Extra error checking prevents hours debugging mysterious failures.
