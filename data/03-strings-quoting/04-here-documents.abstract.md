### Here Documents

**Quote delimiter (`<<'EOF'`) to prevent expansion; unquoted (`<<EOF`) for variable substitution.**

#### Delimiter Types

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON, SQL) |

#### Core Pattern

```bash
# Variables expand
cat <<EOF
User: $USER
EOF

# Literal content (no expansion)
cat <<'EOF'
{"name": "$APP_NAME"}
EOF
```

#### Indentation

`<<-` removes leading tabs only (not spaces).

#### Anti-Pattern

`<<EOF` with SQL â†' injection risk if variables contain user input. Use `<<'EOF'` for literal queries with placeholders.

**Ref:** BCS0304
