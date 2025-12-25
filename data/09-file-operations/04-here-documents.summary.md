## Here Documents

Use for multi-line strings or input.

**Syntax:**
- `<<'EOF'` - No variable expansion (single quotes prevent expansion)
- `<<EOF` - With variable expansion (double quotes implied)

**Examples:**

```bash
# Static content (no expansion)
cat <<'EOF'
This is a multi-line
string with no variable
expansion.
EOF

# Dynamic content (with expansion)
cat <<EOF
User: $USER
Home: $HOME
EOF
```

**Key distinction**: Quote the delimiter (`'EOF'`) to prevent variable expansion, leave unquoted to enable expansion.
