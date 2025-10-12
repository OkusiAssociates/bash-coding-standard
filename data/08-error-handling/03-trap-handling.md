### Trap Handling
\`\`\`bash
cleanup() {
  local -i exitcode=${1:-0}
  # Cleanup operations
  #...
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
\`\`\`
