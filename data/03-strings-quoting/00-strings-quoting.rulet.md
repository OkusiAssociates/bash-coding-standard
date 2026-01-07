# Strings & Quoting - Rulets
## Quoting Fundamentals
- [BCS0301] Use single quotes for static strings and double quotes when variable expansion is needed: `info 'Processing...'` vs `info "Found $count files"`.
- [BCS0301] Nest single quotes inside double quotes to display literal values: `die 1 "Unknown option '$1'"`.
- [BCS0301] One-word alphanumeric literals (`a-zA-Z0-9_-./`) may be unquoted: `STATUS=success` or `[[ "$level" == INFO ]]`.
- [BCS0301] Always quote strings containing spaces, special characters, `$`, quotes, backslashes, or empty strings: `EMAIL='user@domain.com'`, `VAR=''`.
- [BCS0301] Quote variable portions separately from literal path components for clarity: `"$PREFIX"/bin` and `"$SCRIPT_DIR"/data/"$filename"`.
## Command Substitution
- [BCS0302] Use double quotes when strings include command substitution: `echo "Current time: $(date +%T)"`.
- [BCS0302] Omit quotes around simple variable assignments: `VERSION=$(git describe --tags)` not `VERSION="$(git describe --tags)"`.
- [BCS0302] Use double quotes when concatenating command substitution with other values: `VERSION="$(git describe)".beta`.
- [BCS0302] Always quote command substitution results when used: `echo "$result"` never `echo $result`.
## Quoting in Conditionals
- [BCS0303] Always quote variables in conditionals: `[[ -f "$file" ]]` never `[[ -f $file ]]`.
- [BCS0303] Leave glob patterns unquoted for matching: `[[ "$filename" == *.txt ]]` matches globs, `[[ "$filename" == '*.txt' ]]` matches literal.
- [BCS0303] Leave regex pattern variables unquoted: `[[ "$input" =~ $pattern ]]` not `[[ "$input" =~ "$pattern" ]]`.
- [BCS0303] Use single quotes or no quotes for static comparison values: `[[ "$mode" == 'production' ]]` or `[[ "$mode" == production ]]`.
## Here Documents
- [BCS0304] Use unquoted delimiter `<<EOF` when variable expansion is needed; use quoted delimiter `<<'EOF'` for literal content.
- [BCS0304] Quote here-doc delimiters for JSON, SQL, or any content with `$` characters that should not expand: `cat <<'EOF'`.
- [BCS0304] Use `<<-EOF` to strip leading tabs (not spaces) for indented heredocs within control structures.
## printf Patterns
- [BCS0305] Use single quotes for printf format strings and double quotes for variable arguments: `printf '%s: %d files\n' "$name" "$count"`.
- [BCS0305] Prefer printf over `echo -e` for consistent escape sequence handling: `printf 'Line1\nLine2\n'` not `echo -e "Line1\nLine2"`.
- [BCS0305] Use `$'...'` syntax as alternative for escape sequences in echo: `echo $'Line1\nLine2'`.
## Parameter Quoting with @Q
- [BCS0306] Use `${parameter@Q}` to safely display user input in error messages: `die 2 "Unknown option ${1@Q}"`.
- [BCS0306] Use `${var@Q}` for dry-run output to show exact command that would execute: `info "[DRY-RUN] ${cmd@Q}"`.
- [BCS0306] Never use `@Q` for normal variable expansion or comparisons; use standard quoting: `process "$file"`, `[[ "$var" == "$value" ]]`.
## Anti-Patterns
- [BCS0307] Never use double quotes for static strings: `info 'Checking...'` not `info "Checking..."`.
- [BCS0307] Never leave variables unquoted: `echo "$result"` not `echo $result`, `rm "$temp_file"` not `rm $temp_file`.
- [BCS0307] Avoid unnecessary braces around variables: `echo "$HOME"/bin` not `echo "${HOME}/bin"`.
- [BCS0307] Use braces only when required: `${var:-default}`, `${file##*/}`, `${array[@]}`, `${var1}${var2}`.
- [BCS0307] Always quote array expansions: `for item in "${items[@]}"` never `for item in ${items[@]}`.
- [BCS0307,BCS0304] Quote here-doc delimiters to prevent SQL injection and unintended variable expansion in templates.
