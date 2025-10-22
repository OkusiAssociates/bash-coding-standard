# Variable Expansion & Parameter Substitution - Rulets
## Default Form
- [BCS0302] Always use `"$var"` as the default form for variable expansion; only add braces when syntactically required.
- [BCS0302] Never use braces for standalone variables like `"${var}"`, `"${HOME}"`, or `"${SCRIPT_DIR}"` - use simple form `"$var"` instead.
## Parameter Expansion Operations
- [BCS0301] Use braces for parameter expansion operations: `${var##pattern}` for prefix removal, `${var%pattern}` for suffix removal, `${var:-default}` for defaults.
- [BCS0301] Use braces for substring extraction `${var:0:5}`, pattern substitution `${var//old/new}`, and case conversion `${var,,}` or `${var^^}`.
- [BCS0301] Use braces for array operations: `${array[index]}` for element access, `${array[@]}` for all elements, `${#array[@]}` for length.
- [BCS0301] Use braces for special parameter expansion: `${@:2}` for positional parameters from 2nd onward, `${10}` for parameters beyond $9, `${!var}` for indirect expansion.
## Path Concatenation
- [BCS0302] Use `"$var"/path` or `"$var/path"` for path concatenation with separators - quotes handle concatenation without requiring braces.
- [BCS0302] Never use `"${PREFIX}"/bin` or `"${PREFIX}/bin"` when a separator (slash) is present - use `"$PREFIX"/bin` or `"$PREFIX/bin"` instead.
- [BCS0302] The pattern `"$var"/literal/"$var"` (mixing quoted variables with unquoted literals/separators) is preferred in assignments, conditionals, and command arguments.
## Variable Concatenation
- [BCS0302] Use braces for variable concatenation without separators: `"${var1}${var2}${var3}"` or `"${prefix}suffix"` when immediately followed by alphanumeric characters.
- [BCS0302] Use braces to prevent ambiguity when next character is alphanumeric: `"${var}_suffix"` prevents `$var_suffix` interpretation, `"${prefix}123"` prevents `$prefix123` interpretation.
- [BCS0302] No braces needed when separator is present: `"$var-suffix"`, `"$var.suffix"`, `"$var/path"` - the separator naturally delimits.
## Strings and Messages
- [BCS0302] Use simple form in echo/info strings: `echo "Installing to $PREFIX/bin"` and `info "Found $count files"` - separators (spaces, slashes) make braces unnecessary.
- [BCS0302] Never use braces in string interpolation when separators are present: `echo "Binary: $BIN_DIR/file"` not `echo "Binary: ${BIN_DIR}/file"`.
## Conditionals
- [BCS0302] Use simple form in conditionals: `[[ -d "$path" ]]`, `[[ -f "$SCRIPT_DIR"/file ]]`, `if [[ "$var" == 'value' ]]` - braces add unnecessary noise.
## Rationale
- [BCS0302] Braces add visual noise without providing value when not required; using them only when necessary makes code cleaner and necessary cases stand out.
