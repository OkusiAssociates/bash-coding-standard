### Anti-Patterns (What NOT to Do)

\`\`\`bash
# ✗ Don't use double quotes for static strings
info "Checking prerequisites..."    # ✗ Wrong - no variables, use single quotes
success "Operation completed"       # ✗ Wrong - use 'Operation completed'
ERROR_MSG="File not found"          # ✗ Wrong - use 'File not found'

# ✗ Don't forget to quote variables
[[ -f $file ]]                      # ✗ Wrong - word splitting danger
for path in ${paths[@]}; do         # ✗ Wrong - must quote array expansion
echo $VAR/path                      # ✗ Wrong - must quote variable

# ✗ Don't use unnecessary braces AND double quotes together
info "${PREFIX}/bin"                # ✗ Wrong on two counts - use "$PREFIX/bin" or "$PREFIX"/bin
echo "File: ${filename}"            # ✗ Wrong - use "File: $filename"

# ✓ Correct versions
info 'Checking prerequisites...'
success 'Operation completed'
ERROR_MSG='File not found'
[[ -f "$file" ]]
for path in "${paths[@]}"; do
  echo "$VAR/path"
  info "$PREFIX/bin"
  echo "File: $filename"
  #...
done
\`\`\`

**Key Principle:** Single quotes mean "literal text", double quotes mean "process this". Use the simplest form that works correctly.
