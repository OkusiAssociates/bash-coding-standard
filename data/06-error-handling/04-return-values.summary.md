## Checking Return Values

**Always check return values of commands and function calls with contextual error messages. While `set -e` helps, explicit checking gives better control.**

**Rationale:**
- Explicit checks enable contextual error messages and controlled recovery
- `set -e` doesn't catch: pipelines (except last), conditionals, command substitution in assignments
- Informative errors aid debugging and user experience

**When `set -e` fails:**

```bash
cat missing_file.txt | grep pattern  # Doesn't exit if cat fails!
if command_that_fails; then echo 'Runs anyway'; fi
output=$(failing_command)  # Doesn't exit!
```

**Return value checking patterns:**

```bash
# Pattern 1: Explicit if (most informative)
if ! mv "$source_file" "$dest_dir/"; then
  error "Failed to move ${source_file@Q} to ${dest_dir@Q}"
  exit 1
fi

# Pattern 2: || with die (concise)
mv "$source_file" "$dest_dir/" || die 1 "Failed to move ${source_file@Q}"

# Pattern 3: || with command group (for cleanup)
mv "$temp_file" "$final_location" || {
  error "Failed to move ${temp_file@Q} to ${final_location@Q}"
  rm -f "$temp_file"
  exit 1
}

# Pattern 4: Capture and check return code
wget "$url"
case $? in
  0) success "Download complete" ;;
  4) die 4 "Network failure" ;;
  *) die 1 "Unknown error: $?" ;;
esac

# Pattern 5: Function return value checking
validate_file() {
  local -- file=$1
  [[ -f "$file" ]] || return 2   # Not found
  [[ -r "$file" ]] || return 5   # Permission denied
  [[ -s "$file" ]] || return 22  # Invalid (empty)
  return 0
}

if validate_file "$config_file"; then
  source "$config_file"
else
  case $? in
    2)  die 2 "Config not found ${config_file@Q}" ;;
    5)  die 5 "Cannot read config ${config_file@Q}" ;;
    22) die 22 "Config empty ${config_file@Q}" ;;
  esac
fi
```

**Edge cases:**

```bash
# Pipelines - use PIPEFAIL or check PIPESTATUS
set -o pipefail
cat file1 | grep pattern | sort
if ((PIPESTATUS[0] != 0)); then die 1 'cat failed'; fi

# Command substitution - check after assignment
output=$(command_that_might_fail) || die 1 'Command failed'
# Or use: shopt -s inherit_errexit

# Conditional contexts - explicit check after
if some_command; then
  process_result
else
  die 1 'some_command failed'
fi
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
  [[ -w "${backup_file%/*}" ]] || { error "Cannot write to ${backup_file%/*}"; return 5; }

  temp_file="${backup_file}.tmp"

  if ! tar -czf "$temp_file" -C "${source_dir%/*}" "${source_dir##*/}"; then
    error 'Failed to create tar archive'
    rm -f "$temp_file"
    return 1
  fi

  if ! mv "$temp_file" "$backup_file"; then
    error 'Failed to move backup to final location'
    rm -f "$temp_file"
    return 1
  fi

  sha256sum "$backup_file" > "$backup_file".sha256 || true  # Non-fatal
  info "Backup created: $backup_file"
}

main() {
  local -a source_dirs=(/etc /var/log)
  local -- dir
  local -i fail_count=0

  for dir in "${source_dirs[@]}"; do
    create_backup "$dir" /backup/"${dir##*/}".tar.gz || fail_count+=1
  done

  ((fail_count == 0)) || die 1 "Some backups failed ($fail_count)"
  info 'All backups completed'
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Ignoring return values
mv "$file" "$dest"
# ✓ Check return value
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Checking $? too late
command1
command2
if (($?)); then  # Checks command2, not command1!
# ✓ Check immediately after each command

# ✗ Generic error message
mv "$file" "$dest" || die 1 'Move failed'
# ✓ Specific error with context
mv "$file" "$dest" || die 1 "Failed to move ${file@Q} to ${dest@Q}"

# ✗ Unchecked command substitution
checksum=$(sha256sum "$file")
# ✓ Check command substitution
checksum=$(sha256sum "$file") || die 1 "Checksum failed for ${file@Q}"

# ✗ No cleanup after failure
cp "$source" "$dest" || exit 1
# ✓ Cleanup on failure
cp "$source" "$dest" || { rm -f "$dest"; die 1 "Copy failed"; }

# ✗ Assuming set -e catches everything
output=$(failing_command)  # Doesn't exit!
# ✓ Explicit checks even with set -e
output=$(failing_command) || die 1 'Command failed'
```

**Key principles:**
- Use `set -euo pipefail` + `shopt -s inherit_errexit` as baseline
- Add explicit checks for critical operations
- Provide contextual error messages with variable values using `${var@Q}`
- Clean up on failure with `|| { cleanup; exit 1; }` pattern
- Use meaningful return codes (0=success, 2=not found, 5=permission, etc.)
