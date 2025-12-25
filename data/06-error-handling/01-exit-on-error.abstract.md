## Exit on Error

**Always use `set -euo pipefail` at script start (line 4 after description).**

**Flags:**
- `-e`: Exit on command failure (non-zero)
- `-u`: Exit on undefined variable reference
- `-o pipefail`: Pipeline fails if any command fails (not just last)

**Rationale:**
- Catches errors immediately preventing cascading failures
- Scripts behave predictably like compiled languages

**Handle expected failures:**
```bash
command || true                           # Allow failure
if command; then ... else ... fi          # Capture result
set +e; risky_command; set -e            # Temporarily disable
[[ -n "${VAR:-}" ]] && use "$VAR"        # Test undefined vars
```

**Critical gotcha:** `result=$(failing_command)` exits immediately with `set -e` ’ use `if result=$(cmd); then` or wrap in `set +e; ...; set -e`.

**Ref:** BCS0801
