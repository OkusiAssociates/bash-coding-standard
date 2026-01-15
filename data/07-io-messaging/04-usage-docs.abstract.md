## Usage Documentation

**Every script MUST provide `show_help()` with name, version, description, options, and examples.**

### Rationale
- Self-documenting scripts reduce support burden
- Consistent format enables automated help extraction

### Required Structure
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose   Increase verbosity
  -h|--help      This help
Examples:
  $SCRIPT_NAME -v file.txt
EOT
}
```

### Anti-patterns
- `echo "Usage..."` â†' Use heredoc for multiline help
- Missing `-h|--help` option

**Ref:** BCS0704
