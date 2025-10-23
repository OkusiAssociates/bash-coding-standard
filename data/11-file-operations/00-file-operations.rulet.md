# File Operations - Rulets
## Safe File Testing
- [BCS1101] Always quote variables in file tests with `[[ ]]`: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS1101] Use `[[ ]]` for file tests, never `[ ]` or `test` command.
- [BCS1101] Test file existence and readability before sourcing or processing: `[[ -f "$file" && -r "$file" ]] || die 3 "Cannot read: $file"`.
- [BCS1101] Use `-e` for any file type, `-f` for regular files only, `-d` for directories only.
- [BCS1101] Test file permissions before operations: `-r` for readable, `-w` for writable, `-x` for executable.
- [BCS1101] Use `-s` to test if file is non-empty (size > 0).
- [BCS1101] Compare file timestamps with `-nt` (newer than) or `-ot` (older than): `[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"`.
- [BCS1101] Check multiple conditions with `&&` or `||`: `[[ -f "$config" && -r "$config" ]] || die 3 "Config not found"`.
- [BCS1101] Always include filename in error messages for debugging: `die 2 "File not found: $file"`.
## Wildcard Expansion
- [BCS1102] Always use explicit path prefix with wildcards to prevent filenames starting with `-` being interpreted as flags: `rm ./*` not `rm *`.
- [BCS1102] Use explicit path in loops: `for file in ./*.txt; do` not `for file in *.txt; do`.
## Process Substitution
- [BCS1103] Use process substitution `<(command)` to provide command output as file-like input, eliminating temporary files and avoiding subshell issues.
- [BCS1103] Use input process substitution to compare command outputs: `diff <(sort file1) <(sort file2)`.
- [BCS1103] Use output process substitution `>(command)` to send data to commands as if writing to files: `tee >(wc -l) >(grep ERROR)`.
- [BCS1103] Avoid subshell variable scope issues in while loops with process substitution: `while read -r line; do ((count+=1)); done < <(cat file)` not `cat file | while read; do`.
- [BCS1103] Use `readarray` with process substitution to populate arrays from command output: `readarray -t users < <(getent passwd | cut -d: -f1)`.
- [BCS1103] Process files in parallel with tee and multiple output substitutions: `cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warn.txt) >/dev/null`.
- [BCS1103] Quote variables inside process substitution like normal: `diff <(sort "$file1") <(sort "$file2")`.
- [BCS1103] Never use process substitution for simple command output; use command substitution instead: `result=$(command)` not `result=$(cat <(command))`.
- [BCS1103] Never use process substitution for single file input; use direct redirection: `grep pattern < file` not `grep pattern < <(cat file)`.
- [BCS1103] Use here-string for variable expansion, not process substitution: `command <<< "$var"` not `command < <(echo "$var")`.
- [BCS1103] Assign process substitution to file descriptors for delayed reading: `exec 3< <(long_command)` then `read -r line <&3`.
## Here Documents
- [BCS1104] Use here documents for multi-line strings: `cat <<'EOF' ... EOF` for literal text, `cat <<EOF ... EOF` for variable expansion.
- [BCS1104] Quote the delimiter with single quotes to prevent variable expansion: `cat <<'EOF'` preserves `$var` literally.
- [BCS1104] Omit quotes on delimiter to enable variable expansion: `cat <<EOF` expands `$USER` to actual value.
## Input Redirection Performance
- [BCS1105] Use `$(< file)` instead of `$(cat file)` in command substitution for 100x+ speedup by eliminating process fork overhead.
- [BCS1105] Use `command < file` instead of `cat file | command` for 3-4x speedup in single-file operations.
- [BCS1105] Replace `cat` with `<` redirection in loops to eliminate cumulative fork overhead: `for f in *.txt; do data=$(< "$f"); done`.
- [BCS1105] Never use `< file` alone without a consuming command; it opens stdin but produces no output.
- [BCS1105] Use `cat` when concatenating multiple files; `< file1 file2` is invalid syntax.
- [BCS1105] Use `cat` when needing options like `-n` (line numbers), `-A` (show all), `-b` (number non-blank), `-s` (squeeze blank).
- [BCS1105] Process creation overhead dominates I/O time even for large files, making `< file` consistently faster regardless of file size.
