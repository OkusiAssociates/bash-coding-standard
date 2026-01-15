### Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### Braces Required

- **Expansion ops:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Adjacent concat:** `${prefix}suffix` `${var1}${var2}`
- **Arrays:** `${array[@]}` `${array[i]}` `${#array[@]}`
- **Special:** `${10}` `${@:2}` `${!var}` `${#var}`

#### No Braces (separators delimit)

`"$var"` `"$HOME"` `"$PREFIX"/bin` `"$var-suffix"` `"$var.suffix"`

```bash
# Pattern/default/substring
name=${path##*/}; dir=${path%/*}; val=${var:-default}
# ✓ "$PREFIX"/bin  �' ✗ "${PREFIX}"/bin
# ✓ "$var"         �' ✗ "${var}"
```

| Context | Form |
|---------|------|
| Standalone | `"$var"` |
| With separator | `"$var"/path` |
| Expansion op | `"${var%pat}"` |
| Concat (no sep) | `"${a}${b}"` |

**Ref:** BCS0210
