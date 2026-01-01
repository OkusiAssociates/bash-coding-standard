### Parameter Quoting with @Q

**Use `${parameter@Q}` for safe display of user input in error messages and logging.**

`${var@Q}` expands to shell-quoted value preventing injection and command execution.

#### Core Behavior

```bash
name='$(rm -rf /)'
echo "${name@Q}"    # Output: '$(rm -rf /)' (safe, literal)
```

| Input | `"$var"` | `${var@Q}` |
|-------|----------|------------|
| `$(date)` | executes | `'$(date)'` |
| `*.txt` | `*.txt` | `'*.txt'` |

#### When to Use

**Use @Q:** Error messages, logging input, dry-run display
```bash
die 2 "Unknown option ${1@Q}"
info "[DRY-RUN] ${cmd[@]@Q}"
```

**Don't use @Q:** Normal expansion (`"$file"`), comparisons

#### Anti-Pattern

```bash
# ✗ Wrong - injection risk
die 2 "Unknown option $1"

# ✓ Correct
die 2 "Unknown option ${1@Q}"
```

**Ref:** BCS0306
