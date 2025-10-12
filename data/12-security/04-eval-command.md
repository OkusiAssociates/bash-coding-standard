### Eval Command
\`eval\` should be avoided wherever possible due to security risks.

\`\`\`bash
# Dangerous - avoid
eval "$user_input"

# Safer alternatives
# Use indirect expansion for variable references
var_name=HOME
echo "${!var_name}"

# Use arrays for building commands
declare -a cmd=(ls -la "$dir")
"${cmd[@]}"
\`\`\`
