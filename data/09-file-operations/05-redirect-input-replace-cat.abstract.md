## Input Redirection vs Cat

**Use `< file` instead of `cat file` for 3-100x speedup by eliminating fork/exec overhead.**

### Key Patterns

| Context | Anti-pattern → Correct | Speedup |
|---------|------------------------|---------|
| Command substitution | `$(cat f)` → `$(< f)` | **107x** |
| Single file input | `cat f \| cmd` → `cmd < f` | **3-4x** |
| Loops | Multiplied savings per iteration | **10-100x** |

### Why

- `cat`: fork→exec→load binary→read→exit→cleanup (7 steps)
- `<`: open fd→read→close (3 steps, no process)
- `$(< file)`: Bash reads directly, zero processes

### Example

```bash
# CORRECT
content=$(< "$file")
grep ERROR < "$logfile"

# WRONG - forks cat process
content=$(cat "$file")
cat "$logfile" | grep ERROR
```

### When cat IS Required

- Multiple files: `cat f1 f2`
- Options needed: `cat -n file`
- Direct output (standalone `< file` produces nothing)

**Ref:** BCS0905
