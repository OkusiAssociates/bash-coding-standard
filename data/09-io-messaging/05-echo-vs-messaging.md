### Echo vs Messaging Functions

Choose between plain \`echo\` and messaging functions based on the context and formatting requirements:

**Use messaging functions (\`info\`, \`success\`, \`warn\`, \`error\`) for:**
- Single-line status updates during script execution
- Progress indicators
- Error and warning messages
- Messages that should respect verbosity settings
- Messages that benefit from visual formatting (colors, icons)

\`\`\`bash
info 'Checking prerequisites...'
success 'Installation complete'
warn 'bash-builtins package not found'
error 'Failed to build binary'

# Multi-line messaging with continuation
info '[DRY-RUN] Would install:' \
     "  $BIN_DIR/mailheader" \
     "  $BIN_DIR/mailmessage"
\`\`\`

**Use plain \`echo\` for:**
- Multi-paragraph formatted output
- Help text and documentation
- Structured output intended for parsing
- Complex formatting with multiple echo statements
- Output that should always display regardless of verbosity

\`\`\`bash
# Multi-paragraph completion message
show_completion_message() {
  echo
  success 'Installation complete!'
  echo
  echo 'Installed files:'
  echo "  • Standalone binaries: $BIN_DIR/mailheader"
  echo "  • Scripts:             $BIN_DIR/mailgetaddresses"
  echo "  • Manpages:            $MAN_DIR/mailheader.1"
  echo
  echo 'Verify installation:'
  echo '  which mailheader'
  echo '  man mailheader'
  echo
}
\`\`\`

**Rationale:** Messaging functions provide consistent formatting, verbosity control, and visual indicators (colors, icons). Plain \`echo\` is better for structured multi-line output where you need precise control over formatting and spacing.
