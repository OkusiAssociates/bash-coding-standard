## Error Suppression

**Only suppress errors when failure is expected, non-critical, and explicitly safe. Always document WHY. Indiscriminate suppression masks bugs and creates unreliable scripts.**

**Rationale:**

- Masks real bugs and creates silent failures
- Security risk: ignored errors leave systems in insecure states
- Makes debugging impossible when errors are hidden
- False success signals while operations actually failed
- Indicates design problems that should be fixed, not hidden

**Appropriate error suppression:**

**1. Checking command/file existence (expected to fail):**

```bash
#  Failure is expected and non-critical
if command -v optional_tool >/dev/null 2>&1; then
  info 'optional_tool available'
fi

if [[ -f "$optional_config" ]]; then
  source "$optional_config"
fi
```

**2. Cleanup operations (may fail if nothing exists):**

```bash
#  Cleanup may have nothing to do
cleanup_temp_files() {
  rm -f /tmp/myapp_* 2>/dev/null || true
  rmdir /tmp/myapp 2>/dev/null || true
}
```

**3. Optional operations with fallback:**

```bash
#  Have fallback if optional tool unavailable
if command -v md2ansi >/dev/null 2>&1; then
  md2ansi < "$file" || cat "$file"
else
  cat "$file"
fi
```

**4. Idempotent operations:**

```bash
#  Directory/user may already exist
install -d "$target_dir" 2>/dev/null || true
id "$username" >/dev/null 2>&1 || useradd "$username"
```

**Dangerous error suppression:**

**1. File operations (usually critical):**

```bash
#  DANGEROUS - script continues with missing file
cp "$important_config" "$destination" 2>/dev/null || true

#  Correct - fail explicitly
if ! cp "$important_config" "$destination"; then
  die 1 "Failed to copy config to $destination"
fi
```

**2. Data processing (silently loses data):**

```bash
#  DANGEROUS - data loss
process_data < input.txt > output.txt 2>/dev/null || true

#  Correct
if ! process_data < input.txt > output.txt; then
  die 1 'Data processing failed'
fi
```

**3. System configuration (leaves system broken):**

```bash
#  DANGEROUS - service not running but script continues
systemctl start myapp 2>/dev/null || true

#  Correct
systemctl start myapp || die 1 'Failed to start myapp service'
```

**4. Security operations (creates vulnerabilities):**

```bash
#  DANGEROUS - wrong permissions
chmod 600 "$private_key" 2>/dev/null || true

#  Correct - security must succeed
chmod 600 "$private_key" || die 1 "Failed to secure $private_key"
```

**5. Dependency checks (script runs without required tools):**

```bash
#  DANGEROUS - later commands fail mysteriously
command -v git >/dev/null 2>&1 || true

#  Correct - fail early
command -v git >/dev/null 2>&1 || die 1 'git is required'
```

**Error suppression patterns:**

**Pattern 1: Redirect stderr (suppress messages, check return):**

```bash
# Use when error messages are noisy but you check return value
if ! command 2>/dev/null; then
  error "command failed"
fi
```

**Pattern 2: || true (ignore return code):**

```bash
# Make command always succeed
command || true
# Use when failure is acceptable
rm -f /tmp/optional_file || true
```

**Pattern 3: Combined (suppress both):**

```bash
# Use when both messages and return code are irrelevant
rmdir /tmp/maybe_exists 2>/dev/null || true
```

**Pattern 4: Always document WHY:**

```bash
# Suppress errors: temp files may not exist (non-critical)
rm -f /tmp/myapp_* 2>/dev/null || true

# Suppress errors: directory may exist from previous run
install -d "$cache_dir" 2>/dev/null || true
```

**Pattern 5: Conditional suppression:**

```bash
if ((DRY_RUN)); then
  actual_operation 2>/dev/null || true  # Expected to fail
else
  actual_operation || die 1 'Operation failed'  # Must succeed
fi
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -- CACHE_DIR="$HOME/.cache/myapp"
declare -- LOG_FILE="$HOME/.local/share/myapp/app.log"

check_optional_tools() {
  #  Safe - tool is optional
  if command -v md2ansi >/dev/null 2>&1; then
    info 'md2ansi available for formatted output'
    declare -g -i HAS_MD2ANSI=1
  else
    info 'md2ansi not found (optional)'
    declare -g -i HAS_MD2ANSI=0
  fi
}

check_required_tools() {
  #  Do NOT suppress - required
  if ! command -v jq >/dev/null 2>&1; then
    die 1 'jq is required but not found'
  fi
}

create_directories() {
  #  Safe - idempotent operation
  install -d "$CACHE_DIR" 2>/dev/null || true
  install -d "${LOG_FILE%/*}" 2>/dev/null || true

  # But verify they exist
  [[ -d "$CACHE_DIR" ]] || die 1 "Failed to create cache directory: $CACHE_DIR"
  [[ -d "${LOG_FILE%/*}" ]] || die 1 "Failed to create log directory: ${LOG_FILE%/*}"
}

cleanup_old_files() {
  #  Safe - best-effort cleanup
  rm -f "$CACHE_DIR"/*.tmp 2>/dev/null || true
  rm -f "$CACHE_DIR"/*.old 2>/dev/null || true
  rmdir "$CACHE_DIR"/temp_* 2>/dev/null || true
}

process_data() {
  local -- input_file="$1"
  local -- output_file="$2"

  #  Do NOT suppress - data processing is critical
  if ! jq '.data' < "$input_file" > "$output_file"; then
    die 1 "Failed to process $input_file"
  fi

  if ! jq empty < "$output_file"; then
    die 1 "Output file is invalid: $output_file"
  fi
}

main() {
  check_required_tools
  check_optional_tools
  create_directories
  cleanup_old_files
  process_data 'input.json' "$CACHE_DIR/output.json"
}

main "$@"

#fin
```

**Critical anti-patterns:**

```bash
#  WRONG - suppressing critical operation
cp "$important_file" "$backup" 2>/dev/null || true
#  Correct
cp "$important_file" "$backup" || die 1 "Failed to create backup"

#  WRONG - no explanation
some_command 2>/dev/null || true
#  Correct - document reason
# Suppress errors: temp directory may not exist (non-critical)
rmdir /tmp/myapp 2>/dev/null || true

#  WRONG - suppressing entire function
process_files() {
  # ... many operations ...
} 2>/dev/null
#  Correct - only suppress specific operations
process_files() {
  critical_operation || die 1 'Critical operation failed'
  optional_cleanup 2>/dev/null || true
}

#  WRONG - using set +e
set +e
critical_operation
set -e
#  Correct - use || true for specific command
critical_operation || {
  error 'Operation failed but continuing'
  true
}

#  WRONG - different handling in production
if [[ "$ENV" == "production" ]]; then
  operation 2>/dev/null || true
else
  operation
fi
#  Correct - same handling everywhere
operation || die 1 'Operation failed'
```

**Summary:**

- Only suppress when failure is expected, non-critical, and safe
- Always document WHY with comment above suppression
- Never suppress critical operations (data, security, dependencies)
- `|| true` ignores return code, `2>/dev/null` suppresses messages, combined suppresses both
- Verify after suppressed operations when possible
- Test without suppression first to ensure correctness

**Key principle:** Error suppression is the exception, not the rule. Every `2>/dev/null` and `|| true` is a deliberate decision that this specific failure is safe to ignore. Document it.
