### Exit Codes
\`\`\`bash
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
die 0                    # Success (or use \`exit 0\`)
die 1                    # Exit 1 with no error message
die 1 'General error'    # General error
die 2 'Missing argument' # Missing argument
die 22 'Invalid option'  # Invalid argument
\`\`\`
