## Exit on Error
```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

**Rationale:** Transforms Bash from permissive to strict mode - catches errors immediately, prevents cascading failures, makes scripts behave like compiled languages.

**Expected failure handling patterns:**

```bash
# Allow specific command to fail
command_that_might_fail || true

# Capture exit code in conditional
if command_that_might_fail; then
  echo "Success"
else
  echo "Expected failure occurred"
fi

# Temporarily disable errexit
set +e
risky_command
set -e

# Check optional variables
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Anti-patterns:**

```bash
# ✗ Script exits on command substitution failure before conditional check
result=$(failing_command)  # Exits here with set -e
if [[ -n "$result" ]]; then  # Never reached
  echo "Never gets here"
fi

# ✓ Disable errexit for command
set +e
result=$(failing_command)
set -e

# ✓ Check in conditional
if result=$(failing_command); then
  echo "Command succeeded: $result"
else
  echo "Command failed, that's okay"
fi
```

**Edge cases:** Disable for interactive scripts with recoverable user errors, scripts trying multiple approaches, or cleanup operations that might fail. Re-enable immediately after.
