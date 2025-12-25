## Temporary File Handling

**Always use `mktemp` for temp files/directories, never hard-code paths. Use trap EXIT handlers to ensure cleanup occurs even on failure/interruption. Proper temp file handling prevents security vulnerabilities, file collisions, and resource leaks.**

**Rationale:**

- **Security**: mktemp creates files with 0600 permissions in safe locations atomically, preventing race conditions
- **Uniqueness**: Guaranteed unique filenames prevent collisions
- **Cleanup Guarantee**: EXIT trap ensures cleanup even when script fails or is interrupted
- **Portability**: mktemp works consistently across Unix-like systems

**Basic temp file creation:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

#  CORRECT - Create temp file and ensure cleanup
create_temp_file() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  info "Created temp file: $temp_file"

  echo 'Test data' > "$temp_file"
  cat "$temp_file"
}

main() {
  create_temp_file
}

main "$@"

#fin
```

**Basic temp directory creation:**

```bash
create_temp_dir() {
  local -- temp_dir

  temp_dir=$(mktemp -d) || die 1 'Failed to create temporary directory'
  trap 'rm -rf "$temp_dir"' EXIT
  readonly -- temp_dir

  info "Created temp directory: $temp_dir"

  echo 'file1' > "$temp_dir/file1.txt"
  echo 'file2' > "$temp_dir/file2.txt"

  ls -la "$temp_dir"
}
```

**Custom temp file templates:**

```bash
#  CORRECT - Temp file with custom template
create_custom_temp() {
  local -- temp_file

  # Template: myapp.XXXXXX (at least 3 X's required)
  temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX) ||
    die 1 'Failed to create temporary file'

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  info "Created temp file: $temp_file"
  # Output example: /tmp/myscript.Ab3X9z

  echo 'Data' > "$temp_file"
}

#  CORRECT - Temp file with extension
create_temp_with_extension() {
  local -- temp_file

  # mktemp doesn't support extensions directly, so add it
  temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
  mv "$temp_file" "$temp_file.json"
  temp_file="$temp_file.json"

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  echo '{"key": "value"}' > "$temp_file"
}
```

**Multiple temp files with cleanup:**

```bash
# Global array for temp files
declare -a TEMP_FILES=()

# Cleanup function for all temp files
cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
    info "Cleaning up ${#TEMP_FILES[@]} temporary files"

    for file in "${TEMP_FILES[@]}"; do
      if [[ -f "$file" ]]; then
        rm -f "$file"
      elif [[ -d "$file" ]]; then
        rm -rf "$file"
      fi
    done
  fi

  return "$exit_code"
}

# Set up cleanup trap
trap cleanup_temp_files EXIT

# Create and register temp file
create_temp() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")

  echo "$temp_file"
}

main() {
  local -- temp1 temp2 temp_dir

  # Create multiple temp files
  temp1=$(create_temp)
  temp2=$(create_temp)
  temp_dir=$(create_temp_dir)

  readonly -- temp1 temp2 temp_dir

  # Use temp files
  echo 'Data 1' > "$temp1"
  echo 'Data 2' > "$temp2"
}
```

**Temp file security validation:**

```bash
#  CORRECT - Robust temp file creation with validation
create_temp_robust() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file: $temp_file"
  fi

  # Validate temp file was created
  if [[ ! -f "$temp_file" ]]; then
    die 1 "Temp file does not exist: $temp_file"
  fi

  # Check permissions (should be 0600)
  local -- perms
  perms=$(stat -c %a "$temp_file" 2>/dev/null || stat -f %Lp "$temp_file" 2>/dev/null)
  if [[ "$perms" != '600' ]]; then
    rm -f "$temp_file"
    die 1 "Temp file has insecure permissions: $perms"
  fi

  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  echo "$temp_file"
}
```

**Anti-patterns:**

```bash
#  WRONG - Hard-coded temp file path
temp_file="/tmp/myapp_temp.txt"
echo 'data' > "$temp_file"
# Problems: Not unique, predictable name, no automatic cleanup

#  CORRECT
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Using PID in filename
temp_file="/tmp/myapp_$$.txt"
# Problems: Still predictable, race condition, no cleanup

#  WRONG - No cleanup trap
temp_file=$(mktemp)
echo 'data' > "$temp_file"
# Script exits, temp file remains!

#  WRONG - Cleanup in script body
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"
# If script fails before rm, file remains!

#  CORRECT - Cleanup in trap
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

#  WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

#  WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT

temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!
# temp1 won't be cleaned up!

#  CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

#  BETTER - Cleanup function
declare -a TEMP_FILES=()
cleanup() {
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
  done
}
trap cleanup EXIT

temp1=$(mktemp)
TEMP_FILES+=("$temp1")

#  WRONG - Removing temp directory without -r
temp_dir=$(mktemp -d)
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

#  CORRECT - Use -rf for directories
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
```

**Edge cases:**

**1. Preserving temp files for debugging:**

```bash
declare -i KEEP_TEMP=0
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=$?
  local -- file

  if ((KEEP_TEMP)); then
    if [[ ${#TEMP_FILES[@]} -gt 0 ]]; then
      info 'Keeping temp files for debugging:'
      for file in "${TEMP_FILES[@]}"; do
        info "  $file"
      done
    fi
  else
    for file in "${TEMP_FILES[@]}"; do
      [[ -f "$file" ]] && rm -f "$file"
      [[ -d "$file" ]] && rm -rf "$file"
    done
  fi

  return "$exit_code"
}

trap cleanup EXIT
```

**2. Temp files in specific directory:**

```bash
# Create temp file in specific directory
temp_file=$(mktemp "$SCRIPT_DIR/temp.XXXXXX") ||
  die 1 'Failed to create temp file in script directory'

trap 'rm -f "$temp_file"' EXIT

# Create temp directory in specific location
temp_dir=$(mktemp -d "$HOME/work/temp.XXXXXX") ||
  die 1 'Failed to create temp directory'

trap 'rm -rf "$temp_dir"' EXIT
```

**3. Handling signals:**

```bash
declare -- TEMP_FILE=''

cleanup() {
  local -i exit_code=$?

  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
  fi

  return "$exit_code"
}

# Cleanup on normal exit and signals
trap cleanup EXIT SIGINT SIGTERM

main() {
  TEMP_FILE=$(mktemp) || die 1 'Failed to create temp file'
  readonly -- TEMP_FILE

  # Simulate long-running operation
  local -i i
  for ((i=1; i<=60; i+=1)); do
    echo "Working... $i"
    sleep 1
  done
}
```

**Summary:**

- **Always use mktemp** - never hard-code temp file paths
- **Use trap EXIT for cleanup** - ensure cleanup happens even on failure
- **Check mktemp success** - `|| die` to handle creation failure
- **Default permissions are secure** - 0600 files, 0700 directories
- **Single trap for all cleanup** - use cleanup function for multiple resources
- **Template support** - `mktemp /tmp/prefix.XXXXXX` for recognizable names
- **Keep variables readonly** - prevent accidental modification
- **--keep-temp option** - useful for debugging
- **Signal handling** - trap SIGINT SIGTERM for interruption cleanup

**Key principle:** Temp files are a common source of security vulnerabilities and resource leaks. Always use mktemp (never hard-code paths), always use trap EXIT (never rely on manual cleanup). The combination of mktemp + trap EXIT is the gold standard - it's atomic, secure, and guarantees cleanup even when scripts fail or are interrupted.
