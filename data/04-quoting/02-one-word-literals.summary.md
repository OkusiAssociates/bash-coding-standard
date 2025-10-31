## Exception: One-Word Literals

**Literal one-word values containing only safe characters (alphanumeric, underscore, hyphen, dot, slash) may be left unquoted in variable assignments and simple conditionals. However, quoting is more defensive and recommended. When in doubt, quote everything.**

**Rationale:**

- **Common Practice**: Widely used convention in shell scripts
- **Safety Threshold**: Only safe when value contains no special characters
- **Defensive Programming**: Quoting prevents future bugs if value changes
- **Consistency**: Always quoting eliminates mental overhead and team preference decisions

**One-word literal definition** - Contains **only** alphanumeric (`a-zA-Z0-9`), underscores (`_`), hyphens (`-`), dots (`.`), forward slashes (`/`). Does **not** contain spaces, tabs, newlines, or shell special characters: `*`, `?`, `[`, `]`, `{`, `}`, `$`, `` ` ``, `"`, `'`, `\`, `;`, `&`, `|`, `<`, `>`, `(`, `)`, `!`, `#`, `@`. Must not start with hyphen in conditionals.

**Variable assignments:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

#  Acceptable - one-word literals unquoted
declare -- ORGANIZATION=Okusi
declare -- LOG_LEVEL=INFO
declare -- DEFAULT_PATH=/usr/local/bin

#  Better - always quote (defensive programming)
declare -- ORGANIZATION='Okusi'
declare -- LOG_LEVEL='INFO'
declare -- DEFAULT_PATH='/usr/local/bin'

#  MANDATORY - quote multi-word or special values
declare -- APP_NAME='My Application'
declare -- PATTERN='*.log'
declare -- EMAIL='admin@example.com'

#  Wrong - special characters unquoted
declare -- EMAIL=admin@example.com      # @ is special!
declare -- PATTERN=*.log                 # * will glob!

#fin
```

**Conditionals:**

```bash
declare -- status='success'

#  Acceptable - one-word literal values unquoted
[[ "$status" == success ]]

#  Better - always quote (more consistent)
[[ "$status" == 'success' ]]

#  MANDATORY - quote multi-word values
[[ "$message" == 'File not found' ]]
[[ "$pattern" == '*.txt' ]]

# Note: ALWAYS quote the variable being tested
[[ "$status" == success ]]     #  Variable quoted
[[ $status == success ]]       #  Variable unquoted - dangerous!

#fin
```

**Case statement patterns:**

```bash
#  Acceptable - case patterns can be unquoted literals
case "$action" in
  start) start_service ;;      #  One-word literal
  stop) stop_service ;;        #  One-word literal
  *) die 22 "Invalid action: $action" ;;
esac

#  MANDATORY - quote patterns with special characters
case "$email" in
  'admin@example.com') echo 'Admin user' ;;    # Must quote @
  *) echo 'Unknown user' ;;
esac

#fin
```

**Path construction:**

```bash
#  Acceptable - literal path segments unquoted
declare -- temp_file="$PWD"/.foobar.tmp
declare -- log_path=/var/log/myapp.log

#  Better - quote for consistency (recommended)
declare -- temp_file="$PWD/.foobar.tmp"
declare -- log_path='/var/log/myapp.log'

#  MANDATORY - quote paths with spaces
declare -- docs_dir="$HOME/My Documents"

#  Wrong - unquoted paths with spaces
declare -- docs_dir=$HOME/My Documents     # Word splitting!

#fin
```

**When quotes are mandatory:**

```bash
# 1. Values with spaces
MESSAGE='Hello world'               #  Correct

# 2. Values with wildcards
PATTERN='*.txt'                     #  Correct

# 3. Values with special characters
EMAIL='user@domain.com'             #  Correct

# 4. Empty strings
VALUE=''                            #  Correct

# 5. Values starting with hyphen (in conditionals)
[[ "$arg" == '-h' ]]                #  Correct

# 6. Values with parentheses
FILE='test(1).txt'                  #  Correct

# 7. Values with dollar signs (use single quotes)
LITERAL='$100'                      #  Correct

