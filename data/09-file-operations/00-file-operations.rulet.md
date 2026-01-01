# File Operations - Rulets
## Section Overview
- [BCS0900] File operations require safe handling practices including proper file testing operators (`-e`, `-f`, `-d`, `-r`, `-w`, `-x`), explicit path wildcards (`rm ./*` not `rm *`), process substitution (`< <(command)`) for avoiding subshell issues, and here documents for multi-line input.
## File Testing
- [BCS0901] Always quote variables and use `[[ ]]` for file tests: `[[ -f "$file" ]] && source "$file"`.
- [BCS0901] Test file existence before use and fail fast: `[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"`.
- [BCS0901] Combine readable and existence checks before sourcing: `[[ -f "$config" && -r "$config" ]] || die 3 "Config not found or not readable"`.
- [BCS0901] Use `-s` to check for non-empty files: `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS0901] Use `-nt` and `-ot` for file timestamp comparisons: `[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"`.
- [BCS0901] Use `-ef` to check if two paths reference the same file (same device and inode).
- [BCS0901] Never use `[ ]` or `test` command; always use `[[ ]]` for robust file testing.
- [BCS0901] Always catch mkdir failures: `[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: ${dir@Q}"`.
- [BCS0901] Include filename in error messages using `${var@Q}` for proper quoting in output.
## Wildcard Expansion
- [BCS0902] Always use explicit path with wildcards to prevent flag interpretation: `rm -v ./*` not `rm -v *`.
- [BCS0902] Use explicit path in for loops: `for file in ./*.txt; do process "$file"; done`.
## Process Substitution
- [BCS0903] Use `<(command)` to treat command output as a file-like input: `diff <(sort file1) <(sort file2)`.
- [BCS0903] Use `>(command)` to send output to a command as if writing to a file: `tee >(wc -l) >(grep ERROR)`.
- [BCS0903] Prefer process substitution over temp files to eliminate file management overhead.
- [BCS0903] Use `< <(command)` with while loops to avoid subshell variable scope issues: `while read -r line; do count+=1; done < <(cat file)`.
- [BCS0903] Use `readarray -t array < <(command)` to populate arrays from command output without subshell issues.
- [BCS0903] Handle special characters with null-delimited process substitution: `readarray -d '' -t files < <(find /data -type f -print0)`.
- [BCS0903] Never pipe to while loop when you need variable modifications preserved; use process substitution instead.
- [BCS0903] Use parallel processing with tee and multiple process substitutions: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) > /dev/null`.
- [BCS0903] Always quote variables inside process substitution: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS0903] For simple variable input, prefer here-strings over process substitution: `command <<< "$variable"` not `command < <(echo "$variable")`.
- [BCS0903] For simple command output to variable, use command substitution: `result=$(command)` not `result=$(cat <(command))`.
## Here Documents
- [BCS0904] Use `<<'EOF'` (single-quoted delimiter) to prevent variable expansion in here-documents.
- [BCS0904] Use `<<EOF` (unquoted delimiter) when variable expansion is needed in here-documents.
## Input Redirection Performance
- [BCS0905] Use `$(< file)` instead of `$(cat file)` for command substitution (100x+ speedup): `content=$(< file.txt)`.
- [BCS0905] Use `cmd < file` instead of `cat file | cmd` for single file input (3-4x speedup): `grep pattern < file.txt`.
- [BCS0905] In loops, prefer `$(< "$file")` over `$(cat "$file")` to avoid fork overhead multiplying per iteration.
- [BCS0905] Use `cat` when concatenating multiple files, using cat options (`-n`, `-b`, `-A`), or when `< file` alone produces no output.
- [BCS0905] Remember `< filename` alone does nothing; it only opens stdin without a command to consume it.
- [BCS0905] The exception is command substitution where bash reads file directly: `content=$(< file)` works standalone.
