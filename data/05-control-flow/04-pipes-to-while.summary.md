## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead.**

**Rationale:**
- Pipes create subshells; variables modified inside don't persist (counters stay 0, arrays stay empty)
- Silent failure with no error messages - script continues with wrong values
- Process substitution `< <(command)` runs loop in current shell, variables persist
- `readarray` is cleaner and faster for simple line collection
- Failures in piped commands may not trigger `set -e` properly

**The subshell problem:**

```bash
# ✗ WRONG - Subshell loses variable changes
declare -i count=0

echo -e "line1\nline2\nline3" | while IFS= read -r line; do
  echo "$line"
  count+=1
done

echo "Count: $count"  # Output: Count: 0 (NOT 3!)
```

**Solution 1: Process substitution (most common)**

```bash
# ✓ CORRECT - Process substitution avoids subshell
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  count+=1
done < <(echo -e "line1\nline2\nline3")

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Solution 2: Readarray/mapfile (when collecting lines)**

```bash
# ✓ CORRECT - readarray reads all lines into array
declare -a lines

readarray -t lines < <(echo -e "line1\nline2\nline3")

declare -i count="${#lines[@]}"
echo "Count: $count"  # Output: Count: 3 (correct!)

local -- line
for line in "${lines[@]}"; do
  echo "$line"
done
```

**Solution 3: Here-string (for single variables)**

```bash
# ✓ CORRECT - Here-string when input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  count+=1
done <<< "$input"

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**When readarray is better:**

```bash
# ✓ BEST - readarray for simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

local -- line
for line in "${log_lines[@]}"; do
  [[ "$line" =~ ERROR ]] && echo "Error: ${line@Q}" ||:
done

# ✓ BEST - readarray with null-delimited input (handles spaces in filenames)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)

local -- file
for file in "${files[@]}"; do
  echo "Processing: $file"
done
```

**Anti-patterns to avoid:**

```bash
declare -i count=0
# ✗ WRONG - Pipe to while with counter
cat file.txt | while read -r line; do
  count+=1
done
echo "$count"  # Still 0!

# ✓ CORRECT - Process substitution
while read -r line; do
  count+=1
done < <(cat file.txt)
echo "$count"  # Correct!

# ✗ WRONG - Pipe to while building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done
echo "${#files[@]}"  # Still 0!

# ✓ CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)
echo "${#files[@]}"  # Correct!

# ✗ WRONG - Setting flag in piped while
has_errors=0
grep ERROR log | while read -r line; do
  has_errors=1
done
echo "$has_errors"  # Still 0!

# ✓ CORRECT - Use return value
if grep -q ERROR log; then
  has_errors=1
fi
```

**Edge cases:**

**1. Empty input:**
```bash
declare -i count=0
while read -r line; do
  count+=1
done < <(echo -n "")  # No output
echo "Count: $count"  # 0 - correct (no lines)
```

**2. Very large output:**
```bash
# readarray loads everything into memory
readarray -t lines < <(cat huge_file)  # Might use lots of RAM

# Process substitution processes line by line - lower memory usage
while read -r line; do
  process "$line"
done < <(cat huge_file)
```

**3. Null-delimited input (filenames with newlines):**
```bash
while IFS= read -r -d '' file; do
  echo "File: $file"
done < <(find /data -print0)

# Or with readarray
readarray -d '' -t files < <(find /data -print0)
```

**Key principle:** Piping to while is a dangerous anti-pattern that silently loses variable modifications. Always use process substitution `< <(command)` or `readarray` instead. This is not a style preference - it's about correctness. If you find `| while read` in code, it's almost certainly a bug.
