### Arrays for Safe List Handling
Use arrays to store lists of elements safely, especially for command arguments.

\`\`\`bash
# Declare arrays explicitly
declare -a Elements
declare -- element

# Initialize and iterate
Elements=(one two three)
for element in "${Elements[@]}"; do
  echo "$element"
done

# Arrays for command arguments - avoids quoting issues
declare -a cmd_args
cmd_args=( -o "$output" --verbose )
mycmd "${cmd_args[@]}"
\`\`\`
