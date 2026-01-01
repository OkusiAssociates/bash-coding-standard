## Usage Documentation

**Implement `show_help()` with here-doc containing: name/version, description, usage line, options (grouped), examples.**

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [args]

Options:
  -n|--num NUM   Set num
  -v|--verbose   Verbose output
  -h|--help      This help
EOT
}
```

Anti-patterns: `echo` statements â†' use here-doc; missing `$SCRIPT_NAME`/`$VERSION` â†' use variables; ungrouped options â†' group logically

**Ref:** BCS0704
