# Quoting & String Literals - Rulets
## General Principles
- [BCS0400] Use single quotes (`'...'`) for static string literals and double quotes (`"..."`) only when variable expansion, command substitution, or escape sequences are needed.
- [BCS0400] Single quotes signal "literal text" while double quotes signal "shell processing needed" - this semantic distinction clarifies intent for both developers and AI assistants.
## Static Strings and Constants
- [BCS0401] Always use single quotes for string literals that contain no variables: `info 'Checking prerequisites...'` not `info "Checking prerequisites..."`.
- [BCS0401] Single quotes prevent accidental variable expansion, command substitution, and eliminate the need to escape special characters like `$`, `` ` ``, `\`, `!`.
- [BCS0401] Use double quotes only when the string requires variable expansion or command substitution: `info "Processing $count files"`.
- [BCS0401] For empty strings, prefer single quotes for consistency: `var=''` not `var=""`.
## One-Word Literals
- [BCS0402] Literal one-word values containing only safe characters (alphanumeric, underscore, hyphen, dot, slash) may be left unquoted in variable assignments and conditionals, but quoting is more defensive and recommended: `ORGANIZATION=Okusi` is acceptable but `ORGANIZATION='Okusi'` is better.
- [BCS0402] Values with spaces, wildcards, special characters (`@`, `*`, `?`, etc.), or starting with hyphens must always be quoted: `EMAIL='user@domain.com'`, `PATTERN='*.txt'`, `MESSAGE='Hello world'`.
- [BCS0402] When in doubt, quote everything - the reduction in visual noise from omitting quotes on one-word literals is not worth the mental overhead or risk of bugs when values change.
## Strings with Variables
- [BCS0403] Use double quotes when strings contain variables that need expansion: `error "'$compiler' not found"`, `info "Installing to $PREFIX/bin"`.
- [BCS0403] Do not use braces around variables unless required for parameter expansion, array access, or adjacent variables: `echo "$PREFIX/bin"` not `echo "${PREFIX}/bin"`.
## Mixed Quoting
- [BCS0404] When a string contains both static text and variables, use double quotes with nested single quotes for literal protection: `die 2 "Unknown option '$1'"`, `warn "Cannot access '$file_path'"`.
## Command Substitution
- [BCS0405] Always use double quotes when including command substitution: `echo "Current time: $(date +%T)"`, `info "Found $(wc -l "$file") lines"`.
## Variables in Conditionals
- [BCS0406] Always quote variables in test expressions to prevent word splitting and glob expansion, even when the variable is guaranteed to contain a safe value: `[[ -f "$file" ]]` not `[[ -f $file ]]`.
- [BCS0406] Quote variables in all conditional contexts: file tests `[[ -d "$path" ]]`, string comparisons `[[ "$name" == "$expected" ]]`, integer comparisons `[[ "$count" -eq 0 ]]`, logical operators `[[ -f "$file" && -r "$file" ]]`.
- [BCS0406] Static comparison values follow normal quoting rules - use single quotes for multi-word literals or special characters `[[ "$message" == 'file not found' ]]`, but one-word literals can be unquoted `[[ "$action" == start ]]`.
- [BCS0406] For glob pattern matching, leave the right-side pattern unquoted: `[[ "$filename" == *.txt ]]`; for literal matching, quote it: `[[ "$filename" == '*.txt' ]]`.
- [BCS0406] For regex matching with `=~`, keep the pattern unquoted or in an unquoted variable: `[[ "$email" =~ ^[a-z]+@[a-z]+$ ]]` or `pattern='^test'; [[ "$input" =~ $pattern ]]`.
## Array Expansions
- [BCS0407] Always quote array expansions to preserve element boundaries: `"${array[@]}"` for separate elements, `"${array[*]}"` for a single concatenated string.
- [BCS0407] Use `"${array[@]}"` for iteration, function arguments, and command arguments: `for item in "${array[@]}"`, `my_function "${array[@]}"`.
- [BCS0407] Use `"${array[*]}"` for display, logging, or creating comma-separated values with custom IFS: `echo "Items: ${array[*]}"`, `IFS=','; csv="${array[*]}"`.
- [BCS0407] Unquoted array expansions undergo word splitting and glob expansion, breaking elements with spaces and losing empty elements - never use unquoted: `${array[@]}`.
## Here Documents
- [BCS0408] Use single-quoted delimiter for literal here-docs with no expansion: `cat <<'EOF'` preserves `$VAR` and `$(command)` as literal text.
- [BCS0408] Use unquoted delimiter (or double-quoted, which is equivalent) for here-docs requiring variable/command expansion: `cat <<EOF` expands `$VAR` and `$(command)`.
## Echo and Printf
- [BCS0409] Use single quotes for static echo/printf strings: `echo 'Installation complete'`, `printf '%s\n' 'Processing files'`.
- [BCS0409] Use double quotes for echo/printf with variables: `echo "$SCRIPT_NAME $VERSION"`, `printf 'Found %d files in %s\n' "$count" "$dir"`.
## Anti-Patterns
- [BCS0411] Never use double quotes for static strings with no variables: `info "Checking prerequisites..."` is wrong, use `info 'Checking prerequisites...'`.
- [BCS0411] Never leave variables unquoted in conditionals, assignments, or commands: `[[ -f $file ]]`, `rm $temp_file`, `for item in ${items[@]}` are all wrong.
- [BCS0411] Never use braces when not required: `echo "${HOME}/bin"` should be `echo "$HOME/bin"`; use braces only for parameter expansion `"${var##pattern}"`, arrays `"${array[@]}"`, defaults `"${var:-default}"`, or adjacent variables `"${var1}${var2}"`.
- [BCS0411] Never mix quote styles inconsistently within similar contexts: pick single quotes for all static strings and stick with it.
- [BCS0411] Never use unquoted variables with glob characters or special characters: `pattern='*.txt'; echo $pattern` expands to all `.txt` files.
## Helper Functions
- [BCS0412] Trim whitespace from strings: `trim() { local v="$*"; v="${v#"${v%%[![:blank:]]*}"}"; echo -n "${v%"${v##*[![:blank:]]}"}";}`.
- [BCS0413] Display declared variables without type decorations: `decp() { declare -p "$@" | sed 's/^declare -[a-zA-Z-]* //'; }`.
- [BCS0414] Pluralization helper for output messages: `s() { (( ${1:-1} == 1 )) || echo -n 's'; }` prints 's' unless count is 1.
