## Anti-Patterns (What NOT to Do)

Common quoting mistakes that lead to bugs, security vulnerabilities, and poor code quality. Each shown as incorrect (✗) and correct (✓).

**Rationale:**
- Security: Improper quoting enables code/command injection attacks
- Reliability: Unquoted variables cause word splitting and glob expansion bugs
- Consistency: Mixed styles reduce readability
- Performance: Unnecessary quoting/bracing adds parsing overhead
- Maintenance: Anti-patterns create fragile, error-prone scripts

### Category 1: Double Quotes for Static Strings

Most common anti-pattern. Use single quotes for strings without variables.

```bash
# ✗ Wrong - double quotes for static strings
info "Checking prerequisites..."
readonly ERROR_MSG="Invalid input"

# ✓ Correct - single quotes for static strings
info 'Checking prerequisites...'
readonly ERROR_MSG='Invalid input'

# ✗ Wrong - double quotes in multi-line static content
cat <<EOF
{"name": "myapp", "version": "1.0.0"}
EOF

# ✓ Correct - quoted delimiter for literal here-doc
cat <<'EOF'
{"name": "myapp", "version": "1.0.0"}
EOF

# ✗ Wrong - double quotes in case patterns
case "$action" in
  "start") start_service ;;
  "stop")  stop_service ;;
esac

# ✓ Correct - unquoted one-word patterns
case "$action" in
  start) start_service ;;
  stop)  stop_service ;;
esac
```

### Category 2: Unquoted Variables

Dangerous and unpredictable - causes word splitting and glob expansion.

```bash
# ✗ Wrong - unquoted variables
[[ -f $file ]]
target=$source
echo Processing $file...
rm $temp_file
for item in ${items[@]}; do process $item; done

# ✓ Correct - quoted variables
[[ -f "$file" ]]
target="$source"
echo "Processing $file..."
rm "$temp_file"
for item in "${items[@]}"; do process "$item"; done
```

### Category 3: Unnecessary Braces

Use braces only when required for parameter expansion, arrays, or adjacent variables.

```bash
# ✗ Wrong - braces not needed
echo "${HOME}/bin"
path="${CONFIG_DIR}/app.conf"
[[ -f "${file}" ]]

# ✓ Correct - no braces when unnecessary
echo "$HOME/bin"
path="$CONFIG_DIR/app.conf"
[[ -f "$file" ]]

# ✓ Braces ARE needed:
echo "${HOME:-/tmp}"        # Default value
echo "${file##*/}"          # Parameter expansion
echo "${array[@]}"          # Array expansion
echo "${var1}${var2}"       # Adjacent variables
```

### Category 4: Unnecessary Braces + Wrong Quotes

Combines two anti-patterns.

```bash
# ✗ Wrong - both braces and wrong quotes
info "${PREFIX}/bin"
path="${HOME}/Documents"

# ✓ Correct
info "$PREFIX/bin"
path="$HOME/Documents"
```

### Category 5: Inconsistent Quoting

Inconsistent styles confuse readers.

```bash
# ✗ Wrong - mixed styles
info "Starting process..."
success 'Process complete'
[[ -f $file && -r "$file" ]]

# ✓ Correct - consistent
info 'Starting process...'
success 'Process complete'
[[ -f "$file" && -r "$file" ]]
```

### Category 6: Quote Escaping Nightmares

Choose correct quote type to minimize escaping.

```bash
# ✗ Wrong - excessive escaping
message="It's \"really\" important"

# ✓ Correct - use single quotes or $'...'
message='It'\''s "really" important'
message=$'It\'s "really" important'

# ✗ Wrong - escaping backslashes when not needed
path="C:\\Users\\Documents"

# ✓ Correct - single quotes for literals
path='C:\Users\Documents'
```

### Category 7: Glob Expansion Dangers

Unquoted variables trigger unwanted glob expansion.

```bash
# ✗ Wrong - unquoted with glob characters
pattern='*.txt'
echo $pattern        # Expands to all .txt files!
[[ -f $pattern ]]    # Tests all .txt files!

# ✓ Correct - quoted preserves literal
echo "$pattern"      # Outputs: *.txt
[[ -f "$pattern" ]]  # Tests for file named "*.txt"
```

### Category 8: Command Substitution Quoting

