## Here Documents

**Use heredocs for multi-line strings; quote delimiter to prevent expansion.**

| Syntax | Expansion |
|--------|-----------|
| `<<'EOT'` | None (literal) |
| `<<EOT` | Variables expand |

```bash
cat <<'EOT'    # No expansion
Literal $VAR
EOT

cat <<EOT      # Expands variables
User: $USER
EOT
```

**Ref:** BCS0904
