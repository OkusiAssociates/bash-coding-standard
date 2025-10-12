### Conditionals
\`\`\`bash
# Always use [[ ]] over [ ]
[[ -d "$path" ]] && echo 'Directory exists'

# Arithmetic conditionals use (())
((VERBOSE==0)) || echo 'Verbose mode'
((var > 5)) || return 1

# Complex conditionals
if [[ -n "$var" ]] && ((count > 0)); then
  process_data
fi

# Short-circuit evaluation
[[ -f "$file" ]] && source "$file"
((VERBOSE)) || return 0
\`\`\`
