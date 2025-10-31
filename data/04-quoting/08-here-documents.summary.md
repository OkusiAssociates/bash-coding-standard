## Here Documents

Quote delimiter based on expansion needs:

```bash
# No expansion - quote delimiter
cat <<'EOF'
This text is literal.
$VAR is not expanded.
$(command) is not executed.
EOF

# With expansion - unquoted delimiter
cat <<EOF
Script: $SCRIPT_NAME
Version: $VERSION
Time: $(date)
EOF
```

**Note**: Double quotes on delimiter behave identically to unquoted (both enable expansion).
