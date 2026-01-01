## Temporary File Handling

**Always use `mktemp` to create temporary files and directories, never hard-code temp file paths. Use trap handlers to ensure cleanup occurs even on script failure or interruption. Store temp file paths in variables, make them readonly when possible, and always clean up in EXIT trap.**

**Rationale:**
- **Security**: mktemp creates files with secure permissions (0600) in safe locations
- **Uniqueness**: Guaranteed unique filenames prevent collisions
- **Atomicity**: mktemp creates file atomically, preventing race conditions
- **Cleanup Guarantee**: EXIT trap ensures cleanup even on failure/interruption
- **Portability**: mktemp works consistently across Unix-like systems

**Basic temp file creation:**

```bash
# ✓ CORRECT - Create temp file and ensure cleanup
create_temp_file() {
  local -- temp_file

  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  trap 'rm -f "$temp_file"' EXIT
  readonly -- temp_file

  echo 'Test data' > "$temp_file"
}
```

**Basic temp directory creation:**

```bash
# ✓ CORRECT - Create temp directory and ensure cleanup
create_temp_dir() {
  local -- temp_dir

  temp_dir=$(mktemp -d) || die 1 'Failed to create temporary directory'
  trap 'rm -rf "$temp_dir"' EXIT
  readonly -- temp_dir

  echo 'file1' > "$temp_dir"/file1.txt
}
```

**Custom temp file templates:**

```bash
# Template: myapp.XXXXXX (at least 3 X's required)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX) ||
  die 1 'Failed to create temporary file'
trap 'rm -f "$temp_file"' EXIT
# Output example: /tmp/myscript.Ab3X9z

# Temp file with extension (mktemp doesn't support extensions directly)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
mv "$temp_file" "$temp_file".json
temp_file="$temp_file".json
trap 'rm -f "$temp_file"' EXIT
```

**Multiple temp files with cleanup:**

```bash
# Global array for temp files
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    if [[ -f "$file" ]]; then
      rm -f "$file"
    elif [[ -d "$file" ]]; then
      rm -rf "$file"
    fi
  done

  return "$exit_code"
}

trap cleanup_temp_files EXIT

# Create and register temp file
create_temp() {
  local -- temp_file
  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")
  echo "$temp_file"
}
```

**Temp file security validation:**

```bash
# ✓ CORRECT - Robust temp file creation with validation
create_temp_robust() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file ${temp_file@Q}"
  fi

  if [[ ! -f "$temp_file" ]]; then
    die 1 "Temp file does not exist ${temp_file@Q}"
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

**Anti-patterns to avoid:**

```bash
# ✗ WRONG - Hard-coded temp file path (not unique, predictable, no cleanup)
temp_file=/tmp/myapp_temp.txt

# ✗ WRONG - Using PID in filename (still predictable, race condition)
temp_file=/tmp/myapp_"$$".txt

# ✗ WRONG - No cleanup trap
temp_file=$(mktemp)
echo 'data' > "$temp_file"
# Script exits, temp file remains!

# ✗ WRONG - Cleanup in script body (fails if script fails before rm)
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"

# ✗ WRONG - Creating temp file manually (not atomic, race conditions)
temp_file="/tmp/myapp_$(date +%s).txt"
touch "$temp_file"
chmod 600 "$temp_file"

# ✗ WRONG - Insecure permissions
temp_file=$(mktemp)
chmod 666 "$temp_file"  # World writable!

# ✗ WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

# ✗ WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT
temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!

# ✓ CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

# ✗ WRONG - Removing temp directory without -r
temp_dir=$(mktemp -d)
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

# ✓ CORRECT - Use -rf for directories
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
    info 'Keeping temp files for debugging:'
    for file in "${TEMP_FILES[@]}"; do
      info "  $file"
    done
  else
    for file in "${TEMP_FILES[@]}"; do
      [[ -f "$file" ]] && rm -f "$file" ||:
      [[ -d "$file" ]] && rm -rf "$file" ||:
    done
  fi

  return "$exit_code"
}

trap cleanup EXIT
```

**2. Temp files in specific directory:**

```bash
# Create temp file in specific directory
temp_file=$(mktemp "$SCRIPT_DIR"/temp.XXXXXX) ||
  die 1 'Failed to create temp file in script directory'
trap 'rm -f "$temp_file"' EXIT

# Create temp directory in specific location
temp_dir=$(mktemp -d "$HOME"/work/temp.XXXXXX) ||
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
```

**Summary:**
- **Always use mktemp** - never hard-code temp file paths
- **Use trap for cleanup** - ensure cleanup happens even on failure
- **EXIT trap is mandatory** - automatic cleanup when script ends
- **Check mktemp success** - `|| die` to handle creation failure
- **Default permissions are secure** - mktemp creates 0600 files, 0700 directories
- **Use cleanup function pattern** - for multiple temp files/directories
- **Handle signals** - trap SIGINT SIGTERM for interruption cleanup
