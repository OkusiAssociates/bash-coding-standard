### Static Strings and Constants

Always use single quotes for string literals that contain no variables:

```bash
# Message functions - single quotes for static strings
info 'Checking prerequisites...'
success 'Prerequisites check passed'
warn 'bash-builtins package not found'
error 'Failed to install package'

# Variable assignments
SCRIPT_DESC='Mail Tools Installation Script'
DEFAULT_PATH='/usr/local/bin'
MESSAGE='Operation completed successfully'

# Conditionals with static strings
[[ "$status" == 'success' ]]     # ✓ Correct
[[ "$status" == "success" ]]     # ✗ Unnecessary double quotes
```
