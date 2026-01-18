### Quoting Anti-Patterns

**Always quote variables; use single quotes for literals, double for expansions; braces only when required.**

#### Critical Anti-Patterns

| Wrong | Correct | Issue |
|-------|---------|-------|
| `"literal"` | `'literal'` | Unnecessary parsing |
| `$var` | `"$var"` | Word splitting/glob |
| `"${HOME}/bin"` | `"$HOME"/bin` | Unnecessary braces |
| `${arr[@]}` | `"${arr[@]}"` | Element splitting |

#### Braces Required For
```bash
"${var:-default}"    # Parameter expansion
"${file##*/}"        # Substring ops
"${array[@]}"        # Arrays
"${v1}${v2}"         # Adjacent vars
```

#### Glob Danger
```bash
pattern='*.txt'
echo $pattern    # ✗ Expands!
echo "$pattern"  # ✓ Literal
```

#### Here-doc
```bash
cat <<'EOF'      # ✓ Quoted = literal
cat <<EOF        # ✗ Variables expand
```

**Ref:** BCS0307
