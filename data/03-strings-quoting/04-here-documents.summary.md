### Here Documents

**Rule: BCS0304**

Quoting rules for here documents.

---

#### Delimiter Quoting

| Delimiter | Variable Expansion | Use Case |
|-----------|-------------------|----------|
| `<<EOF` | Yes | Dynamic content with variables |
| `<<'EOF'` | No | Literal content (JSON, SQL) |
| `<<"EOF"` | No | Same as single quotes |

---

#### With Variable Expansion

```bash
cat <<EOF
User: $USER
Home: $HOME
Time: $(date)
EOF
```

---

#### Literal Content (No Expansion)

```bash
cat <<'EOF'
{
  "name": "$APP_NAME",
  "version": "$VERSION"
}
EOF
```

---

#### Indented Content

```bash
# <<- removes leading tabs (not spaces)
if condition; then
	cat <<-EOF
	Indented content
	Aligned with code
	EOF
fi
```

---

#### Anti-Pattern

```bash
# ✗ Wrong - unquoted when literal needed (SQL injection risk)
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF

# ✓ Correct - quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

**Key principle:** Quote delimiter (`<<'EOF'`) to prevent expansion; leave unquoted for variable substitution.

#fin
