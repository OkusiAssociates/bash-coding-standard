### Here Documents

**Delimiter quoting controls variable expansion: `<<EOF` expands, `<<'EOF'` literal.**

| Delimiter | Expansion | Use |
|-----------|-----------|-----|
| `<<EOF` | Yes | Dynamic content |
| `<<'EOF'` | No | Literal (JSON/SQL) |

**Indented:** `<<-EOF` strips leading tabs (not spaces).

```bash
# Dynamic - variables expand
cat <<EOF
User: $USER
EOF

# Literal - no expansion (use for JSON/SQL)
cat <<'EOF'
{"key": "$VALUE"}
EOF
```

**Anti-pattern:** `<<EOF` with untrusted data â†' SQL injection. Use `<<'EOF'` for literal content.

**Ref:** BCS0304
