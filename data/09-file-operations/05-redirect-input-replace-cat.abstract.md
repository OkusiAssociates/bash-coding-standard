## Input Redirection vs Cat

**Replace `cat file` with `< file` redirection to eliminate process fork overhead (3-107x speedup).**

### Key Patterns

| Context | Speedup | Technique |
|---------|---------|-----------|
| Command substitution | **107x** | `$(< file)` |
| Single file to command | **3-4x** | `cmd < file` |
| Loops | **cumulative** | Avoid repeated forks |

### Core Example

```bash
# ✓ CORRECT - 107x faster (zero processes)
content=$(< config.json)
errors=$(grep -c ERROR < "$logfile")

# ✗ AVOID - forks cat process each time
content=$(cat config.json)
errors=$(cat "$logfile" | grep -c ERROR)
```

### When `cat` is Required

- **Multiple files**: `cat file1 file2` (syntax requirement)
- **cat options**: `-n`, `-b`, `-A`, `-E` (no redirection equivalent)
- **Direct output**: `< file` alone produces nothing

### Anti-Patterns

```bash
# ✗ Does nothing - no command to consume stdin
< /tmp/test.txt

# ✗ Invalid syntax
< file1.txt file2.txt
```

### Why It Works

`$(< file)` is Bash magic: shell reads file directly into substitution result with zero external processes. Regular `< file` only opens file descriptor—requires a command to consume it.

**Ref:** BCS0905
