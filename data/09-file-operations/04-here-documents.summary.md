## Here Documents

Use for multi-line strings or input.

```bash
# No variable expansion (note single quotes)
cat <<'EOT'
This is a multi-line
string with no variable
expansion.
EOT

# With variable expansion
cat <<EOT
User: $USER
Home: $HOME
EOT
```