```bash
# ✗ Wrong - unquoted command substitution
result=$(command)
echo $result         # Word splitting!

# ✓ Correct - quoted output
result=$(command)
echo "$result"       # Preserves whitespace

# ✗ Wrong - unnecessary braces
version=$(cat "${VERSION_FILE}")

# ✓ Correct - minimal quoting
version=$(cat "$VERSION_FILE")
```

### Category 9: Here-Document Quoting

```bash
# ✗ Wrong - quoted delimiter when expansion needed
cat <<"EOF"
User: $USER          # Not expanded - stays as $USER
EOF

# ✓ Correct - unquoted for expansion
cat <<EOF
User: $USER          # Expands to actual user
EOF

# ✗ Wrong - unquoted for literal JSON
cat <<EOF
{"api_key": "$API_KEY"}    # Expands variable (dangerous!)
EOF

# ✓ Correct - quoted delimiter for literals
cat <<'EOF'
{"api_key": "$API_KEY"}    # Stays as $API_KEY
EOF
```

### Category 10: Special Characters

```bash
# ✗ Wrong - unquoted special characters
email=user@domain.com     # @ has special meaning!
file=test(1).txt          # () are special!

# ✓ Correct - quoted
email='user@domain.com'
file='test(1).txt'
```

### Complete Example: Before and After

```bash
# ✗ WRONG VERSION - Anti-patterns
VERSION="1.0.0"                          # Double quotes for static
SCRIPT_PATH=${0}                         # Unquoted
BIN_DIR="${PREFIX}/bin"                  # Braces not needed
info "Starting ${SCRIPT_NAME}..."        # Double quotes + braces

check_file() {
  local file=$1                          # Unquoted
  if [[ -f $file ]]; then                # Unquoted
    info "Processing ${file}..."         # Braces not needed
  fi
}

files=(file1.txt "file 2.txt")
for file in ${files[@]}; do              # Unquoted - breaks on spaces!
  check_file $file
done

# ✓ CORRECT VERSION
declare -r VERSION='1.0.0'               # Single quotes
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")  # Quoted
BIN_DIR="$PREFIX/bin"                    # No braces
info 'Starting script...'                # Single quotes

check_file() {
  local -- file="$1"                     # Quoted
  if [[ -f "$file" ]]; then              # Quoted
    info "Processing $file..."           # No braces
  fi
}

declare -a files=('file1.txt' 'file 2.txt')
for file in "${files[@]}"; do            # Quoted array
  check_file "$file"
done
```

### Quick Reference Checklist

```bash
# Static strings ' Single quotes
'literal text'                ✓
"literal text"                ✗

# Variables in strings ' Double quotes, no braces
"text with $var"              ✓
"text with ${var}"            ✗

# Variables in commands/conditionals ' Quoted
echo "$var"                   ✓
[[ -f "$file" ]]              ✓
echo $var                     ✗

# Array expansion ' Quoted
"${array[@]}"                 ✓
${array[@]}                   ✗

# Braces ' Only when needed
"${var##*/}"                  ✓ (parameter expansion)
"${array[@]}"                 ✓ (array)
"${var1}${var2}"              ✓ (adjacent)
"${var:-default}"             ✓ (default)
"${HOME}"                     ✗ (unnecessary)

# One-word literals ' Unquoted or single quotes
[[ "$var" == value ]]         ✓
[[ "$var" == "value" ]]       ✗

# Command substitution ' Quote variable, not path
result=$(cat "$file")         ✓
result=$(cat "${file}")       ✗

# Here-docs ' Quote delimiter for literal
cat <<'EOF'                   ✓ (literal)
cat <<EOF                     ✓ (expand variables)
```

**Summary:**
- Never use double quotes for static strings - use single quotes
- Always quote variables in conditionals, assignments, commands, expansions
- Don't use braces unless required (parameter expansion, arrays, adjacent variables)
- Quote array expansions: `"${array[@]}"` is mandatory
- Be consistent - don't mix quote styles
- Choose quote type to minimize escaping

**Key principle:** Quoting anti-patterns create fragile, insecure, hard-to-maintain code. Proper quoting eliminates entire classes of bugs. When in doubt: quote variables, use single quotes for static text, avoid unnecessary braces.
