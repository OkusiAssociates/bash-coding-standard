# Arrays - Rulets
## Array Declaration
- [BCS0501] Always declare indexed arrays explicitly with `declare -a array=()` to signal array type, prevent scalar assignment, and enable type safety.
- [BCS0501] Use `local -a` for array declarations inside functions to prevent global pollution and control scope.
- [BCS0501] Initialize arrays with elements using parentheses syntax: `declare -a colors=('red' 'green' 'blue')`.
## Array Expansion and Iteration
- [BCS0501] Always quote array expansion with `"${array[@]}"` to preserve element boundaries and handle spaces safely; never use unquoted `${array[@]}`.
- [BCS0501] Use `"${array[@]}"` for iteration where each element becomes a separate word; never use `"${array[*]}"` which creates a single string.
- [BCS0501] Iterate over array values directly with `for item in "${array[@]}"` rather than iterating over indices with `"${!array[@]}"`.
## Array Modification
- [BCS0501] Append single elements with `array+=("value")` and multiple elements with `array+=("val1" "val2" "val3")`.
- [BCS0501] Get array length with `${#array[@]}`; check for empty arrays with `((${#array[@]} == 0))` or `((${#array[@]})) || default_action`.
- [BCS0501] Delete array elements with `unset 'array[i]'` (quoted to prevent glob expansion); clear entire array with `array=()`.
- [BCS0501] Access last element with `${array[-1]}` (Bash 4.3+) and extract slices with `"${array[@]:start:length}"`.
## Reading Into Arrays
- [BCS0501] Use `readarray -t array < <(command)` to read command output into arrays; `-t` removes trailing newlines and `< <()` avoids subshells.
- [BCS0501] Split delimited strings with `IFS=',' read -ra fields <<< "$csv_line"` but prefer arrays over IFS manipulation for list handling.
- [BCS0501] Read files into arrays with `readarray -t lines < file.txt` where each line becomes one array element.
## Safe List Handling with Arrays
- [BCS0502] Always use arrays to store lists of files, arguments, or any elements that may contain spaces, special characters, or wildcards; never use space/newline-separated strings.
- [BCS0502] Arrays preserve element boundaries without word splitting or glob expansion when expanded with `"${array[@]}"`, unlike string-based lists which break on spaces.
- [BCS0502] Build command arguments in arrays and execute with `"${array[@]}"` to safely handle arguments containing spaces, quotes, or special characters.
## Safe Command Construction
- [BCS0502] Construct complex commands by building argument arrays and conditionally adding elements: `cmd_args+=('-flag')` if condition met, then execute with `"${cmd_args[@]}"`.
- [BCS0502] Never concatenate strings for command arguments (`cmd="arg1 $arg2"`); use arrays (`cmd_args=('arg1' "$arg2")`) to avoid word splitting and eval dangers.
- [BCS0502] For SSH, rsync, find, tar, or any command with dynamic arguments, build the full command in an array: `ssh_args+=('-i' "$keyfile")` then `ssh "${ssh_args[@]}"`.
## File List Processing
- [BCS0502] Collect glob results directly into arrays with `files=(*.txt)` using `nullglob` to handle no-matches safely, then iterate with `for file in "${files[@]}"`.
- [BCS0502] Gather files from commands with null-delimited output: `while IFS= read -r -d '' file; do array+=("$file"); done < <(find ... -print0)`.
- [BCS0502] Check if glob matched anything by testing array length: `((${#files[@]} > 0))` or `[[ ${#files[@]} -eq 0 ]]`.
## Function Argument Passing
- [BCS0502] Pass arrays to functions with `function_name "${array[@]}"` and receive with `local -a items=("$@")` to preserve all elements as separate arguments.
- [BCS0502] Return arrays from functions by printing elements with `printf '%s\n' "${array[@]}"` and capturing with `readarray -t result < <(function_name)`.
## Anti-Patterns to Avoid
- [BCS0501,BCS0502] Never iterate with unquoted `${array[@]}` or use `for item in "$array"` (without `[@]`) which only processes the first element.
- [BCS0501] Never assign scalars to array variables; use array syntax even for single elements: `files=('item')` not `files='item'`.
- [BCS0502] Never use `eval` with constructed commands; build commands in arrays and execute directly with `"${array[@]}"`.
- [BCS0502] Never parse `ls` output into strings (`files=$(ls *.txt)`); use globs directly into arrays (`files=(*.txt)`).
- [BCS0502] Never manipulate IFS for iteration over lists; use arrays which handle element boundaries naturally without IFS changes.
## Array Operators Summary
- [BCS0501] Key array operators: `declare -a arr=()` (create), `arr+=("val")` (append), `${#arr[@]}` (length), `"${arr[@]}"` (all elements), `"${arr[i]}"` (single element), `"${arr[-1]}"` (last element), `"${arr[@]:start:len}"` (slice), `unset 'arr[i]'` (delete element), `"${!arr[@]}"` (indices).
## Special Cases
- [BCS0502] Empty arrays iterate safely (zero iterations) and can be passed to functions (zero arguments received); no special handling needed.
- [BCS0502] Arrays safely preserve elements containing spaces, quotes, dollars, wildcards, and newlines when expanded with `"${array[@]}"`.
- [BCS0502] Merge multiple arrays with `combined=("${arr1[@]}" "${arr2[@]}" "${arr3[@]}")` to concatenate all elements into a new array.
