## Here Documents

**Use here-docs for multi-line strings/input; quote delimiter to prevent expansion.**

**Rationale:** Here-docs provide clean multi-line text without escaping. Quoting the delimiter (`<<'EOF'`) prevents variable expansion; unquoted allows expansion.

**Example:**
```bash
# No expansion (quoted delimiter)
cat <<'EOF'
Literal $USER text
EOF

# With expansion
cat <<EOF
User: $USER
EOF
```

**Anti-patterns:**
- `echo -e "line1\nline2"` ’ Use here-doc for readability
- Forgetting to quote delimiter when literal text needed

**Ref:** BCS1104
