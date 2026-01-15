## Here Documents

**Use heredocs for multi-line strings/input; quote delimiter to prevent expansion.**

`<<'EOF'` â†' literal (no expansion) | `<<EOF` â†' variables expand

```bash
cat <<'EOT'
Literal $VAR text
EOT

cat <<EOT
Expanded: $USER
EOT
```

**Anti-pattern:** Using `echo` with embedded newlines â†' use heredoc instead.

**Ref:** BCS0904
