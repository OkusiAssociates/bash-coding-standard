## Input Redirection vs Cat: Performance Optimization

Replace `cat filename` with `< filename` redirection to eliminate process fork overhead. Provides 3-100x speedup depending on usage pattern.

## Performance Comparison

| Scenario | `cat` | `< file` | Speedup |
|----------|-------|----------|---------|
| Command substitution (1000 iter) | 0.965s | 0.009s | **107x** |
| Output to /dev/null (1000 iter) | 0.792s | 0.234s | **3.4x** |
| Large file (500 iter) | 0.398s | 0.115s | **3.5x** |

**Why:** `cat` requires fork→exec→load binary→setup environment→read→exit→cleanup. Redirection: open fd→read→close (all in-shell).

## When to Use `< filename`

### Command Substitution (107x speedup)

```bash
# RECOMMENDED - Massively faster
content=$(< file.txt)
config=$(< /etc/app.conf)

# AVOID - 100x slower
content=$(cat file.txt)
```

Bash reads file directly into variable with zero external processes.

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

### Loop Optimization (Cumulative gains)

```bash
# RECOMMENDED
for file in *.json; do
    data=$(< "$file")
    process "$data"
done

# AVOID - Forks cat thousands of times
for file in *.json; do
    data=$(cat "$file")
    process "$data"
done
```

1000 iterations = 1000 avoided process creations.

## When NOT to Use `< filename`

| Scenario | Reason | Use Instead |
|----------|--------|-------------|
| Multiple files | Invalid syntax | `cat file1 file2` |
| Need `-n`, `-A`, `-b`, `-s` | No option support | `cat -n file` |
| Direct output | `< file` alone produces nothing | `cat file` |
| POSIX portability | Older shells may not optimize | `cat file` |

### Invalid Usage

```bash
# WRONG - Does nothing visible
< /tmp/test.txt
# Output: (nothing - redirection without command)

# WRONG - Invalid syntax
< file1.txt file2.txt

# RIGHT - Must use cat
cat file1.txt file2.txt
```

## Technical Details

`<` is a **redirection operator**, not a command. It opens a file on stdin; you need a command to consume that input:

```bash
cat < /tmp/test.txt    # cat reads from stdin
< /tmp/test.txt cat    # Same, different order
```

### Command Substitution Exception

```bash
content=$(< file.txt)
```

In `$()` context, bash itself reads the file and captures it. This is the only case where `< filename` works standalone.

## Real-World Example

### Before Optimization

```bash
for logfile in /var/log/app/*.log; do
    content=$(cat "$logfile")
    errors=$(cat "$logfile" | grep -c ERROR)
    warnings=$(cat "$logfile" | grep WARNING)
done
```

**Problem:** 4 cat processes per iteration; 100 files = 400 forks.

### After Optimization

```bash
for logfile in /var/log/app/*.log; do
    content=$(< "$logfile")
    errors=$(grep -c ERROR < "$logfile")
    warnings=$(grep WARNING < "$logfile")
done
```

**Result:** 300 fewer process forks, 10-100x faster.

## Recommendation

**SHOULD:** Use `< filename` for:
- Command substitution: `var=$(< file)`
- Single file input: `cmd < file`
- Loops with many file reads

**MUST:** Use `cat` when:
- Multiple file arguments needed
- Using options `-n`, `-b`, `-E`, `-T`, `-s`, `-v`

## Testing

```bash
echo "Test content" > /tmp/test.txt

time for i in {1..1000}; do content=$(cat /tmp/test.txt); done
# Expected: ~0.8-1.0s

time for i in {1..1000}; do content=$(< /tmp/test.txt); done
# Expected: ~0.01s (100x faster)
```

## See Also

- ShellCheck SC2002 (useless cat)
- Bash manual: Redirections

**Ref:** BCS0905
