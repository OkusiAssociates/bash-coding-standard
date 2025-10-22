# File Operations - Rulets

## File Testing

- [BCS1101] Always quote variables in file tests and use `[[ ]]` not `[ ]` or `test`: `[[ -f "$file" ]]` not `[[ -f $file ]]` or `[ -f "$file" ]`.
- [BCS1101] Use `-f` for regular files, `-d` for directories, `-e` for any file type existence check.
- [BCS1101] Validate file prerequisites before use: `[[ -f "$config" ]] || die 3 "Config not found: $config"` then `[[ -r "$config" ]] || die 5 "Cannot read: $config"`.
- [BCS1101] Use `-r` to test readability, `-w` for writability, `-x` for executability before attempting operations.
- [BCS1101] Test file emptiness with `-s` (true if size > 0): `[[ -s "$logfile" ]] || warn 'Log file is empty'`.
- [BCS1101] Compare file modification times with `-nt` (newer than) or `-ot` (older than): `[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"`.
- [BCS1101] Combine file tests with `&&` or `||` in single conditional: `[[ -f "$file" && -r "$file" && -s "$file" ]]`.
- [BCS1101] Always include filename in error messages for debugging: `die 2 "File not found: $file"` not `die 2 "File not found"`.

## Wildcard Expansion Safety

- [BCS1102] Always use explicit path prefix for wildcard expansion to prevent filenames starting with `-` from being interpreted as flags: `rm -v ./*` not `rm -v *`.
- [BCS1102] Use explicit path in loops: `for file in ./*.txt; do` not `for file in *.txt; do`.

## Process Substitution

- [BCS1103] Use `<(command)` to provide command output as file-like input, eliminating temporary files and avoiding subshell variable scope issues.
- [BCS1103] Use `>(command)` to redirect output to a command as if writing to a file: `tee >(wc -l) >(grep ERROR) > output.txt`.
- [BCS1103] Prefer process substitution over pipes to while loops to preserve variable scope: `while read -r line; do ((count+=1)); done < <(command)` not `command | while read -r line; do`.
- [BCS1103] Use `readarray` with process substitution for populating arrays: `readarray -t users < <(cut -d: -f1 /etc/passwd)`.
- [BCS1103] Use process substitution with `diff` to compare command outputs without temporary files: `diff <(sort file1) <(sort file2)`.
- [BCS1103] Use `tee` with multiple output process substitutions for parallel processing: `cat log | tee >(grep ERROR > errors.log) >(grep WARN > warnings.log) > all.log`.
- [BCS1103] Quote variables inside process substitution like normal: `<(sort "$file1")` not `<(sort $file1)`.
- [BCS1103] Use null-delimited input with process substitution for safe filename handling: `while IFS= read -r -d '' file; do ...; done < <(find /data -print0)`.
- [BCS1103] Never use process substitution where simple command substitution suffices: use `result=$(command)` not `result=$(cat <(command))`.

## Here Documents

- [BCS1104] Use here documents for multi-line strings or input with appropriate quoting.
- [BCS1104] Use `<<'EOF'` (single quotes) to prevent variable expansion in here documents: `cat <<'EOF'\nLiteral $VAR\nEOF`.
- [BCS1104] Use `<<EOF` (no quotes) to enable variable expansion: `cat <<EOF\nExpanded: $VAR\nEOF`.

## Input Redirection Optimization

- [BCS1105] Use `< filename` instead of `cat filename` for single-file input to commands for 3-4x performance improvement: `grep pattern < file` not `cat file | grep pattern`.
- [BCS1105] Use `content=$(< file)` instead of `content=$(cat file)` in command substitution for 100x+ speedup.
- [BCS1105] Optimize loops by replacing `$(cat "$file")` with `$(< "$file")` to eliminate process fork overhead in every iteration.
- [BCS1105] Use `cat` when concatenating multiple files (redirection cannot combine multiple sources): `cat file1 file2 file3` not `< file1 file2 file3`.
- [BCS1105] Use `cat` when needing cat-specific options like `-n` (line numbers), `-A` (show all), `-E` (show ends), `-T` (show tabs), `-s` (squeeze blank).
- [BCS1105] Never use `< filename` alone without a command to consume input; it opens the file descriptor but produces no output.

## Combined Patterns

- [BCS1101,BCS1102] Validate before glob operations: `[[ -d "$dir" ]] || die 1 "Directory not found: $dir"` then `for file in "$dir"/*.txt; do`.
- [BCS1103,BCS1105] Use process substitution with redirection for maximum efficiency: `while read -r line; do ...; done < <(< "$file" grep pattern)`.
- [BCS1101,BCS1103] Test file existence before using in process substitution: `[[ -f "$config" ]] || die 3 "Not found: $config"` then `diff <(sort "$config") <(sort "$backup")`.
