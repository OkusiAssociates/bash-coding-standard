# Control Flow - Rulets
## Conditionals
- [BCS0501] Use `[[ ]]` for string and file tests, `(())` for arithmetic comparisons: `[[ -f "$file" ]]` for existence, `((count > 5))` for numbers.
- [BCS0501] Never use `[ ]` test syntax; `[[ ]]` provides pattern matching, `&&`/`||` operators, and no word splitting on variables.
- [BCS0501] Use arithmetic truthiness directly: `((count))` not `((count > 0))`, `((VERBOSE))` not `((VERBOSE == 1))`.
- [BCS0501] Pattern match with `[[ "$file" == *.txt ]]` for globs and `[[ "$input" =~ ^[0-9]+$ ]]` for regex.
- [BCS0501] Short-circuit evaluation: `[[ -f "$file" ]] && source "$file"` for conditional execution, `||` for fallback.
## Case Statements
- [BCS0502] Use `case` for multi-way branching on single variable pattern matching; use `if/elif` for multiple variables or complex conditions.
- [BCS0502] Do not quote the case expression: `case ${1:-} in` not `case "${1:-}" in`.
- [BCS0502] Do not quote literal patterns: `start)` not `"start)"`, but quote test variable: `case "$var" in`.
- [BCS0502] Always include default case `*)` to handle unexpected values explicitly.
- [BCS0502] Compact format for simple single-action cases with `;;` on same line; expanded format for multi-line logic with `;;` on separate line.
- [BCS0502] Align actions consistently at column 14-18 for readability.
- [BCS0502] Use alternation for multiple patterns: `-h|--help|help)` and wildcards: `*.txt|*.md)`.
- [BCS0502] Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`.
## Loops
- [BCS0503] Use for loops for arrays and globs: `for file in "${files[@]}"`, `for f in *.txt`.
- [BCS0503] Use while loops for reading input and argument parsing: `while (($#)); do case $1 in`.
- [BCS0503] Always quote array expansion in loops: `"${array[@]}"` to preserve element boundaries.
- [BCS0503] Never parse `ls` output; use glob patterns directly: `for f in *.txt` not `for f in $(ls *.txt)`.
- [BCS0503] Use `i+=1` for all increments in C-style loops: `for ((i=0; i<10; i+=1))`, never `i++` or `((i++))`.
- [BCS0503] Use `while ((1))` for infinite loops (fastest); `while :` for POSIX compatibility; avoid `while true` (15-22% slower).
- [BCS0503] Declare local variables before loops, not inside: `local -- file; for file in *.txt` not `for file in *.txt; do local -- file`.
- [BCS0503] Use `break N` for nested loops to specify level: `break 2` exits both inner and outer loop.
- [BCS0503] Use `while (($#))` not `while (($# > 0))` for argument parsing; non-zero is truthy in arithmetic context.
- [BCS0503] Always use `IFS= read -r` when reading input to preserve whitespace and backslashes.
## Pipes to While Loops
- [BCS0504] Never pipe to while loops; pipes create subshells where variable modifications are lost.
- [BCS0504] Use process substitution: `while read -r line; do count+=1; done < <(command)` to keep variables in current shell.
- [BCS0504] Use `readarray -t array < <(command)` when collecting lines into array; simpler and efficient.
- [BCS0504] Use here-string `<<< "$var"` when input is already in a variable.
- [BCS0504] Use `-d ''` with `read` and `-print0` with `find` for null-delimited input handling filenames with newlines.
## Arithmetic Operations
- [BCS0505,BCS0201] Always declare integer variables with `declare -i` or `local -i` before arithmetic operations.
- [BCS0505] Use `i+=1` for ALL increments; never use `((i++))`, `((++i))`, or `((i+=1))`.
- [BCS0505] Use `(())` for arithmetic conditionals: `((count > 10))` not `[[ "$count" -gt 10 ]]`.
- [BCS0505] No `$` needed inside `(())`: `((result = x + y))` not `((result = $x + $y))`.
- [BCS0505] Use arithmetic truthiness: `((count))` evaluates non-zero as true, zero as false.
- [BCS0505] Integer division truncates: `((10 / 3))` equals 3; use `bc` or `awk` for floating point.
## Floating-Point Operations
- [BCS0506] Bash only supports integer arithmetic; use `bc -l` or `awk` for floating-point calculations.
- [BCS0506] Use `bc` for precision: `result=$(echo 'scale=2; 10 / 3' | bc -l)`.
- [BCS0506] Use `awk` for inline float math: `result=$(awk -v a="$a" -v b="$b" 'BEGIN {printf "%.2f", a * b}')`.
- [BCS0506] Compare floats with `bc` or `awk`: `if (($(echo "$a > $b" | bc -l)))` not `[[ "$a" > "$b" ]]`.
- [BCS0506] Use `printf '%.2f'` to format floating-point output to specific decimal places.
