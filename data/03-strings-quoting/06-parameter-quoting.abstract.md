### Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of user input in error messages and logs.**

#### @Q Operator

`${var@Q}` expands to shell-quoted value safe for display/reuse.

```bash
name='$(rm -rf /)'
echo "${name@Q}"  # Output: '$(rm -rf /)' (literal, safe)

# Error messages - ALWAYS use @Q
die 2 "Unknown option ${1@Q}"
```

#### Behavior Comparison

| Input | `$var` | `${var@Q}` |
|-------|--------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | globs | `'*.txt'` |

#### When to Use

**Use @Q:** Error messages, logging input, dry-run display
**Don't use:** Normal expansion (`"$file"`), comparisons

#### Anti-Patterns

- `die "Unknown $1"` → injection risk
- `die "Unknown '$1'"` → still unsafe with embedded quotes

**Ref:** BCS0306
