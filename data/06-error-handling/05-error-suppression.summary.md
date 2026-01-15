## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY.**

**Rationale:**
- Masks bugs and creates silent failures
- Security risk: ignored errors leave systems vulnerable
- Debugging nightmare: impossible to diagnose suppressed errors
- False success: users think operations succeeded when they failed

**When suppression IS appropriate:**

```bash
# 1. Checking if command exists (expected to fail)
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

# 2. Cleanup operations (may have nothing to clean)
rm -f /tmp/myapp_* 2>/dev/null || true
rmdir /tmp/myapp 2>/dev/null || true

# 3. Idempotent operations
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"

# 4. Optional operations with fallback
command -v md2ansi >/dev/null 2>&1 && md2ansi < "$file" || cat "$file"
```

**When suppression is DANGEROUS:**

```bash
# ✗ File operations - script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true

# ✓ Correct - fail explicitly
cp "$important_config" "$destination" || die 1 "Failed to copy config"

# ✗ System configuration - service not running
systemctl start myapp 2>/dev/null || true

# ✓ Correct
systemctl start myapp || die 1 'Failed to start myapp service'

# ✗ Security operations - wrong permissions
chmod 600 "$private_key" 2>/dev/null || true

# ✓ Correct
chmod 600 "$private_key" || die 1 "Failed to secure ${private_key@Q}"

# ✗ Required dependency checks
command -v git >/dev/null 2>&1 || true

# ✓ Correct
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

**Suppression patterns:**

| Pattern | Effect | Use When |
|---------|--------|----------|
| `2>/dev/null` | Suppress stderr only | Messages noisy but check return value |
| `\|\| true` | Ignore return code | Failure acceptable, want to continue |
| `2>/dev/null \|\| true` | Suppress both | Both messages and return code irrelevant |

```bash
# Pattern 4: ALWAYS document WHY
# Rationale: Temp files may not exist, this is not an error
rm -f /tmp/myapp_* 2>/dev/null || true

# Pattern 5: Conditional suppression
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true
else
  actual_operation || die 1 'Operation failed'
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CACHE_DIR="$HOME"/.cache/myapp

# Optional dependency - suppress OK
check_optional_tools() {
  if command -v md2ansi >/dev/null 2>&1; then
    declare -g -i HAS_MD2ANSI=1
  else
    declare -g -i HAS_MD2ANSI=0
  fi
}

# Required dependency - DO NOT suppress
check_required_tools() {
  command -v jq >/dev/null 2>&1 || die 1 'jq is required'
}

# Idempotent creation - suppress OK, but verify
create_directories() {
  # Rationale: install -d is idempotent
  install -d "$CACHE_DIR" 2>/dev/null || true
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create ${CACHE_DIR@Q}"
}

# Cleanup - suppress OK
cleanup_old_files() {
  # Rationale: files may not exist
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
}

# Data processing - DO NOT suppress
process_data() {
  local -- input_file=$1 output_file=$2
  jq '.data' < "$input_file" > "$output_file" || die 1 "Failed to process ${input_file@Q}"
}

main() {
  check_required_tools
  check_optional_tools
  create_directories
  cleanup_old_files
  process_data input.json "$CACHE_DIR"/output.json
}

main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Suppressing critical operation
cp "$important_file" "$backup" 2>/dev/null || true
# ✓ cp "$important_file" "$backup" || die 1 'Failed to create backup'

# ✗ Suppressing without understanding
some_command 2>/dev/null || true
# ✓ Add comment: # Rationale: temp directory may not exist

# ✗ Suppressing all errors in function
process_files() { ... } 2>/dev/null
# ✓ Suppress only specific optional operations

# ✗ Using set +e to suppress errors
set +e; critical_operation; set -e
# ✓ Use || true for specific commands only

# ✗ Different handling prod vs dev
[[ "$ENV" == production ]] && operation 2>/dev/null || operation
# ✓ Same error handling everywhere
```

**Key principles:**
- Suppress only when failure is expected, non-critical, safe to ignore
- Always document WHY with a comment
- Never suppress: data ops, security ops, required dependencies
- Verify after suppressed operations when possible
- Error suppression is the exception, not the rule
