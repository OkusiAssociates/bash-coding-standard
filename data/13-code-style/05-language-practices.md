### Language Best Practices

#### Command Substitution
\`\`\`bash
# Always use $() instead of backticks
var=$(command)       # ✓ Correct
var=\`command\`        # ✗ Wrong!
\`\`\`

#### Builtin Commands vs External Commands
Always prefer shell builtins over external commands for performance.

\`\`\`bash
# Good - bash builtins
addition=$((x + y))
string=${var^^}  # uppercase
if [[ -f "$file" ]]; then

# Avoid - external commands
addition=$(expr "$x" + "$y")
string=$(echo "$var" | tr '[:lower:]' '[:upper:]')
if [ -f "$file" ]; then
\`\`\`
