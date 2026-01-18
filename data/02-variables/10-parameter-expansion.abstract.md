### Parameter Expansion & Braces

**Use `"$var"` by default; braces only when syntactically required.**

#### When Braces Required
- **Expansion ops:** `${var:-default}` `${var##*/}` `${var:0:5}` `${var//old/new}` `${var,,}`
- **Concatenation (no separator):** `${var}suffix` `${a}${b}`
- **Arrays:** `${arr[@]}` `${arr[i]}` `${#arr[@]}`
- **Special:** `${10}` `${@:2}` `${!var}` `${#var}`

#### When Braces NOT Required
- Standalone: `"$var"` `"$HOME"` → not `"${var}"`
- With separators: `"$var/path"` `"$var-suffix"` → not `"${var}/path"`

#### Core Operations
```bash
${var##*/}      # Longest prefix removal
${var%/*}       # Shortest suffix removal
${var:-default} # Default if unset
${var:0:5}      # Substring
${var//old/new} # Replace all
${var,,}        # Lowercase (Bash 4+)
```

#### Anti-patterns
- `"${HOME}"` → `"$HOME"` (unnecessary braces)
- `"${PREFIX}/bin"` → `"$PREFIX/bin"` (separator delimits)

**Ref:** BCS0210
