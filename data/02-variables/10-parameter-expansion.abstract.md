### Parameter Expansion & Braces Usage

**Use `"$var"` by default; braces only when syntactically required.**

---

#### Braces REQUIRED

- **Operations:** `${var##*/}` `${var:-default}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Concatenation:** `"${var1}${var2}"` `"${prefix}suffix"`
- **Arrays:** `"${array[@]}"` `"${#array[@]}"`
- **Special:** `"${@:2}"` `"${10}"` `"${!var}"`

#### Braces NOT Required

```bash
# ✓ Correct
"$var"  "$PREFIX"/bin  "Found $count files"

# ✗ Wrong - unnecessary braces
"${var}"  "${PREFIX}"/bin  "Found ${count} files"
```

#### Edge Cases

```bash
"${var}_suffix"   # Required - no separator
"$var-suffix"     # OK - dash separates
```

#### Summary

| Situation | Form |
|-----------|------|
| Standalone | `"$var"` |
| Path with `/` | `"$var"/path` |
| Expansion op | `"${var%/*}"` |
| Concatenation | `"${a}${b}"` |
| Array | `"${arr[@]}"` |

**Ref:** BCS0210
