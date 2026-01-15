### Quoting Anti-Patterns

**Single quotes for static text, double quotes for variables, avoid unnecessary braces.**

#### Critical Anti-Patterns

| Wrong | Correct | Why |
|-------|---------|-----|
| `"literal"` | `'literal'` | Static strings need single quotes |
| `$var` | `"$var"` | Prevents word splitting/glob expansion |
| `"${HOME}/bin"` | `"$HOME"/bin` | Braces only when needed |
| `${arr[@]}` | `"${arr[@]}"` | Arrays require quotes |

#### When Braces ARE Required

```bash
"${var:-default}"    # Default value
"${file##*/}"        # Parameter expansion
"${array[@]}"        # Array expansion
"${var1}${var2}"     # Adjacent variables
```

#### Glob Danger

```bash
pattern='*.txt'
echo $pattern    # ✗ Expands to all .txt files!
echo "$pattern"  # ✓ Outputs literal: *.txt
```

#### Here-doc: Quote Delimiter for Literals

```bash
# ✗ Variables expand unexpectedly
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted delimiter prevents expansion
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0307
