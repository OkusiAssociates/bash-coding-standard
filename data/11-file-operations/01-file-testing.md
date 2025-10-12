### Safe File Testing
\`\`\`bash
[[ -d "$path" ]] || die 1 "Not a directory '$path'"
[[ -f "$file" ]] && source "$file"
[[ -r "$file" ]] || warn "Cannot read '$file'"
\`\`\`
