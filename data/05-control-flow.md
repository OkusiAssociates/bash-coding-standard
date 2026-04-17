# Section 05: Control Flow

## BCS0500 Section Overview

Use `[[ ]]` for string and file tests, `(())` for arithmetic. Never use `[ ]`. This section covers conditionals, case statements, loops, arithmetic, and floating-point operations.

## BCS0501 Conditionals

**Tier:** core

```bash
# correct — [[ ]] for strings/files, (()) for arithmetic
[[ -f $file ]]
[[ $name == "$expected" ]]
((count > 5))

# correct — arithmetic truthiness
((count))                            # true if non-zero
((VERBOSE)) || return 0

# correct — pattern matching
[[ $file == *.txt ]]                 # glob
[[ $input =~ ^[0-9]+$ ]]             # regex

# correct — short-circuit
[[ -f $file ]] && source "$file"
command -v curl >/dev/null || die 18 'curl required'

# wrong
[ -f "$file" ]                       # never use [ ]
((count > 0))                        # use ((count)) instead
((VERBOSE == 1))                     # use ((VERBOSE)) instead
```

## BCS0502 Case Statements

**Tier:** recommended

Use `case` for multi-way branching on a single variable.

```bash
# correct — no quotes on case expression or literal patterns
case ${1:-} in
  start)          start_service ;;
  stop)           stop_service ;;
  help|-h|--help) show_help ;;
  *.txt|*.md)     process_text "$1" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              die 2 "Unknown command ${1@Q}" ;;
esac

# wrong
case "${1:-}" in                     # unnecessary quotes on expression
  "start")                           # unnecessary quotes on pattern
```

Always include default case `*)`  to handle unexpected values. Align actions consistently for readability. Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`.

## BCS0503 Loops

**Tier:** core

```bash
# correct — for with arrays and globs
for file in "${files[@]}"; do
  process "$file"
done
for f in ./*.txt; do
  echo "$f"
done

# correct — while for argument parsing
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done

# correct — while for reading input
while IFS= read -r line; do
  process "$line"
done < "$input_file"

# correct — C-style loop
for ((i=0; i<10; i+=1)); do
  echo "$i"
done

# wrong
for f in $(ls *.txt); do             # never parse ls
for ((i=0; i<10; i++)); do           # never use i++
while (($# > 0)); do                 # use (($#)) instead
```

Declare local variables before loops, not inside:

```bash
# correct
local -- file
for file in ./*.txt; do process "$file"; done

# wrong
for file in ./*.txt; do local -- file; done
```

Use `while ((1))` for infinite loops — it is pure arithmetic evaluation with no command lookup or dispatch, making it the fastest construct (~14% faster than `while :`, ~21% faster than `while true` at 1M iterations).

```bash
# correct — arithmetic evaluation, fastest
while ((1)); do
  process_item || break
done

# acceptable — special builtin, POSIX-compatible
while :; do
  process_item || break
done

# wrong — unquoted variable expansion as command (fragile, dangerous)
running=true
while $running; do
  running=false
done

# wrong — unnecessary string comparison on constants
while [[ 1 == 1 ]]; do
  break
done
```

The flag-variable pattern (`while $running`) executes the variable content as a command — if it contains anything other than `true` or `false`, arbitrary code runs. Use arithmetic flags instead:

```bash
# correct — arithmetic flag, safe
local -i running=1
while ((running)); do
  # ...
  running=0
done
```

Use `break N` for nested loops (`break 2` exits two enclosing levels).

See also: [While Loops Reference](../benchmarks/while-loops-reference.md) — full benchmark data and analysis of `while ((1))` vs `while :` vs `while true`.

## BCS0504 Process Substitution

**Tier:** core

Never pipe to while loops — pipes create subshells where variable modifications are lost.

```bash
# correct — process substitution preserves variables
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep -c '' "$file")

# correct — readarray for collecting lines
readarray -t lines < <(find . -name '*.txt')

# correct — null-delimited for special filenames
while IFS= read -r -d '' file; do
  process "$file"
done < <(find /data -type f -print0)

# wrong — subshell loses count
grep '' "$file" | while read -r line; do
  count+=1
done
# count is still 0 here!
```

Use here-string `<<< "$var"` when input is already in a variable.

## BCS0505 Arithmetic Operations

**Tier:** style

Always declare integer variables with `declare -i` or `local -i` before arithmetic.

```bash
# correct
declare -i count=0
count+=1                             # increment

# correct — arithmetic conditional
((count > 10)) && warn 'High count'
((result = x + y))                   # no $ needed inside (())

# wrong — NEVER use any form of ++
((count++))
((++count))
count++
((count+=1))                         # use plain count+=1
```

Use `i+=1` for ALL increments. Integer division truncates: `((10 / 3))` equals 3.

## BCS0506 Floating-Point Operations

**Tier:** recommended

Bash only supports integer arithmetic. Use `bc -l` or `awk` for floating-point.

```bash
# correct
result=$(echo 'scale=2; 10 / 3' | bc -l)
result=$(awk -v a="$a" -v b="$b" 'BEGIN {printf "%.2f", a * b}')

# correct — float comparison
if (($(echo "$a > $b" | bc -l))); then
  echo 'a is greater'
fi

# wrong
[[ "$a" > "$b" ]]                    # string comparison, not numeric
```
