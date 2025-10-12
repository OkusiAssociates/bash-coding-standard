### Pipes to While
Prefer process substitution or \`readarray\` instead of piping to while.

\`\`\`bash
# ✓✓ Good - readarray
readarray -t my_array < <(my_command)

# ✓ Good - process substitution
while IFS= read -r line; do
  echo "$line"
done < <(my_command)

# ✗ Bad - creates subshell where variables don't persist
my_command | while read -r line; do
  echo "$line"
done
\`\`\`
