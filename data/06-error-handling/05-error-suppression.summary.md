## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY.**

**Rationale:** Suppression masks bugs, creates silent failures, leaves systems in insecure states, makes debugging impossible, and indicates design problems requiring fixes.

### When Suppression IS Appropriate

**1. Command/file existence checks (failure expected):**
```bash
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

if [[ -f "$optional_config" ]]; then
  source "$optional_config"
fi
```

**2. Cleanup operations (may have nothing to clean):**
```bash
cleanup_temp_files() {
  # Suppress - temp files might not exist
  rm -f /tmp/myapp_* 2>/dev/null || true
  rmdir /tmp/myapp 2>/dev/null || true
}
```

**3. Idempotent operations:**
```bash
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"
```

### When Suppression is DANGEROUS

**Critical operations that MUST NOT be suppressed:**

```bash
# ✗ DANGEROUS - copy fails, script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true
# ✓ Correct
cp "$important_config" "$destination" || die 1 "Failed to copy config"

# ✗ DANGEROUS - data silently lost
process_data < input.txt > output.txt 2>/dev/null || true
# ✓ Correct
process_data < input.txt > output.txt || die 1 'Data processing failed'

# ✗ DANGEROUS - service not running
systemctl start myapp 2>/dev/null || true
# ✓ Correct
systemctl start myapp || die 1 'Failed to start myapp service'

# ✗ DANGEROUS - wrong permissions (security vulnerability)
chmod 600 "$private_key" 2>/dev/null || true
# ✓ Correct
chmod 600 "$private_key" || die 1 "Failed to secure ${private_key@Q}"

# ✗ DANGEROUS - missing dependency, later failures mysterious
command -v git >/dev/null 2>&1 || true
# ✓ Correct
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

### Suppression Patterns

| Pattern | Effect | Use When |
|---------|--------|----------|
| `2>/dev/null` | Suppress stderr only | Error messages noisy but check return value |
| `\|\| true` | Ignore return code | Failure acceptable, continue execution |
| `2>/dev/null \|\| true` | Suppress both | Both messages and return code irrelevant |

**Always document suppression:**
```bash
# Rationale: Temp files may not exist, this is not an error
rm -f /tmp/myapp_* 2>/dev/null || true
```

**Conditional suppression:**
```bash
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true  # Expected to fail
else
  actual_operation || die 1 'Operation failed'
fi
```

### Anti-Patterns

```bash
# ✗ WRONG - suppressing without documented reason
some_command 2>/dev/null || true

# ✗ WRONG - suppressing ALL errors in function
process_files() {
  # ... many operations ...
} 2>/dev/null

# ✓ Correct - only suppress specific operations
process_files() {
  critical_operation || die 1 'Critical operation failed'
  optional_cleanup 2>/dev/null || true  # Only this suppressed
}

# ✗ WRONG - using set +e to suppress errors
set +e
critical_operation
set -e

# ✓ Correct - use || true for specific command
critical_operation || {
  error 'Operation failed but continuing'
  true
}

# ✗ WRONG - different handling for production vs development
if [[ "$ENV" == production ]]; then
  operation 2>/dev/null || true
else
  operation
fi
```

### Complete Example

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CACHE_DIR="$HOME"/.cache/myapp

# Optional dependency - suppression OK
check_optional_tools() {
  if command -v md2ansi >/dev/null 2>&1; then
    declare -g -i HAS_MD2ANSI=1
  else
    declare -g -i HAS_MD2ANSI=0
  fi
}

# Required dependency - NO suppression
check_required_tools() {
  command -v jq >/dev/null 2>&1 || die 1 'jq is required'
}

# Idempotent creation - suppression OK, but verify
create_directories() {
  # Rationale: install -d is idempotent
  install -d "$CACHE_DIR" 2>/dev/null || true
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create ${CACHE_DIR@Q}"
}

# Cleanup - suppression OK
cleanup_old_files() {
  # Rationale: files may not exist
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
}

# Data processing - NO suppression
process_data() {
  local -- input_file=$1 output_file=$2
  jq '.data' < "$input_file" > "$output_file" || die 1 "Failed: ${input_file@Q}"
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

### Key Rules

- **Only suppress** when failure is expected, non-critical, and safe
- **Always document** WHY with comment above suppression
- **Never suppress** critical operations (data, security, required dependencies)
- **Verify after** suppressed operations when possible
- **Test without** suppression first to ensure correctness
