### Temporary File Handling

Safe creation and cleanup of temporary files and directories.

\`\`\`bash
# Safe temporary file creation
TMPFILE=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$TMPFILE"' EXIT

# Temporary file with custom template
TMPFILE=$(mktemp /tmp/script.XXXXXX) || die 1 'Failed to create temp file'

# Temporary directory
TMPDIR=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$TMPDIR"' EXIT

# Multiple temp files with cleanup function
declare -a TEMP_FILES=()
cleanup_temps() {
  local -- file
  for file in "${TEMP_FILES[@]}"; do
    [[ -f "$file" ]] && rm -f "$file"
  done
}
trap cleanup_temps EXIT

# Add temp files to cleanup list
TEMP_FILES+=("$(mktemp)")
\`\`\`
