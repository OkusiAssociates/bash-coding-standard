### Parameter Expansion & Braces

**Use `"$var"` by default; braces `"${var}"` only when syntactically required.**

#### When Braces REQUIRED

- **Expansion ops:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **No separator concat:** `"${var1}${var2}"` `"${prefix}suffix"`
- **Arrays:** `"${array[@]}"` `"${#array[@]}"`
- **Special:** `"${@:2}"` `"${10}"` `"${!var}"`

#### When Braces NOT Required

Standalone or separator-delimited: `"$var"` `"$HOME"` `"$PREFIX"/bin` `"$var-suffix"`

```bash
# ✓ Correct
SCRIPT_NAME=${SCRIPT_PATH##*/}
echo "Installing to $PREFIX/bin"
"$SCRIPT_DIR"/build/lib

# ✗ Wrong - unnecessary braces
echo "${PREFIX}/bin"
info "Found ${count} files"
```

**Rationale:** Braces add noise; reserving them for required cases makes special operations stand out.

**Ref:** BCS0210
