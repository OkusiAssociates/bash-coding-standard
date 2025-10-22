# Quoting & String Literals - Rulets
## Core Principle
- [BCS0400] Use single quotes (`'...'`) for static string literals; use double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.
## Static Strings and Constants
- [BCS0401] Always use single quotes for string literals that contain no variables: `info 'Checking prerequisites...'` not `info "Checking prerequisites..."`.
- [BCS0401] Use single quotes for SQL queries, regex patterns, and shell commands stored as strings to prevent accidental variable expansion: `regex='^\$[0-9]+\.[0-9]{2}$'`.
- [BCS0401] Single quotes require no escaping of special characters like `$`, `` ` ``, `\`, `!` - what you see is what you get.
## One-Word Literals Exception
- [BCS0402] Literal one-word values containing only alphanumeric, underscore, hyphen, dot, or slash may be left unquoted in assignments and conditionals, but quoting is more defensive: `VAR=value` or `VAR='value'`.
- [BCS0402] Never leave unquoted: values with spaces, wildcards (`*.txt`), special characters (`@`, `$`), empty strings, values starting with hyphen in conditionals, or any value with `()`, quotes, or backslashes.
- [BCS0402] Always quote variables even when concatenating with literals: `FILE="$basename.txt"` not `FILE=$basename.txt`.
## Strings with Variables
- [BCS0403] Use double quotes when strings contain variables that need expansion: `info "Installing to $PREFIX/bin"` or `echo "Processed $count files"`.
- [BCS0403] Combine double quotes with nested single quotes to protect literal quotes: `die 2 "Unknown option '$1'"`.
## Command Substitution
- [BCS0405] Use double quotes when including command substitution: `echo "Current time: $(date +%T)"` or `VERSION="$(git describe --tags)"`.
## Variables in Conditionals
- [BCS0406] Always quote variables in test expressions to prevent word splitting and glob expansion: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS0406] Quote variables in all file tests (`-f`, `-d`, `-r`, `-w`, `-x`), string comparisons, and integer comparisons: `[[ "$count" -eq 0 ]]`.
- [BCS0406] Static comparison values follow normal quoting rules: single quotes for multi-word literals (`[[ "$msg" == 'hello world' ]]`), optional quotes for one-word literals (`[[ "$action" == start ]]` or `[[ "$action" == 'start' ]]`).
- [BCS0406] For glob pattern matching, quote the variable but leave the pattern unquoted: `[[ "$filename" == *.txt ]]`; for literal matching, quote both: `[[ "$filename" == '*.txt' ]]`.
- [BCS0406] For regex matching with `=~`, quote the variable but leave the pattern unquoted: `[[ "$email" =~ ^[a-z]+@[a-z]+$ ]]` or store pattern in variable: `[[ "$input" =~ $pattern ]]`.
## Array Expansions
- [BCS0407] Always quote array expansions: `"${array[@]}"` for separate elements, `"${array[*]}"` for single concatenated string.
- [BCS0407] Use `"${array[@]}"` for iteration, function arguments, command arguments, and array copying: `for item in "${array[@]}"`.
- [BCS0407] Use `"${array[*]}"` for display, logging, or creating CSV with custom IFS: `IFS=','; csv="${array[*]}"`.
- [BCS0407] Unquoted array expansions undergo word splitting and lose empty elements; always quote to preserve element boundaries: `copy=("${original[@]}")` not `copy=(${original[@]})`.
## Here Documents
- [BCS0408] Use single quotes on delimiter for literal content (no expansion): `cat <<'EOF'` keeps `$VAR` and `$(command)` literal.
- [BCS0408] Use unquoted delimiter for variable expansion: `cat <<EOF` expands `$VAR` and `$(command)`.
## Echo and Printf
- [BCS0409] Use single quotes for static strings in echo/printf: `echo 'Installation complete'` not `echo "Installation complete"`.
- [BCS0409] Use double quotes when echo/printf contains variables: `echo "Installing to $PREFIX/bin"` or `printf 'Found %d files in %s\n' "$count" "$dir"`.
## Anti-Patterns
- [BCS0411] Never use double quotes for static strings with no variables: `info "Starting process..."` is wrong, use `info 'Starting process...'`.
- [BCS0411] Never leave variables unquoted in conditionals, assignments, or commands: `[[ -f $file ]]`, `rm $file`, `echo $result` are all wrong.
- [BCS0411] Never use braces when not required: `echo "${HOME}/bin"` should be `echo "$HOME/bin"`; braces only needed for `${var##pattern}`, `${var:-default}`, `${array[@]}`, `${var1}${var2}`.
- [BCS0411] Never mix quote styles inconsistently: pick single quotes for all static strings, double quotes for all strings with variables.
- [BCS0411] Never use unquoted glob patterns in variables: `pattern='*.txt'; echo $pattern` expands to all .txt files; use `echo "$pattern"` to preserve literal.
- [BCS0411] Never use quoted delimiter when variables needed in heredoc: `cat <<"EOF"` with `$VAR` inside prevents expansion; use `cat <<EOF`.
## Utility Functions
- [BCS0412] Use parameter expansion for string trimming: `v="${v#"${v%%[![:blank:]]*}"}"; v="${v%"${v##*[![:blank:]]}"}"` removes leading/trailing whitespace.
- [BCS0413] Display declared variables without the declare statement prefix: `decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }`.
- [BCS0414] Create pluralization helper that returns 's' for non-singular counts: `s() { (( ${1:-1} == 1 )) || echo -n 's'; }` for use like `echo "$count file$(s "$count")"`.
