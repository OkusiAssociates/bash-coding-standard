## Here Documents

**Use heredocs for multi-line strings or input to commands.**

### Syntax

| Delimiter | Expansion |
|-----------|-----------|
| `<<'EOF'` | No variable expansion (literal) |
| `<<EOF` | Variables expand (`$USER`, `$HOME`) |

### Example

```bash
# Literal (quoted delimiter)
cat <<'EOF'
$USER stays literal
EOF

# Expanded (unquoted delimiter)
cat <<EOF
User: $USER
EOF
```

**Ref:** BCS0904
