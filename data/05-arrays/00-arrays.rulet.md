# Arrays - Rulets
## Array Declaration
- [BCS0501] Always declare arrays explicitly with `declare -a array=()` for indexed arrays to signal intent, ensure type safety, and prevent accidental scalar assignment.
- [BCS0501] Use `local -a array=()` for arrays within functions to prevent global scope pollution and maintain proper variable scoping.
- [BCS0501] Initialize arrays with elements using parentheses: `declare -a colors=('red' 'green' 'blue')` for immediate population.
## Array Expansion and Iteration
- [BCS0501] Always quote array expansion with `"${array[@]}"` to preserve element boundaries and prevent word splitting on spaces or special characters.
- [BCS0501] Never use unquoted array expansion `${array[@]}` or `"$array"` without `[@]`; the former breaks with spaces, the latter only processes the first element.
- [BCS0501] Use `"${array[@]}"` not `"${array[*]}"` for iteration; `[@]` expands each element as a separate word, `[*]` treats all elements as a single string.
## Array Modification
- [BCS0501] Append elements with `+=` operator: `array+=("element")` for single items, `array+=("item1" "item2")` for multiple items, or `array+=("${other_array[@]}")` to merge arrays.
- [BCS0501] Get array length with `${#array[@]}`; check if empty with `((${#array[@]} == 0))` or set default if empty with `((${#array[@]})) || array=('default')`.
- [BCS0501] Delete array elements with `unset 'array[index]'` (always quote the subscript), clear entire array with `array=()`, or access last element with `${array[-1]}` (Bash 4.3+).
## Reading Data into Arrays
- [BCS0501] Use `readarray -t array < <(command)` or `mapfile -t array < <(command)` to capture command output into arrays; `-t` removes trailing newlines, `< <()` avoids subshell issues.
- [BCS0501] Split strings into arrays with `IFS='delimiter' read -ra array <<< "$string"` for delimiter-separated values like CSV or PATH components.
- [BCS0501] Read files into arrays with `readarray -t lines < file.txt` to process one line per element, preserving spaces and special characters.
## Safe List Handling
- [BCS0502] Always use arrays to store lists of files, command arguments, or any collection where elements may contain spaces, special characters, or wildcards; string-based lists inevitably fail with edge cases.
- [BCS0502] Never use string concatenation for lists like `files="file1 file2 file3"`; word splitting breaks iteration and command arguments when elements contain spaces.
- [BCS0502] Build commands dynamically with arrays: `cmd_args=('-o' 'output.txt' '--verbose')` then execute with `"${cmd_args[@]}"` to safely handle arguments with spaces or special characters.
## Command Argument Construction
- [BCS0502] Construct commands with conditional arguments using arrays: initialize with `cmd=('base' 'args')`, add conditionally with `((flag)) && cmd+=('--option')`, execute with `"${cmd[@]}"`.
- [BCS0502] Build complex commands like `find` or `rsync` in arrays, adding options conditionally: `find_args=("$dir" '-type' 'f')`, then `[[ -n "$pattern" ]] && find_args+=('-name' "$pattern")`, finally `find "${find_args[@]}"`.
- [BCS0502] Never use `eval` or string concatenation for command building; arrays eliminate quoting issues and security risks associated with string-based command construction.
## Array Patterns
- [BCS0501] Collect dynamic arguments during parsing: `declare -a files=()`, then `files+=("$arg")` in parse loop, finally iterate with `for file in "${files[@]}"`.
- [BCS0501] Check array membership by iterating elements: `for element; do [[ "$element" == "$search" ]] && return 0; done; return 1` in a function receiving array as arguments.
- [BCS0501] Avoid iterating with indices `for i in "${!array[@]}"; do echo "${array[$i]}"; done` when you can iterate values directly with `for value in "${array[@]}"`.
## Glob and File Collection
- [BCS0502] Collect glob results directly into arrays: `files=(*.txt)` safely captures matching files; always use `shopt -s nullglob` to handle zero matches gracefully.
- [BCS0502] Never parse `ls` output into strings with `files=$(ls *.txt)`; use glob into array `files=(*.txt)` or `readarray -t files < <(find ...)` for complex searches.
- [BCS0502] Use `while IFS= read -r -d '' file; do array+=("$file"); done < <(find ... -print0)` for null-delimited file collection when filenames may contain newlines.
## Passing Arrays to Functions
- [BCS0502] Pass arrays to functions with `func "${array[@]}"` and receive with `local -a items=("$@")` to preserve all elements as separate arguments.
- [BCS0502] Return arrays from functions by printing elements with `printf '%s\n' "${array[@]}"` and capture with `readarray -t result < <(func)`.
- [BCS0502] Never pass arrays as single-quoted strings; always expand with `"${array[@]}"` so each element becomes a separate function argument.
## Array Anti-Patterns
- [BCS0501,BCS0502] Never use unquoted expansion `for item in ${array[@]}` or single-element reference `for item in "$array"`; both break safe iteration and element preservation.
- [BCS0502] Avoid IFS manipulation for splitting `IFS=','; for item in $string; do ...` when you can use `IFS=',' read -ra array <<< "$string"` followed by array iteration.
- [BCS0502] Never build file lists with string concatenation or command substitution into strings; word splitting destroys filenames with spaces and makes commands fail.
## Advanced Array Operations
- [BCS0502] Merge multiple arrays with `combined=("${arr1[@]}" "${arr2[@]}" "${arr3[@]}")` to create a new array containing all elements from source arrays.
- [BCS0502] Extract array slices with `"${array[@]:start:length}"` syntax: `"${array[@]:2:4}"` returns 4 elements starting at index 2.
- [BCS0502] Handle empty arrays safely; `for item in "${empty[@]}"` performs zero iterations without errors, and empty arrays pass zero arguments to functions.
## Key Principles
- [BCS0501,BCS0502] Arrays are the only safe way to handle lists in Bash; they preserve element boundaries, prevent word splitting, and eliminate glob expansion issues that plague string-based lists.
- [BCS0502] Always quote array expansion as `"${array[@]}"` never `${array[@]}` or `"${array[*]}"` to ensure each element is treated as a separate, intact word during iteration or argument passing.
- [BCS0502] Use arrays for all collections: file lists, command arguments, options, configuration values; string-based lists will fail with spaces, quotes, wildcards, or special characters.
