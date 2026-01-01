### Here Documents

**Quote delimiter (`<<'EOF'`) for literal content; unquoted (`<<EOF`) for variable expansion.**

| Delimiter | Expansion | Use Case |
|-----------|-----------|----------|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

Use `<<-EOF` to strip leading tabs for indented blocks.

```bash
# Dynamic
cat <<EOF
User: $USER
EOF

# Literal (prevents injection)
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Anti-pattern:** `<<EOF` with untrusted `$var` â†' injection risk. Use `<<'EOF'` + parameterized queries.

**Ref:** BCS0304
