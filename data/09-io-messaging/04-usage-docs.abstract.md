## Usage Documentation

**Use heredoc with `cat <<EOT` for multi-line help text including script metadata, options, and examples.**

**Format:** Title line with `$SCRIPT_NAME $VERSION`, description, `Usage:` line, options with short/long forms, examples section.

```bash
show_help() {
  cat <<EOT
$SCRIPT_NAME $VERSION - Brief description
Usage: $SCRIPT_NAME [Options] [arguments]
Options:
  -v|--verbose      Increase verbose output
  -h|--help         This help message
EOT
}
```

**Rationale:** Heredoc prevents escaping issues, enables variable expansion, maintains formatting.

**Ref:** BCS0904
