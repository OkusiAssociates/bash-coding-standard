## Here Documents

**Quote delimiter with single quotes to prevent expansion; leave unquoted (or double-quoted) to enable expansion.**

```bash
# Literal (no expansion)
cat <<'EOF'
$VAR not expanded
EOF

# With expansion
cat <<EOF
Script: $SCRIPT_NAME
EOF
```

**Anti-pattern:** Using double quotes thinking it differs from unquoted ’ both enable expansion.

**Ref:** BCS0408
