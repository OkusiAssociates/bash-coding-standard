## Pipes to While Loops

**Avoid piping commands to while loops because pipes create subshells where variable assignments don't persist outside the loop. Use process substitution `< <(command)` or `readarray` instead.**

**Rationale:**
- Pipes create subshells; variables modified inside don't persist outside
- Silent failure: no errors, script continues with wrong values (counters stay 0, arrays stay empty)
- `< <(command)` runs loop in current shell; `readarray` is cleaner for line collection
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
```

**Solution 3: Here-string (for single variables)**

```bash
# ✓ CORRECT - Here-string when input is in variable
declare -- input=$'line1\nline2\nline3'
declare -i count=0

while IFS= read -r line; do
  count+=1
done <<< "$input"

echo "Count: $count"  # Output: Count: 3 (correct!)
```

**Complete example: Counting matching lines**

```bash
# ✗ WRONG - Counter stays 0
count_errors_wrong() {
  local -- log_file=$1
  local -i error_count=0

  grep 'ERROR' "$log_file" | while IFS= read -r line; do
    error_count+=1
  done

  echo "Errors: $error_count"  # Always 0!
}

# ✓ CORRECT - Process substitution
count_errors_correct() {
  local -- log_file=$1
  local -i error_count=0

  while IFS= read -r line; do
    error_count+=1
  done < <(grep 'ERROR' "$log_file")

  echo "Errors: $error_count"  # Correct count!
}

# ✓ ALSO CORRECT - Using grep -c when only count matters
count_errors_simple() {
  local -- log_file=$1
  local -i error_count

  error_count=$(grep -c 'ERROR' "$log_file")
  echo "Errors: $error_count"
}
```

**Building arrays from command output:**

```bash
# ✗ WRONG - Array stays empty
collect_users_wrong() {
  local -a users=()

  getent passwd | while IFS=: read -r user _; do
    users+=("$user")
  done

  echo "Users: ${#users[@]}"  # Always 0!
}

# ✓ CORRECT - Process substitution
collect_users_correct() {
  local -a users=()

  while IFS=: read -r user _; do
    users+=("$user")
  done < <(getent passwd)

  echo "Users: ${#users[@]}"  # Correct count!
}

# ✓ ALSO CORRECT - readarray (simpler)
collect_users_readarray() {
  local -a users

  readarray -t users < <(getent passwd | cut -d: -f1)
  echo "Users: ${#users[@]}"
}
```

**When readarray is better:**

```bash
# ✓ BEST - readarray for simple line collection
declare -a log_lines
readarray -t log_lines < <(tail -n 100 /var/log/app.log)

# ✓ BEST - readarray with null-delimited input (handles spaces in filenames)
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)

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

# ✗ WRONG - Pipe to while building array
find /data -name '*.txt' | while read -r file; do
  files+=("$file")
done  # files is empty!

# ✓ CORRECT - readarray
readarray -d '' -t files < <(find /data -name '*.txt' -print0)

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

**1. Empty input:** Process substitution handles correctly—loop doesn't execute, variables remain unchanged.

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
# Use -d '' for null-delimited
while IFS= read -r -d '' file; do
  echo "File: $file"
done < <(find /data -print0)

# Or with readarray
readarray -d '' -t files < <(find /data -print0)
```

**Key principle:** Piping to while is a dangerous anti-pattern that silently loses variable modifications. Always use process substitution `< <(command)` or `readarray` instead. If you find `| while read` in code, it's almost certainly a bug.
