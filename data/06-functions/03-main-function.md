### Main Function
- Always include a \`main()\` function for scripts longer than ~100 lines
- Helps with organization and testing

\`\`\`bash
main() {
  # Main logic here
  local -i rc=0
  # Process arguments, call functions
  return "$rc"
}

# Call main with all arguments
main "$@"
#fin
\`\`\`
