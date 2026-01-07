# File Operations - Rulets
## Section Overview
- [BCS0900] File operations section covers safe file testing, wildcard expansion, process substitution, here documents, and input redirection patterns to prevent common shell scripting pitfalls.
## Safe File Testing
- [BCS0901] Always quote variables in file tests and use `[[ ]]` syntax: `[[ -f "$file" ]]` not `[[ -f $file ]]` or `[ -f "$file" ]`.
- [BCS0901] Test files before use with fail-fast pattern: `[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"`.
- [BCS0901] Combine permission checks when sourcing files: `[[ -f "$file" && -r "$file" ]] || die 5 "Cannot read ${file@Q}"`.
- [BCS0901] Use `-s` to check for non-empty files: `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS0901] Use `-nt` and `-ot` for timestamp comparisons: `[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"`.
- [BCS0901] Validate directory writability with combined checks: `[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"`.
- [BCS0901] Include filenames in error messages for debugging: `die 3 "File not found ${file@Q}"`.
## Wildcard Expansion
- [BCS0902] Always use explicit path prefix for wildcard expansion to prevent filenames starting with `-` from being interpreted as flags: `rm -v ./*` not `rm -v *`.
- [BCS0902] Use `./*.txt` pattern in loops: `for file in ./*.txt; do process "$file"; done`.
## Process Substitution
- [BCS0903] Use process substitution `< <(command)` with while loops to avoid subshell variable scope issues: `while read -r line; do count+=1; done < <(cat file)`.
- [BCS0903] Use `readarray -t array < <(command)` to populate arrays from command output without subshell issues.
- [BCS0903] Use process substitution to compare command outputs without temp files: `diff <(sort file1) <(sort file2)`.
- [BCS0903] Use `>(command)` with tee for parallel output processing: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt)`.
- [BCS0903] Use null-delimited process substitution for filenames with special characters: `while IFS= read -r -d '' file; do ...; done < <(find /data -type f -print0)`.
- [BCS0903] Quote variables inside process substitution: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS0903] Never use pipe to while when you need to preserve variable values: use `< <(command)` instead of `command | while`.
## Here Documents
- [BCS0904] Use single-quoted delimiter `<<'EOT'` to prevent variable expansion in here documents.
- [BCS0904] Use unquoted delimiter `<<EOT` when variable expansion is needed in here documents.
## Input Redirection vs Cat
- [BCS0905] Use `$(< file)` instead of `$(cat file)` for command substitution—107x faster due to zero process fork.
- [BCS0905] Use `< file` redirection instead of `cat file |` for single-file input to commands—3-4x faster: `grep pattern < file.txt` not `cat file.txt | grep pattern`.
- [BCS0905] Optimize loops by using `$(< "$file")` instead of `$(cat "$file")`—fork overhead multiplies across iterations.
- [BCS0905] Use `cat` when concatenating multiple files, when using cat options (`-n`, `-A`, `-b`), or when multiple file arguments are needed.
- [BCS0905] Remember `< filename` alone produces no output—it requires a command to consume the redirected input.
