### Input Sanitization

Validate and sanitize user input to prevent security issues.

\`\`\`bash
# Validate filename - no directory traversal
sanitize_filename() {
  local -- name="$1"
  # Remove directory traversal attempts
  name="${name//\.\./}"
  name="${name//\//}"
  # Allow only safe characters
  if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    die 1 'Invalid filename: contains unsafe characters'
  fi
  echo "$name"
}

# Validate numeric input
validate_number() {
  local -- input="$1"
  if [[ ! "$input" =~ ^-?[0-9]+$ ]]; then
    die 1 "Invalid number: '$input'"
  fi
  echo "$input"
}
\`\`\`
