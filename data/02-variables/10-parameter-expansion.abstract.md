### Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### Braces Required

```bash
"${var##*/}"      # Pattern removal
"${var:-default}" # Default value
"${var:0:5}"      # Substring
"${var//old/new}" # Substitution
"${var,,}"        # Lowercase
"${array[@]}"     # Array access
"${var1}${var2}"  # No-separator concat
"${prefix}suffix" # Alphanumeric follows
```

#### No Braces Needed

```bash
"$var"           # Standalone
"$PREFIX"/bin    # Separator delimits
"$var-suffix"    # Dash/dot/slash separates
```

#### Key Operations

| Op | Syntax | Use |
|----|--------|-----|
| Prefix rm | `${v##*/}` | Basename |
| Suffix rm | `${v%/*}` | Dirname |
| Default | `${v:-x}` | Fallback |
| Replace | `${v//a/b}` | Subst all |
| Length | `${#v}` | Char count |

**Anti-patterns:** `"${var}"` standalone â†' `"$var"` | `"${PREFIX}/bin"` â†' `"$PREFIX"/bin`

**Ref:** BCS0210
