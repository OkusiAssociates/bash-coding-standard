## Exit on Error

**Always use `set -euo pipefail` at script start for strict mode.**

- `-e`: Exit on command failure
- `-u`: Exit on undefined variable
- `-o pipefail`: Pipeline fails if any command fails

**Rationale:** Catches errors immediately; prevents cascading failures.

**Handling expected failures:**
```bash
command_that_might_fail || true      # Allow failure
if result=$(failing_cmd); then       # Check in conditional
  echo "$result"
fi
${OPTIONAL_VAR:-}                    # Safe undefined access
```

**Critical gotcha:** `result=$(failing_cmd)` exits before you can check `$result` → wrap in conditional or use `set +e`.

**Anti-patterns:**
- `set -e` after logic starts → must be at top
- Forgetting `pipefail` → `cmd1 | cmd2` hides `cmd1` failures

**Ref:** BCS0601
