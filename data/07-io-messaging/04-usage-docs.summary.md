## Usage Documentation

Standard `show_help()` pattern using heredoc with variable interpolation.

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description

Detailed description.

Usage: $SCRIPT_NAME [Options] [arguments]

Options:
  -n|--num NUM      Set num to NUM

  -v|--verbose      Increase verbose output
  -q|--quiet        No verbosity

  -V|--version      Print version ('$SCRIPT_NAME $VERSION')
  -h|--help         This help message

Examples:
  # Example 1
  $SCRIPT_NAME -v file.txt
EOT
}
```

**Key elements:** Script name/version header, description, usage line, grouped options with blank-line separators, examples section.
