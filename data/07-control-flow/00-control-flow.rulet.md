# Control Flow - Rulets

## Conditionals

- [BCS0701] Always use `[[ ]]` for string and file tests, `(())` for arithmetic tests: `[[ -f "$file" ]]` for files, `((count > 0))` for numbers.
- [BCS0701] Never use `[ ]` (old test syntax) - it requires quotes, doesn't support pattern matching, and lacks logical operators inside brackets.
- [BCS0701] Quote variables in `[[ ]]` tests even though not strictly required: `[[ "$var" == "value" ]]` for clarity and consistency.
- [BCS0701] Use pattern matching in `[[ ]]` with `==` for globs and `=~` for regex: `[[ "$file" == *.txt ]]` or `[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]`.
- [BCS0701] Use short-circuit evaluation for concise conditionals: `[[ -f "$file" ]] && source "$file"` or `((VERBOSE)) || return 0`.
- [BCS0701] Never use `-a` and `-o` operators inside `[ ]` - they are deprecated and fragile; use `[[ ]]` with `&&` and `||` instead.

## Case Statements

- [BCS0702] Use case statements for multi-way branching based on pattern matching a single value, not for testing multiple variables or complex conditions.
- [BCS0702] Choose compact format (single-line actions with aligned `;;`) for simple cases like argument parsing; use expanded format (multi-line actions with `;;` on separate line) for complex logic.
- [BCS0702] Always quote the test variable but don't quote literal patterns: `case "$filename" in` not `case $filename in`, and `*.txt)` not `"*.txt")`.
- [BCS0702] Always include default case `*)` to handle unexpected values explicitly and prevent silent failures.
- [BCS0702] Use alternation with `|` for multiple patterns: `-h|--help|help)` action `;;` instead of separate cases.
- [BCS0702] Enable `shopt -s extglob` for advanced patterns: `@(start|stop|restart)` for exactly one, `!(*.tmp|*.bak)` for exclusion, `+([0-9])` for one or more digits.
- [BCS0702] Align actions consistently at same column (typically 14-18 characters) in compact format for visual clarity.
- [BCS0702] Never attempt fall-through patterns - Bash doesn't support them; use explicit alternation: `200|201|204)` not separate cases expecting fall-through.
- [BCS0702] Use case for pattern matching (file extensions, option flags, action routing), use if/elif for complex conditions involving multiple variables or ranges.

## Loops

- [BCS0703] Always quote arrays in for loops: `for item in "${array[@]}"` not `for item in ${array[@]}` to preserve element boundaries with spaces.
- [BCS0703] Use for loops for arrays, globs, and known ranges; use while loops for reading input, argument parsing, and condition-based iteration.
- [BCS0703] Enable `shopt -s nullglob` before glob loops to handle zero matches gracefully: `for file in *.txt` expands to nothing if no matches instead of literal `*.txt`.
- [BCS0703] Use C-style for loops for numeric iteration: `for ((i=1; i<=10; i+=1))` not `for i in $(seq 1 10)` to avoid external commands.
- [BCS0703] Read files line-by-line with `while IFS= read -r line; do ... done < "$file"` preserving backslashes and avoiding word splitting.
- [BCS0703] Use `break N` to exit N levels of nested loops explicitly: `break 2` breaks both inner and outer loop for clarity.
- [BCS0703] Use `continue` to skip remaining loop body and proceed to next iteration for early conditional filtering.
- [BCS0703] Use `while ((1))` for infinite loops (fastest option, 15-22% faster than `while true`), or `while :` for POSIX compatibility.
- [BCS0703] Never parse `ls` output - use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
- [BCS0703] Use process substitution for null-delimited input: `while IFS= read -r -d '' file; do ... done < <(find . -print0)` to handle filenames with newlines.
- [BCS0703] Avoid redundant comparisons in arithmetic context: use `while (($#))` not `while (($# > 0))` since non-zero is truthy.

## Pipes to While Loops

- [BCS0704] Never pipe commands to while loops - pipes create subshells where variable assignments don't persist outside the loop; use process substitution `< <(command)` instead.
- [BCS0704] Use `readarray -t array < <(command)` when collecting command output into array - simpler and more efficient than while loop.
- [BCS0704] Use here-string `<<< "$variable"` when input is already in a variable: `while read -r line; done <<< "$input"`.
- [BCS0704] The pipe subshell issue is silent - counters stay at 0, arrays stay empty, flags stay unset - no error messages, script continues with wrong values.
- [BCS0704] With `set -e`, command failures in process substitution are detected properly: `< <(failing_command)` exits script, but pipe may not.

## Arithmetic Operations

- [BCS0705] Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity: `declare -i count=0 total max_retries=3`.
- [BCS0705] Use `i+=1` or `((i+=1))` for increment; never use `((i++))` - it returns the original value and fails with `set -e` when i=0.
- [BCS0705] Use `((++i))` only if you need the incremented value returned (pre-increment); `((i+=1))` always returns 0 (success) regardless of value.
- [BCS0705] Use `(())` for arithmetic assignments without $ on variables inside: `((result = x * y + z))` not `((result = $x * $y + $z))`.
- [BCS0705] Use `(())` for arithmetic conditionals not `[[ ]]` with `-gt/-lt`: `((count > 10))` not `[[ "$count" -gt 10 ]]` for clarity and conciseness.
- [BCS0705] Never use `expr` command for arithmetic - it's slow and external; use `$(())` or `(())` instead: `result=$((i + j))`.
- [BCS0705] Remember Bash only does integer arithmetic - division truncates: `((result = 10 / 3))` gives 3 not 3.333; use `bc` or `awk` for floating-point.
- [BCS0705] Use ternary operator in arithmetic for conditional assignment: `((max = a > b ? a : b))` (Bash 5.2+).
