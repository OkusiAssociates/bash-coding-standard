## Static Strings and Constants

**Always use single quotes for string literals that contain no variables:**

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
[[ "$status" == 'success' ]]     #  Correct
[[ "$status" == "success" ]]     #  Unnecessary double quotes
```

**Rationale:**

1. **Performance**: Single quotes are slightly faster (no parsing for variables/escapes)
2. **Clarity**: Signals "this is a literal string, no substitution"
3. **Safety**: Prevents accidental variable expansion or command substitution
4. **Predictability**: WYSIWYG - no escaping needed for `$`, `` ` ``, `\`, `!`

**Single quotes required for:**

```bash
# Strings with special characters
msg='The variable $PATH will not expand here'
cmd='This `command` will not execute'
note='Backslashes \ do not escape anything in single quotes'

# SQL queries and regex patterns
sql='SELECT * FROM users WHERE name = "John"'
regex='^\$[0-9]+\.[0-9]{2}$'  # Matches $12.34

# Shell commands stored as strings
find_cmd='find /tmp -name "*.log" -mtime +7 -delete'
```

**Double quotes needed when:**

```bash
# Variables must be expanded
info "Found $count files in $directory"
echo "Current user: $USER"
warn "File $filename does not exist"

# Command substitution needed
msg="Current time: $(date +%H:%M:%S)"
info "Script running as $(whoami)"

# Escape sequences needed
echo "Line 1\nLine 2"  # \n processed in double quotes
tab="Column1\tColumn2"  # \t processed in double quotes
```

**Anti-patterns:**

```bash
#  Wrong - double quotes for static strings
info "Checking prerequisites..."  # No variables, use single quotes
error "Failed to connect"          # No variables, use single quotes
[[ "$status" == "active" ]]        # Right side should be single-quoted

#  Correct
info 'Checking prerequisites...'
error 'Failed to connect'
[[ "$status" == 'active' ]]

#  Wrong - unnecessary escaping in double quotes
msg="The cost is \$5.00"           # Must escape $
path="C:\\Users\\John"             # Must escape backslashes

#  Correct - no escaping needed in single quotes
msg='The cost is $5.00'
path='C:\Users\John'

#  Wrong - trying to use variables in single quotes
name='John'
greeting='Hello, $name'  #  $name not expanded, greeting = "Hello, $name"

#  Correct
name='John'
greeting="Hello, $name"  #  greeting = "Hello, John"
```

**Combining quotes:**

```bash
# Single quote inside double quotes
msg="It's $count o'clock"  #  Works

# Mixing static text and variables
echo 'Static text: ' "$variable" ' more static'
# Or use double quotes for everything
echo "Static text: $variable more static"
```

**Empty strings:**

```bash
var=''   #  Preferred for consistency
var=""   #  Also acceptable

DEFAULT_VALUE=''
EMPTY_STRING=''
```

**Summary:**
- **Single quotes `'...'`**: For all static strings (no variables, no escapes)
- **Double quotes `"..."`**: When you need variable expansion or command substitution
- **Consistency**: Single quotes for static strings makes code scannable - double quotes signal variable/substitution presence
