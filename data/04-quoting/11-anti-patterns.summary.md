## Anti-Patterns (What NOT to Do)

**Common quoting mistakes that cause bugs, security vulnerabilities, and poor code quality. Each shows incorrect () and correct () forms.**

**Rationale:**
- **Security**: Improper quoting enables code/command injection attacks
- **Reliability**: Unquoted variables cause word splitting and glob expansion bugs
- **Consistency**: Mixed styles reduce readability
- **Performance**: Unnecessary quoting/bracing adds parsing overhead
- **Maintenance**: Anti-patterns make scripts fragile

**Category 1: Double quotes for static strings**

```bash
#  Wrong - double quotes for static strings
info "Checking prerequisites..."
readonly ERROR_MSG="Invalid input"

#  Correct - single quotes for static strings
info 'Checking prerequisites...'
readonly ERROR_MSG='Invalid input'

#  Wrong - double quotes in case patterns
case "$action" in
  "start") start_service ;;
esac

#  Correct - unquoted one-word patterns
case "$action" in
  start) start_service ;;
esac
```

**Category 2: Unquoted variables**

```bash
#  Wrong - unquoted variable
[[ -f $file ]]
rm $temp_file
for item in ${items[@]}; do process $item; done

#  Correct - quoted variables
[[ -f "$file" ]]
rm "$temp_file"
for item in "${items[@]}"; do process "$item"; done
```

**Category 3: Unnecessary braces**

```bash
#  Wrong - braces not needed
echo "${HOME}/bin"
[[ -f "${file}" ]]

#  Correct - no braces when not needed
echo "$HOME/bin"
[[ -f "$file" ]]

# When braces ARE needed:
echo "${HOME:-/tmp}"        # Default value
echo "${file##*/}"          # Parameter expansion
echo "${array[@]}"          # Array expansion
echo "${var1}${var2}"       # Adjacent variables
```

**Category 4: Mixing quote styles inconsistently**

```bash
#  Wrong - inconsistent quoting
info "Starting process..."
success 'Process complete'

#  Correct - consistent quoting
info 'Starting process...'
success 'Process complete'
```

**Category 5: Quote escaping nightmares**

```bash
#  Wrong - excessive escaping
message="It's \"really\" important"

#  Correct - use single quotes or $'...'
message='It'\''s "really" important'
message=$'It\'s "really" important'
```

**Category 6: Glob expansion dangers**

```bash
#  Wrong - unquoted variable with glob characters
pattern='*.txt'
echo $pattern        # Expands to all .txt files!

#  Correct - quoted to preserve literal
echo "$pattern"      # Outputs: *.txt
```

**Category 7: Command substitution quoting**

```bash
#  Wrong - unquoted command substitution
result=$(command)
echo $result         # Word splitting on result!

#  Correct - quoted command substitution
result=$(command)
echo "$result"       # Preserves whitespace
```

**Category 8: Here-document quoting**

```bash
#  Wrong - quoted delimiter when variables needed
cat <<"EOF"
User: $USER          # Not expanded
EOF

#  Correct - unquoted for expansion, quoted for literal
cat <<EOF
User: $USER          # Expands
EOF

cat <<'EOF'
{
  "api_key": "$API_KEY"    # Literal
}
EOF
```

**Complete example comparison:**

```bash
#  WRONG VERSION - Full of anti-patterns
VERSION="1.0.0"                              #  Double quotes for static
SCRIPT_PATH=${0}                             #  Unquoted
BIN_DIR="${PREFIX}/bin"                      #  Braces not needed

info "Starting ${SCRIPT_NAME}..."            #  Double quotes + braces

check_file() {
  local file=$1                              #  Unquoted
  if [[ -f $file ]]; then                    #  Unquoted
    info "Processing ${file}..."             #  Braces not needed
  fi
}

for file in ${files[@]}; do                  #  Unquoted - breaks on spaces!
  check_file $file                           #  Unquoted
done

#  CORRECT VERSION
declare -r VERSION='1.0.0'                   #  Single quotes
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")   #  Quoted
BIN_DIR="$PREFIX/bin"                        #  No braces

info 'Starting script...'                    #  Single quotes

check_file() {
  local -- file="$1"                         #  Quoted
  if [[ -f "$file" ]]; then                  #  Quoted
    info "Processing $file..."               #  No braces
  fi
}

for file in "${files[@]}"; do                #  Quoted array
  check_file "$file"                         #  Quoted
done
```

**Quick reference checklist:**

```bash
# Static strings ’ Single quotes
'literal text'                
"literal text"                

# Variables in strings ’ Double quotes, no braces
"text with $var"              
"text with ${var}"            

# Variables everywhere ’ Quoted
echo "$var"                   
[[ -f "$file" ]]              
echo $var                     

# Array expansion ’ Quoted
"${array[@]}"                 
${array[@]}                   

# Braces ’ Only when needed
"${var##*/}"                   (parameter expansion)
"${array[@]}"                  (array)
"${var1}${var2}"               (adjacent)
"${HOME}"                      (not needed)
```

**Summary:**
- **Never use double quotes for static strings** - use single quotes
- **Always quote variables** - in conditionals, assignments, commands
- **Don't use braces unless required** - parameter expansion, arrays, adjacent variables only
- **Quote array expansions** - `"${array[@]}"` is mandatory
- **Be consistent** - don't mix quote styles
- **Choose right quote type** - single for literal, double for variables

**Key principle:** Quoting anti-patterns make code fragile and insecure. Quote variables, use single quotes for static text, avoid unnecessary braces.