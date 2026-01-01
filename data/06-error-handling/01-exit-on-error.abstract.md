## Exit on Error

**Mandatory `set -euo pipefail` enables strict mode: exit on command failure (`-e`), undefined variables (`-u`), or pipe failures (`-o pipefail`).**

**Why:** Catches errors immediately; prevents cascading failures; makes scripts behave like compiled languages.

### Handling Expected Failures

```bash
# Allow failure
cmd_might_fail || true

# Capture in conditional (avoids set -e exit)
if result=$(failing_cmd); then
  echo "OK: $result"
fi

# Temporary disable
set +e; risky_cmd; set -e
```

### Critical Gotcha

```bash
# ✗ Exits before check (set -e triggers on substitution)
result=$(failing_cmd)
[[ -n "$result" ]] && echo "$result"

# ✓ Conditional protects from exit
if result=$(failing_cmd); then echo "$result"; fi
```

**Anti-patterns:** Leaving flags disabled longer than necessary �' re-enable immediately after risky operation.

**Ref:** BCS0601
