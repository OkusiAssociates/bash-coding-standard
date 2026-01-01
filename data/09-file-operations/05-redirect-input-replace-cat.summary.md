## Input Redirection vs Cat: Performance Optimization

Replace `cat filename` with `< filename` redirection to eliminate process fork overhead. Provides 3-100x speedup.

## Performance Comparison

| Scenario | `cat` | `< file` | Speedup |
|----------|-------|----------|---------|
| Output to /dev/null (1000 iter) | 0.792s | 0.234s | **3.4x** |
| Command substitution (1000 iter) | 0.965s | 0.009s | **107x** |
| Large file (500 iter) | 0.398s | 0.115s | **3.5x** |

**Why:** `cat` requires forkâ†'execâ†'loadâ†'readâ†'waitâ†'cleanup (7 steps). Redirection: openâ†'readâ†'close (3 steps). Command substitution `$(< file)` has zero external processes.

## When to Use `< filename`

### Command Substitution (107x speedup)

```bash
# RECOMMENDED - Zero external processes
content=$(< file.txt)
config=$(< /etc/app.conf)

# AVOID - 100x slower
content=$(cat file.txt)
```

### Single Input to Command (3-4x speedup)

```bash
# RECOMMENDED
grep "pattern" < file.txt
while read line; do ...; done < file.txt
jq '.field' < data.json

# AVOID - Wastes a cat process
cat file.txt | grep "pattern"
cat data.json | jq '.field'
```

### Loop Optimization (cumulative gains)

```bash
# RECOMMENDED
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

# AVOID - Forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
done
```

## When NOT to Use `< filename`

| Scenario | Why | Use Instead |
|----------|-----|-------------|
| Multiple files | Invalid syntax | `cat file1 file2` |
| Need cat options | No `-n`, `-A`, etc. | `cat -n file` |
| Direct output | `< file` alone produces nothing | `cat file` |
| Concatenation | Cannot combine sources | `cat f1 f2 f3` |

### Invalid Usage

```bash
# WRONG - Does nothing (no command to consume stdin)
< /tmp/test.txt

# WRONG - Invalid syntax
< file1.txt file2.txt

# RIGHT - Must use cat for multiple files
cat file1.txt file2.txt
```

## Technical Details

The `<` operator is a **redirection operator**, not a command. It opens a file on stdin but requires a command to consume input.

**Exception:** Command substitution `$(< file)` - bash reads file directly into variable.

## Real-World Example

**Before (400 forks for 100 files):**
```bash
for logfile in /var/log/app/*.log; do
    content=$(cat "$logfile")
    errors=$(cat "$logfile" | grep -c ERROR)
    warnings=$(cat "$logfile" | grep WARNING)
done
```

**After (100 forks eliminated per file):**
```bash
for logfile in /var/log/app/*.log; do
    content=$(< "$logfile")
    errors=$(grep -c ERROR < "$logfile")
    warnings=$(grep WARNING < "$logfile")
done
```

## Recommendation

**SHOULD use `< filename`:**
- Command substitution: `var=$(< file)`
- Single file input: `cmd < file`
- Loops with file reads

**MUST use `cat`:**
- Multiple file arguments
- Using options `-n`, `-b`, `-E`, `-T`, `-s`, `-v`

## Testing

```bash
# Command substitution speedup
time for i in {1..1000}; do content=$(cat /tmp/test.txt); done  # ~0.8-1.0s
time for i in {1..1000}; do content=$(< /tmp/test.txt); done    # ~0.01s

# Pipeline speedup
time for i in {1..500}; do cat /tmp/numbers.txt | wc -l > /dev/null; done  # ~0.4s
time for i in {1..500}; do wc -l < /tmp/numbers.txt > /dev/null; done      # ~0.1s
```

## See Also

- ShellCheck SC2002 (useless cat)
- Bash manual: Redirections
