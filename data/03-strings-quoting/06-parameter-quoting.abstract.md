### Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of untrusted input in error messages and logs.**

#### Why
- Prevents command injection via `$(...)` or glob expansion in displayed strings
- Shows exact literal value without execution risk

#### Pattern
```bash
# Error messages - always @Q for user input
die 2 "Unknown option ${1@Q}"

# Dry-run display
printf -v quoted '%s ' "${cmd[@]@Q}"
info "[DRY-RUN] $quoted"
```

#### When to Use
- **Yes:** Error messages, logging user input, dry-run output
- **No:** Normal expansion `"$var"`, comparisons `[[ "$a" == "$b" ]]`

#### Anti-Pattern
```bash
# ✗ Injection risk - user controls displayed value
die 2 "Unknown option $1"
# ✓ Safe literal display
die 2 "Unknown option ${1@Q}"
```

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(rm -rf /)` | executes | `'$(rm -rf /)'` |

**Ref:** BCS0306
