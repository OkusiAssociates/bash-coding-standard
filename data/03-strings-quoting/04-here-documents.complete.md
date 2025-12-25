### Here Documents

**Rule: BCS0304** (Merged from BCS0408 + BCS1104)

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
# Unquoted delimiter - variables expand
cat <<EOF
User: $USER
Home: $HOME
Time: $(date)
EOF
```

---

#### Literal Content (No Expansion)

```bash
# Single-quoted delimiter - no expansion
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

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted when literal needed
cat <<EOF
SELECT * FROM users WHERE name = "$name"
EOF
# SQL injection risk if $name is attacker-controlled!

# ✓ Correct - quoted for literal SQL
cat <<'EOF'
SELECT * FROM users WHERE name = ?
EOF
```

---

**Key principle:** Quote the delimiter (`<<'EOF'`) to prevent expansion; leave unquoted for variable substitution.

#fin
