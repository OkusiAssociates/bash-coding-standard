### PATH Security
Lock down PATH to prevent command injection and trojan attacks.

\`\`\`bash
# Lock down PATH at script start
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH

# Or validate existing PATH
[[ "$PATH" =~ \. ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^: ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ :: ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ :$ ]] && die 1 'PATH ends with empty element'
\`\`\`
