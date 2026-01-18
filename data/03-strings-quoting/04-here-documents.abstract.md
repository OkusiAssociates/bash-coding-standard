### Here Documents

**Quote delimiter (`<<'EOF'`) for literal content; unquoted (`<<EOF`) for variable expansion.**

#### Delimiter Behavior

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | JSON, SQL, literals |

`<<-EOF` strips leading tabs (not spaces).

#### Example

```bash
# Variables expand
cat <<EOF
User: $USER
EOF

# Literal (no expansion)
cat <<'EOF'
{"key": "$VAR"}
EOF
```

#### Anti-Pattern

`<<EOF` with untrusted data → SQL injection risk. Use `<<'EOF'` for literals with `$` symbols.

**Ref:** BCS0304
