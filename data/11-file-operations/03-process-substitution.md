### Process Substitution
\`\`\`bash
# Compare command outputs
diff <(sort file1) <(sort file2)

# Read command output into array
readarray -t array < <(command)

# Process lines from command
while IFS= read -r line; do
  process "$line"
done < <(command)
\`\`\`
