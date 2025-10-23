# Variable Expansion & Parameter Substitution - Rulets
## Default Form
- [BCS0302] Always use `"$var"` without braces as the default form for standalone variables: `"$HOME"`, `"$SCRIPT_DIR"`, `"$1"`.
- [BCS0302] Only use braces `"${var}"` when syntactically necessary; braces add visual noise and should make necessary cases stand out.
## Required Brace Usage
- [BCS0301,BCS0302] Use braces for parameter expansion operations: `"${var##*/}"` (remove prefix), `"${var%/*}"` (remove suffix), `"${var:-default}"` (default value), `"${var:0:5}"` (substring), `"${var//old/new}"` (substitution), `"${var,,}"` (case conversion).
- [BCS0302] Use braces for variable concatenation without separators: `"${var1}${var2}${var3}"` or `"${prefix}suffix"` when variable immediately followed by alphanumeric.
- [BCS0301,BCS0302] Use braces for array access: `"${array[index]}"`, `"${array[@]}"`, `"${#array[@]}"`.
- [BCS0301,BCS0302] Use braces for special parameter expansion: `"${@:2}"` (positional parameters from 2nd), `"${10}"` (parameters beyond $9), `"${!var}"` (indirect expansion).
## Path Concatenation
- [BCS0302] Use simple form for path concatenation with separators: `"$PREFIX"/bin` or `"$PREFIX/bin"`, never `"${PREFIX}"/bin`.
- [BCS0302] Mix quoted variables with unquoted literals/separators in assignments and commands: `"$path"/file.txt`, `"$HOME"/.config/"$APP"/settings`, `[[ -f "$dir"/subdir/file ]]`.
## String Interpolation
- [BCS0302] Use simple form in echo/info strings: `echo "Installing to $PREFIX/bin"`, `info "Found $count files"`, never `echo "Installing to ${PREFIX}/bin"`.
- [BCS0302] Use simple form in conditionals: `[[ -d "$path" ]]`, `[[ -f "$SCRIPT_DIR"/file ]]`, never `[[ -d "${path}" ]]`.
## Edge Cases
- [BCS0302] Use braces when next character is alphanumeric with no separator: `"${var}_suffix"` (prevents `$var_suffix` interpretation), `"${prefix}123"` (prevents `$prefix123` interpretation).
- [BCS0302] Omit braces when separator present: `"$var-suffix"` (dash), `"$var.suffix"` (dot), `"$var/path"` (slash).
## Key Principle
- [BCS0300,BCS0302] Default to `"$var"` for simplicity and readability; reserve `"${var}"` exclusively for cases where shell requires braces for correct parsing.
