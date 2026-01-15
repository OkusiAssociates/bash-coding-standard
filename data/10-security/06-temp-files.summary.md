## Temporary File Handling

**Always use `mktemp` to create temporary files and directories, never hard-code temp file paths. Use trap handlers to ensure cleanup occurs even on script failure or interruption.**

**Rationale:**
- **Security**: mktemp creates files with secure permissions (0600) atomically, preventing race conditions
- **Uniqueness**: Guaranteed unique filenames prevent collisions with other processes
- **Cleanup Guarantee**: EXIT trap ensures cleanup even when script fails or is interrupted
- **Portability**: mktemp works consistently across Unix-like systems using TMPDIR or /tmp

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

# Temp file with extension (mktemp doesn't support extensions directly)
temp_file=$(mktemp /tmp/"$SCRIPT_NAME".XXXXXX)
mv "$temp_file" "$temp_file".json
temp_file="$temp_file".json
```

**Multiple temp files with cleanup function:**

```bash
declare -a TEMP_FILES=()

cleanup_temp_files() {
  local -i exit_code=$?
  local -- file

  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file" ||:
    [[ -d "$file" ]] && rm -rf "$file" ||:
  done

  return "$exit_code"
}

trap cleanup_temp_files EXIT

create_temp() {
  local -- temp_file
  temp_file=$(mktemp) || die 1 'Failed to create temporary file'
  TEMP_FILES+=("$temp_file")
  echo "$temp_file"
}
```

**Secure temp file with validation:**

```bash
secure_temp_file() {
  local -- temp_file

  if ! temp_file=$(mktemp 2>&1); then
    die 1 "Failed to create temporary file ${temp_file@Q}"
  fi

  # Validate temp file exists and is regular file
  [[ -f "$temp_file" ]] || die 1 "Temp file does not exist ${temp_file@Q}"

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
# ✗ WRONG - Hard-coded temp file path (collisions, predictable, no cleanup)
temp_file=/tmp/myapp_temp.txt

# ✗ WRONG - Using PID in filename (still predictable, race condition)
temp_file=/tmp/myapp_"$$".txt

# ✗ WRONG - No cleanup trap (temp file remains if script fails)
temp_file=$(mktemp)
echo 'data' > "$temp_file"

# ✗ WRONG - Cleanup in script body, not trap (cleanup skipped on failure)
temp_file=$(mktemp)
echo 'data' > "$temp_file"
rm -f "$temp_file"

# ✗ WRONG - Multiple traps overwrite each other
temp1=$(mktemp)
trap 'rm -f "$temp1"' EXIT
temp2=$(mktemp)
trap 'rm -f "$temp2"' EXIT  # Overwrites previous trap!

# ✓ CORRECT - Single trap for all cleanup
temp1=$(mktemp) || die 1 'Failed to create temp file'
temp2=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp1" "$temp2"' EXIT

# ✗ WRONG - Insecure permissions
chmod 666 "$temp_file"  # World writable!

# ✗ WRONG - Not checking mktemp success
temp_file=$(mktemp)
echo 'data' > "$temp_file"  # May fail if mktemp failed!

# ✗ WRONG - Removing temp directory without -r
trap 'rm "$temp_dir"' EXIT  # Fails if directory not empty!

# ✓ CORRECT - Use -rf for directories
trap 'rm -rf "$temp_dir"' EXIT
```

**Edge Cases:**

**1. Preserving temp files for debugging:**

```bash
declare -i KEEP_TEMP=0

cleanup() {
  local -i exit_code=$?

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
```

**2. Signal handling for cleanup on interruption:**

```bash
# Cleanup on normal exit and signals
trap cleanup EXIT SIGINT SIGTERM
```

**3. Temp files in specific directory:**

```bash
temp_file=$(mktemp "$SCRIPT_DIR"/temp.XXXXXX) ||
  die 1 'Failed to create temp file in script directory'

temp_dir=$(mktemp -d "$HOME"/work/temp.XXXXXX) ||
  die 1 'Failed to create temp directory'
```

**Summary:**

| Requirement | Implementation |
|-------------|----------------|
| Always use mktemp | Never hard-code temp file paths |
| EXIT trap mandatory | Automatic cleanup when script ends |
| Check mktemp success | `\|\| die` to handle creation failure |
| Secure permissions | mktemp creates 0600 files, 0700 directories |
| Multiple temp files | Use array + cleanup function pattern |
| Signal handling | trap SIGINT SIGTERM for interruption cleanup |
| Debug support | --keep-temp option to preserve files |

**Key principle:** The combination of mktemp + trap EXIT is the gold standard for temp file handling - it's atomic, secure, and guarantees cleanup even when scripts fail or are interrupted.
