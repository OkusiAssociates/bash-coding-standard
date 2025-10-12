### IFS Manipulation Safety
When changing IFS, always save and restore it.

\`\`\`bash
# Save and restore IFS
OLD_IFS="$IFS"
IFS=$'\n'
# ... operations requiring newline separator ...
IFS="$OLD_IFS"

# Or use subshell to isolate IFS changes
(
  IFS=','
  read -ra array <<< "$csv_data"
  # IFS change limited to subshell
)
\`\`\`
