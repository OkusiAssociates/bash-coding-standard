### Here Documents

**Quote delimiter (`<<'EOF'`) to prevent expansion; unquoted (`<<EOF`) for variable substitution.**

#### Delimiter Quoting

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

#### Examples

```bash
# Expansion enabled
cat <<EOF
User: $USER
EOF

# Literal content (no expansion)
cat <<'EOF'
{"name": "$VAR"}
EOF
```

#### Anti-Pattern

```bash
# ✗ Unquoted �' SQL injection risk
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

**Ref:** BCS0304
