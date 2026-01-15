### Parameter Quoting with @Q

**`${param@Q}` produces shell-quoted output safe for display—prevents injection in error messages and logs.**

#### Core Behavior

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | literal | `'*.txt'` |

#### Usage Pattern

```bash
# Error messages - safe display of untrusted input
die 2 "Unknown option ${1@Q}"
info "Processing ${file@Q}"

# Dry-run - quote array for display
printf -v quoted '%s ' "${cmd[@]@Q}"
```

#### When to Use

- **Use @Q:** Error messages, logging user input, dry-run display
- **Don't use:** Normal expansion (`"$file"`), comparisons

#### Anti-Patterns

```bash
# ✗ Injection risk
die 2 "Unknown option $1"

# ✓ Safe
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0306
