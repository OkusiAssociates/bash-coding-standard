# Section 5: Control Flow

## BCS0500 Section Overview

Use `[[ ]]` for string and file tests, `(())` for arithmetic. Never use `[ ]`. This section covers conditionals, case statements, loops, arithmetic, and floating-point operations.

## BCS0501 Conditionals

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

Use `while ((1))` for infinite loops (fastest). Use `break N` for nested loops.

## BCS0504 Process Substitution

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
