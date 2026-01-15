## Checking Return Values

**Always check return values of commands and function calls, providing informative error messages with context about what failed. While `set -e` helps, explicit checking gives better control over error handling and messaging.**

**Rationale:**
- Explicit checks enable contextual error messages and controlled recovery/cleanup
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution in assignments
- Informative errors aid debugging and user experience; some failures are non-critical

**When `set -e` is not enough:**
```bash
# set -e doesn't catch these:
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails
if command_that_fails; then echo 'Runs even though command failed'; fi
output=$(failing_command)  # Doesn't exit - output empty, script continues
```

**Basic return value checking patterns:**

**Pattern 1: Explicit if check (most informative)**
```bash
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move ${source_file@Q} to ${dest_dir@Q}"
  exit 1
fi
```

**Pattern 2: || with die (concise)**
```bash
mv "$source_file" "$dest_dir/" || die 1 "Failed to move ${source_file@Q}"
```

**Pattern 3: || with command group (for cleanup)**
```bash
mv "$temp_file" "$final_location" || {
  error "Failed to move ${temp_file@Q} to ${final_location@Q}"
  rm -f "$temp_file"
  exit 1
}
```

**Pattern 4: Capture and check return code**
```bash
wget "$url"
case $? in
  0) success "Download complete" ;;
  1) die 1 "Generic error" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error: $?" ;;
esac
```

**Pattern 5: Function return value checking**
```bash
validate_file() {
  local -- file=$1
  [[ -f "$file" ]] || return 2  # Not found
  [[ -r "$file" ]] || return 5  # Permission denied
  [[ -s "$file" ]] || return 22 # Invalid (empty)
  return 0
}

if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config file not found ${config_file@Q}" ;;
    5)  die 5 "Cannot read config file ${config_file@Q}" ;;
    22) die 22 "Config file is empty ${config_file@Q}" ;;
  esac
fi
```

**Edge case: Pipelines**
```bash
# Solution 1: Use PIPEFAIL
set -o pipefail
cat missing_file | grep pattern  # Exits if cat fails

# Solution 2: Check PIPESTATUS array
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then die 1 'cat failed'; fi

# Solution 3: Process substitution
grep pattern < <(cat file1)
```

**Edge case: Command substitution**
```bash
# Check after assignment
output=$(command_that_might_fail) || die 1 'Command failed'

# Or use inherit_errexit (Bash 4.4+)
shopt -s inherit_errexit
output=$(failing_command)  # NOW exits with set -e
```

**Complete example:**
```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
info() { echo "$SCRIPT_NAME: $*"; }

create_backup() {
  local -- source_dir=$1 backup_file=$2 temp_file

  [[ -d "$source_dir" ]] || { error "Source not found ${source_dir@Q}"; return 2; }
  [[ -w "${backup_file%/*}" ]] || { error "Cannot write to '${backup_file%/*}'"; return 5; }

  temp_file="$backup_file".tmp

  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error 'Failed to create tar archive'
    rm -f "$temp_file"
    return 1
  fi

  mv "$temp_file" "$backup_file" || { rm -f "$temp_file"; return 1; }
  sha256sum "$backup_file" > "$backup_file".sha256 || true  # Non-fatal
  info "Backup created ${backup_file@Q}"
}

main() {
  local -a source_dirs=(/etc /var/log)
  local -- dir
  local -i fail_count=0

  for dir in "${source_dirs[@]}"; do
    create_backup "$dir" /backup/"${dir##*/}".tar.gz || ((fail_count++))
  done

  ((fail_count == 0)) || die 1 'Some backups failed'
  info 'All backups completed'
}

main "$@"
#fin
```

**Anti-patterns:**
```bash
# ✗ Ignoring return values
mv "$file" "$dest"  # No check - script continues on failure

# ✓ Check return value
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Checking $? too late
command1
command2
if (($?)); then  # Checks command2, not command1!

# ✗ Generic error message
mv "$file" "$dest" || die 1 'Move failed'  # No context!

# ✗ Not checking command substitution
checksum=$(sha256sum "$file")  # Empty on failure, continues

# ✓ Check command substitution
checksum=$(sha256sum "$file") || die 1 "Checksum failed for ${file@Q}"

# ✗ Not cleaning up after failure
cp "$source" "$dest" || exit 1  # May leave partial file

# ✓ Cleanup on failure
cp "$source" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }

# ✗ Assuming set -e catches everything
set -e
output=$(failing_command)  # Doesn't exit!

# ✓ Explicit checks with proper options
set -euo pipefail
shopt -s inherit_errexit
output=$(failing_command) || die 1 'Command failed'
```

**Summary:**
- Always check return values of critical operations
- Use `set -euo pipefail` + `inherit_errexit` as baseline, add explicit checks
- Provide context in errors (what failed, with what inputs)
- Check command substitution: `output=$(cmd) || die 1 "failed"`
- Use PIPEFAIL/PIPESTATUS for pipeline failures
- Clean up on failure: `|| { cleanup; exit 1; }`
- Test error paths to ensure failures are caught

**Key principle:** Defensive programming assumes operations can fail. Check returns, provide informative errors, handle failures gracefully.
