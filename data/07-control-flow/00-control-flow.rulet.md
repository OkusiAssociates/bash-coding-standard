# Control Flow - Rulets
## Conditionals
- [BCS0701] Always use `[[ ]]` for string and file tests, `(())` for arithmetic comparisons: `[[ -f "$file" ]]` for files, `((count > 0))` for numbers.
- [BCS0701] Never use `[ ]` for conditionals; use `[[ ]]` which handles unquoted variables safely, supports pattern matching with `==` and `=~`, and allows `&&`/`||` operators inside brackets.
- [BCS0701] Use short-circuit evaluation for concise conditionals: `[[ -f "$file" ]] && source "$file"` executes second command only if first succeeds, `((VERBOSE)) || return 0` executes second only if first fails.
- [BCS0701] Quote variables in `[[ ]]` conditionals for clarity even though not strictly required: `[[ "$var" == "value" ]]` not `[[ $var == "value" ]]`.
## Case Statements
- [BCS0702] Use case statements for multi-way branching based on pattern matching of a single variable; they're more readable and efficient than long if/elif chains.
- [BCS0702] Always quote the test variable but never quote literal patterns: `case "$filename" in` followed by `*.txt)` not `"*.txt")`.
- [BCS0702] Use compact format (all on one line with aligned `;;`) for simple single-action cases like argument parsing: `-v|--verbose) VERBOSE=1 ;;`
- [BCS0702] Use expanded format (action on next line, `;;` on separate line) for multi-line logic or complex operations requiring comments.
- [BCS0702] Always include a default `*)` case to handle unexpected values explicitly: `*) die 22 "Invalid option: $1" ;;`
- [BCS0702] Use alternation with `|` for multiple patterns: `-h|--help|help)` matches any of the three forms.
- [BCS0702] Enable extglob for advanced patterns: `shopt -s extglob` allows `@(pattern)` (exactly one), `+(pattern)` (one or more), `*(pattern)` (zero or more), `?(pattern)` (zero or one), `!(pattern)` (anything except).
- [BCS0702] Align actions at consistent column (14-18 characters) for visual clarity in compact format.
- [BCS0702] Never use case for testing multiple variables or complex conditional logic; use if/elif with `[[ ]]` instead.
## Loops
- [BCS0703] Use for loops for arrays, globs, and known ranges; while loops for reading input, argument parsing, and condition-based iteration; avoid until loops (prefer while with opposite condition).
- [BCS0703] Always quote array expansion in for loops: `for file in "${files[@]}"` preserves element boundaries including spaces.
- [BCS0703] Use C-style for loops for numeric iteration: `for ((i=0; i<10; i+=1))` with explicit increment `i+=1` never `i++`.
- [BCS0703] Never parse `ls` output; use glob patterns directly: `for file in *.txt` not `for file in $(ls *.txt)`.
- [BCS0703] Use `while IFS= read -r line; do` for line-by-line file processing; always include `IFS=` and `-r` flags.
- [BCS0703] Use `while (($#))` not `while (($# > 0))` for argument parsing loops; non-zero values are truthy in arithmetic context, making the comparison redundant.
- [BCS0703] Use `while ((1))` for infinite loops (fastest, recommended), `while :` for POSIX compatibility, never `while true` (15-22% slower due to command execution overhead).
- [BCS0703] Use `break` for early loop exit and `continue` for conditional skipping; specify break level for nested loops: `break 2` exits two levels.
- [BCS0703] Enable `nullglob` to handle empty glob matches safely: `shopt -s nullglob` makes `for file in *.txt` execute zero iterations if no matches.
- [BCS0703] Never iterate over unquoted strings with spaces; always use arrays: `files=('file 1.txt' 'file 2.txt')` then `for file in "${files[@]}"`.
## Pipes to While Loops
- [BCS0704] Never pipe commands to while loops; pipes create subshells where variable assignments don't persist outside the loop, causing silent failures.
- [BCS0704] Always use process substitution instead of pipes: `while read -r line; do ((count+=1)); done < <(command)` keeps loop in current shell so variables persist.
- [BCS0704] Use `readarray -t array < <(command)` when collecting lines into an array; it's cleaner and faster than manual while loop appending.
- [BCS0704] Use here-string `while read -r line; done <<< "$var"` when input is already in a variable.
- [BCS0704] For null-delimited input (filenames with newlines), use `while IFS= read -r -d '' file; done < <(find . -print0)` or `readarray -d '' -t files < <(find . -print0)`.
- [BCS0704] Remember pipe creates process tree: parent shell → subshell (while loop with modified variables) → subshell exits → changes discarded; process substitution avoids this.
## Arithmetic Operations
- [BCS0705] Always declare integer variables with `declare -i` for automatic arithmetic context, type safety, and clarity: `declare -i count=0 total=0`.
- [BCS0705] Use `i+=1` for increment (clearest and safest) or `((++i))` (pre-increment, safe); never use `((i++))` which returns old value and fails with `set -e` when i=0.
- [BCS0705] Use `(())` for arithmetic operations without `$` on variables: `((result = x * y + z))` not `((result = $x * $y + $z))`.
- [BCS0705] Use `$(())` for arithmetic in assignments or command arguments: `result=$((i * 2 + 5))` or `echo "$((count / total))".`
- [BCS0705] Always use `(())` for arithmetic conditionals, never `[[ ]]` with `-gt`/`-lt`: `((count > 10))` not `[[ "$count" -gt 10 ]]`.
- [BCS0705] Remember integer division truncates toward zero: `((result = 10 / 3))` gives 3 not 3.33; use `bc` or `awk` for floating point.
- [BCS0705] Never use `expr` command for arithmetic; it's slow, external, and error-prone: use `$(())` or `(())` instead.
