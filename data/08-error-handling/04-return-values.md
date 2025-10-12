### Checking Return Values
Always check return values and give informative error messages.

\`\`\`bash
# Explicit check with informative error
if ! mv "$file_list" "$dest_dir/"; then
  >&2 echo "Unable to move $file_list to $dest_dir"
  exit 1
fi

# Simple cases with ||
mv "$file_list" "$dest_dir/" || die 1 'Failed to move files'

# Group commands for error handling
mv "$file_list" "$dest_dir/" || {
  error "Move failed: $file_list -> $dest_dir"
  cleanup
  exit 1
}
\`\`\`
