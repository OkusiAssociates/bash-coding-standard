## Usage Documentation

**Provide structured `show_help()` with name, version, description, options, and examples.**

### Rationale
- Users need consistent, discoverable interface documentation
- Enables `--help` / `-h` patterns expected by Unix conventions

### Template
```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -n|--num NUM      Set num to NUM
  -v|--verbose      Verbose output
  -h|--help         This help

Examples:
  $SCRIPT_NAME -v file.txt
EOT
}
```

### Anti-patterns
- Missing version/name variables → hardcoded strings break maintenance
- No examples section → users guess at syntax

**Ref:** BCS0704
