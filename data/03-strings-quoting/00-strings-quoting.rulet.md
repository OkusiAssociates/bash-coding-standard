# Strings & Quoting - Rulets
## Quoting Fundamentals
- [BCS0301] Use single quotes for static strings and double quotes only when variable expansion is needed: `info 'Processing...'` vs `info "Found $count files"`.
- [BCS0301] Nest single quotes inside double quotes to display literal values: `die 1 "Unknown option '$1'"`.
- [BCS0301] Single-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted but quoting is preferred for consistency: `STATUS='success'` not `STATUS=success`.
- [BCS0301] Always quote strings containing spaces, special characters (`@`, `*`, `$`), or empty values: `EMAIL='user@domain.com'`, `PATTERN='*.log'`, `VAR=''`.
- [BCS0301] Quote variable portions separately from literal paths for clarity: `"$PREFIX"/bin` and `"$SCRIPT_DIR"/data/"$filename"` rather than `"$PREFIX/bin"`.
## Command Substitution
- [BCS0302] Use double quotes when strings include command substitution: `VERSION="$(git describe --tags 2>/dev/null || echo 'unknown')"`.
- [BCS0302] Always quote command substitution results to prevent word splitting: `echo "$result"` not `echo $result`.
## Quoting in Conditionals
- [BCS0303] Always quote variables in conditionals: `[[ -f "$file" ]]` and `[[ "$name" == 'value' ]]`, never `[[ -f $file ]]`.
- [BCS0303] Use single quotes for static comparison values: `[[ "$action" == 'start' ]]` not `[[ "$action" == "start" ]]`.
- [BCS0303] Leave glob patterns unquoted for matching, quote for literal: `[[ "$filename" == *.txt ]]` matches globs, `[[ "$filename" == '*.txt' ]]` matches literal.
- [BCS0303] Leave regex pattern variables unquoted: `[[ "$input" =~ $pattern ]]` not `[[ "$input" =~ "$pattern" ]]`.
## Here Documents
- [BCS0304] Use unquoted delimiter `<<EOF` when variable expansion is needed; quote delimiter `<<'EOF'` for literal content with no expansion.
- [BCS0304] Quote here-doc delimiters for SQL, JSON, or any content where `$` should be literal: `cat <<'EOF'` prevents injection risks.
- [BCS0304] Use `<<-EOF` to strip leading tabs (not spaces) for indented heredocs within control structures.
## printf Patterns
- [BCS0305] Use single quotes for printf format strings and double quotes for variable arguments: `printf '%s: %d files\n' "$name" "$count"`.
- [BCS0305] Prefer `printf` over `echo -e` for consistent escape sequence handling across shells: `printf 'Line1\nLine2\n'` not `echo -e "Line1\nLine2"`.
- [BCS0305] Use `$'...'` syntax as alternative for escape sequences: `echo $'Line1\nLine2'`.
## Parameter Quoting with @Q
- [BCS0306] Use `${parameter@Q}` to safely display user input in error messages: `die 2 "Unknown option ${1@Q}"` prevents injection.
- [BCS0306] Use `@Q` for dry-run output to show exact commands: `printf -v quoted_cmd '%s ' "${cmd[@]@Q}"`.
- [BCS0306] Never use `@Q` for normal variable expansion or comparisons—only for display/logging of untrusted input.
## Anti-Patterns
- [BCS0307] Never use double quotes for static strings: `info 'Checking...'` not `info "Checking..."`.
- [BCS0307] Never leave variables unquoted: `rm "$temp_file"` not `rm $temp_file`.
- [BCS0307] Never use unnecessary braces around simple variables: `"$HOME"/bin` not `"${HOME}/bin"`. Braces only for `${var:-default}`, `${file##*/}`, `"${array[@]}"`, `"${var1}${var2}"`.
- [BCS0307] Always quote array expansions: `for item in "${items[@]}"` not `for item in ${items[@]}`.
- [BCS0307] Never echo unquoted glob patterns: `echo "$pattern"` not `echo $pattern` when `pattern='*.txt'`.