# 8. Values with backslashes (use single quotes)
PATH='C:\Users\Name'                #  Correct

# 9. Values with quotes
MESSAGE='It'\''s working'           #  Correct
MESSAGE="He said \"hello\""         #  Correct

# 10. Variable expansions (always quote)
FILE="$basename.txt"                #  Correct
```

**Anti-patterns:**

```bash
#  Wrong - unquoting values that need quotes
MESSAGE=File not found              # Syntax error!
EMAIL=admin@example.com             # @ is special!
PATTERN=*.log                       # Glob expansion!

#  Wrong - inconsistent quoting
OPTION1=value1                      # Unquoted
OPTION2='value2'                    # Quoted
# Pick one style and be consistent!

#  Better - consistent quoting (recommended)
OPTION1='value1'
OPTION2='value2'

#  Wrong - unquoted variable concatenation
FILE=$basename.txt                  # Dangerous!
FILE="$basename.txt"                #  Correct

#  Wrong - unquoted command substitution result
result=$(command)
echo $result                        # Word splitting!
echo "$result"                      #  Correct
```

**Edge cases:**

**Numeric values:**

```bash
# Numbers are technically one-word literals
COUNT='42'              #  Better

# For arithmetic, unquoted is standard
declare -i count=42     #  Correct for integers
((count = 10))          #  Correct in arithmetic context

# In conditionals, quote for consistency
[[ "$count" -eq 42 ]]   #  Variable quoted
```

**Boolean-style values:**

```bash
ENABLED='true'          #  Better
[[ "$ENABLED" == 'true' ]]  #  Better

# As integers (preferred for booleans)
declare -i ENABLED=1
((ENABLED)) && echo 'Enabled'
```

**URLs and email addresses:**

```bash
#  Correct - must quote (@ and : are special)
URL='https://example.com/path'
EMAIL='user@domain.com'
```

**Version numbers:**

```bash
VERSION='1.0.0'         #  Better
VERSION='1.0.0-beta'    #  Better (alphanumeric, dots, hyphen)
```

**Paths with spaces:**

```bash
# MUST quote
PATH='/Applications/My App.app'     #  Correct
PATH=/Applications/My App.app       #  Wrong!

# Path construction
CONFIG="$HOME/.config"  #  Variable quoted
CONFIG=$HOME/.config    #  Dangerous - quote the variable!
```

**File extensions:**

```bash
EXT='.txt'              #  Better

# Pattern matching extensions
[[ "$file" == *.txt ]]      #  Glob pattern
[[ "$file" == '*.txt' ]]    #  Literal match
```

**Recommendation summary:**

**Acceptable unquoted:**
- Single-word alphanumeric values: `value`, `INFO`, `true`, `42`
- Simple paths without spaces: `/usr/local/bin`
- File extensions: `.txt`, `.log`
- Version numbers: `1.0.0`, `2.5.3-beta`

**Mandatory quoting:**
- Any value with spaces: `'hello world'`
- Any value with special characters: `'admin@example.com'`, `'*.txt'`
- Empty strings: `''`
- Values with quotes or backslashes: `'don'\''t'`, `'C:\path'`

**Best practice:** Always quote everything except the most trivial cases. When in doubt, quote it. The small reduction in visual noise is not worth the mental overhead or risk of bugs when values change.

**Summary:**

- **One-word literals** - alphanumeric, underscore, hyphen, dot, slash only
- **Acceptable unquoted** - in assignments and conditionals (simple cases)
- **Better to quote** - more defensive, prevents future bugs
- **Mandatory quoting** - spaces, special characters, wildcards, empty strings
- **Always quote variables** - `"$var"` not `$var`
- **Consistency matters** - pick quoted or unquoted, stick with it
- **Default to quoting** - when in doubt, quote everything

**Key principle:** The one-word literal exception exists to acknowledge common practice, not to recommend it. Unquoted literals cause subtle bugs when values change. The safest approach is to quote everything. Use unquoted literals sparingly, only for trivial cases, never for values that might change or contain special characters. When establishing team standards, consider requiring quotes everywhere - it eliminates quoting decisions and makes scripts more robust.
