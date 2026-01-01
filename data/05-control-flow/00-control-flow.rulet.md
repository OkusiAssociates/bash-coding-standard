# Control Flow - Rulets
## Conditional Tests
- [BCS0501] Always use `[[ ]]` for string and file tests; use `(())` for arithmetic comparisons: `[[ -f "$file" ]]`, `((count > 5))`.
- [BCS0501] Use `[[ ]]` advantages over `[ ]`: no word splitting on variables, pattern matching with `==` and `=~`, logical operators `&&`/`||` work inside.
- [BCS0501] Quote variables in `[[ ]]` conditionals for clarity even though word splitting doesn't occur: `[[ "$var" == 'value' ]]`.
- [BCS0501] Use arithmetic truthiness directly instead of explicit comparisons: `((count))` not `((count > 0))`, `((VERBOSE))` not `((VERBOSE == 1))`.
- [BCS0501] Use short-circuit evaluation for concise conditionals: `[[ -f "$config" ]] && source "$config" ||:`, `((DEBUG)) && set -x ||:`.
- [BCS0501] Never use `[ ]` with `-a`/`-o` operators; use `[[ ]]` with `&&`/`||` instead.
- [BCS0501] Use `=~` for regex matching: `[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]`.
## Case Statements
- [BCS0502] Use `case` statements for multi-way branching on a single variable against multiple patterns; use `if/elif` for multiple variable tests or complex conditions.
- [BCS0502] Do not quote the case expression: `case ${1:-} in` not `case "${1:-}" in`.
- [BCS0502] Do not quote literal patterns: `start)` not `"start)"`.
- [BCS0502] Always include a default `*)` case to handle unexpected values explicitly.
- [BCS0502] Use compact format (single-line actions, aligned `;;`) for simple flag setting in argument parsing.
- [BCS0502] Use expanded format (action on next line, `;;` on separate line) for multi-line logic or complex operations.
- [BCS0502] Align actions consistently at column 14-18 for visual clarity.
- [BCS0502] Use alternation for multiple patterns: `-h|--help|help)` for OR matching.
- [BCS0502] Enable `extglob` for advanced patterns: `@(start|stop)`, `!(*.tmp)`, `+(pattern)`.
## Loops
- [BCS0503] Always quote array expansion in for loops: `for item in "${array[@]}"` not `for item in ${array[@]}`.
- [BCS0503] Use `for` loops for arrays, globs, and known ranges; use `while` loops for reading input and condition-based iteration.
- [BCS0503] Use `i+=1` for loop increments, never `i++` or `((i++))`: `for ((i=0; i<10; i+=1))`.
- [BCS0503] Use arithmetic truthiness in while conditions: `while (($#))` not `while (($# > 0))`.
- [BCS0503] Use `while ((1))` for infinite loops (fastest); use `while :` only for POSIX compatibility; avoid `while true` (15-22% slower).
- [BCS0503] Declare loop variables with `local` BEFORE the loop, not inside: `local -- file; for file in *.txt; do`.
- [BCS0503] Specify break level for nested loops: `break 2` to exit both loops.
- [BCS0503] Always use `IFS= read -r` when reading input in while loops.
- [BCS0503] Never parse `ls` output; use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
## Process Substitution
- [BCS0504] Never pipe to while loops; use process substitution instead: `while read -r line; done < <(command)` not `command | while read -r line; done`.
- [BCS0504] Piping to while creates a subshell where variable modifications are lost when the pipe ends.
- [BCS0504] Use `readarray -t array < <(command)` to collect lines into an array without subshell issues.
- [BCS0504] Use here-strings for single variables: `while read -r line; done <<< "$input"`.
- [BCS0504] Use `readarray -d '' -t files < <(find ... -print0)` for null-delimited input to handle filenames with newlines.
## Integer Arithmetic
- [BCS0505] Declare all integer variables with `declare -i` or `local -i` before use.
- [BCS0505] Use `i+=1` as the ONLY acceptable increment form; never use `((i++))`, `((++i))`, or `((i+=1))`.
- [BCS0505] The `((i++))` form returns the original value and fails with `set -e` when `i=0`.
- [BCS0505] Use `(())` for arithmetic conditionals, not `[[ ... -eq ... ]]`: `((exit_code == 0))` not `[[ "$exit_code" -eq 0 ]]`.
- [BCS0505] No `$` prefix needed for variables inside `(())`: `((result = a + b))` not `((result = $a + $b))`.
- [BCS0505] Use `$(())` for arithmetic in assignments or command arguments: `result=$((x * y))`.
- [BCS0505] Integer division truncates toward zero: `((10 / 3))` equals 3, not 3.333.
## Floating-Point Operations
- [BCS0506] Bash only supports integer arithmetic natively; use `bc` or `awk` for floating-point calculations.
- [BCS0506] Use `bc -l` for arbitrary precision: `result=$(echo '3.14 * 2.5' | bc -l)`.
- [BCS0506] Use `awk` for inline floating-point with formatting: `result=$(awk -v w="$width" -v h="$height" 'BEGIN {printf "%.2f", w * h}')`.
- [BCS0506] Compare floats with bc or awk, never string comparison: `if (($(echo "$a > $b" | bc -l)))` not `[[ "$a" > "$b" ]]`.
