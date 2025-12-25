## Temporary File Handling

**Always use `mktemp` for temp files/directories; use `trap` EXIT handlers for guaranteed cleanup.**

**Rationale:** mktemp creates files atomically with secure permissions (0600) preventing race conditions. EXIT trap ensures cleanup even on failure/interruption.

**Basic pattern:**

```bash
# Single temp file
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file

# Temp directory
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
readonly -- temp_dir
```

**Multiple temp resources:**

```bash
declare -a TEMP_FILES=()

cleanup() {
  local -i exit_code=$?
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
    [[ -d "$file" ]] && rm -rf "$file"
  done
  return "$exit_code"
}
trap cleanup EXIT

temp1=$(mktemp) || die 1 'Failed'
TEMP_FILES+=("$temp1")
```

**Critical anti-patterns:**

```bash
# ✗ Hard-coded path → collisions, insecure
temp_file="/tmp/myapp_temp.txt"

# ✗ PID in filename → predictable, race conditions  
temp_file="/tmp/myapp_$$.txt"

# ✗ No trap → file remains on exit/failure
temp_file=$(mktemp)

# ✗ Multiple traps overwrite → only last executes
trap 'rm -f "$temp1"' EXIT
trap 'rm -f "$temp2"' EXIT  # temp1 lost!

# ✓ Single trap for all
trap 'rm -f "$temp1" "$temp2"' EXIT
```

**Template:** `mktemp /tmp/script.XXXXXX` (≥3 X's)

**Ref:** BCS1403
