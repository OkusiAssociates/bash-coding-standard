## Exit on Error

```bash
set -euo pipefail
# -e: Exit on command failure
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

**Rationale:** Strict mode catches errors immediately, prevents cascading failures, makes scripts behave like compiled languages.

**Handling expected failures:**

```bash
# Allow specific command to fail
command_that_might_fail || true

# Capture exit code in conditional
if command_that_might_fail; then
  echo 'Success'
else
  echo 'Expected failure occurred'
fi

# Temporarily disable errexit
set +e
risky_command
set -e

# Check optional variable safely
if [[ -n "${OPTIONAL_VAR:-}" ]]; then
  echo "Variable is set: $OPTIONAL_VAR"
fi
```

**Critical gotcha - command substitution exits immediately:**

```bash
# ✗ Script exits here with set -e
result=$(failing_command)  # Never reaches next line

# ✓ Correct - disable errexit for this command
set +e
result=$(failing_command)
set -e

# ✓ Alternative - check in conditional
if result=$(failing_command); then
  echo "Command succeeded: $result"
fi
```

**When to disable:** Interactive scripts, scripts trying multiple approaches, cleanup operations. Re-enable immediately after.
