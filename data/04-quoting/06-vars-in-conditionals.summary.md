## Variables in Conditionals

**Always quote variables in test expressions to prevent word splitting and glob expansion. Variable quoting in conditionals is mandatory; static comparison values follow normal quoting rules (single quotes for literals, unquoted for one-word values).**

**Rationale:**

- **Word Splitting Protection**: Unquoted variables undergo word splitting, breaking multi-word values into separate tokens
- **Glob Expansion Safety**: Unquoted variables trigger pathname expansion if they contain wildcards (`*`, `?`, `[`)
- **Empty Value Safety**: Unquoted empty variables disappear entirely, causing syntax errors in conditionals
- **Security**: Prevents injection attacks where malicious input could exploit word splitting
- **Consistent Behavior**: Quoting ensures predictable behavior regardless of variable content

**Core quoting patterns:**

**1. File test operators (always quote variables):**

```bash
# File tests
[[ -f "$file" ]]         #  Correct
[[ -f $file ]]           #  Wrong - word splitting if spaces

[[ -d "$path" ]]         # Directory
[[ -r "$config_file" ]]  # Readable
[[ -w "$log_file" ]]     # Writable
[[ -e "$file" ]]         # Exists
[[ -s "$file" ]]         # Non-empty
[[ -x "$binary" ]]       # Executable
[[ -L "$link" ]]         # Symbolic link
```

**2. String comparisons (quote variables, static values follow normal rules):**

```bash
# Equality/inequality - quote variables
[[ "$name" == "$expected" ]]    #  Both variables quoted
[[ "$name" != "$other" ]]       #  Correct

# One-word literals can be unquoted
[[ "$action" == start ]]        #  Acceptable
[[ "$action" == 'start' ]]      #  Also correct

# Multi-word literals need single quotes
[[ "$message" == 'hello world' ]]        #  Correct
[[ "$message" == hello world ]]          #  Syntax error

# Special characters need quotes
[[ "$input" == 'user@domain.com' ]]      #  Correct
[[ "$path" == '/usr/local/bin' ]]        #  Correct

# Empty/non-empty tests
[[ -n "$value" ]]               # Non-empty test
[[ -z "$value" ]]               # Empty test
```

**3. Integer comparisons (quote variables):**

```bash
[[ "$count" -eq 0 ]]            #  Correct
[[ "$count" -gt 10 ]]           # Greater than
[[ "$age" -le 18 ]]             # Less than or equal

# All operators: -eq, -ne, -lt, -le, -gt, -ge
[[ "$a" -eq "$b" ]]             # Equal
[[ "$a" -ne "$b" ]]             # Not equal
```

**4. Logical operators:**

```bash
# AND/OR/NOT - quote all variables
[[ -f "$file" && -r "$file" ]]  #  Both quoted
[[ -f "$file1" || -f "$file2" ]] #  Correct
[[ ! -f "$file" ]]               #  Correct

# Complex conditions
[[ -f "$config" && -r "$config" && -s "$config" ]]
```

**Pattern matching in conditionals:**

**1. Glob patterns (variable quoted, pattern unquoted for matching):**

```bash
# Pattern matching - right side unquoted enables globbing
[[ "$filename" == *.txt ]]               #  Matches any .txt file
[[ "$filename" == *.@(jpg|png) ]]        #  Extended glob
[[ "$filename" == data_[0-9]*.csv ]]     #  Character class

# Quoting pattern makes it literal
[[ "$filename" == '*.txt' ]]             #  Matches literal "*.txt" only
```

**2. Regex patterns (use =~ operator, pattern unquoted):**

```bash
# Regex matching - pattern unquoted or in variable
[[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]  #  Inline regex
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] #  Semver

# Pattern in variable (unquote the variable)
pattern='^[0-9]{3}-[0-9]{4}$'
[[ "$phone" =~ $pattern ]]               #  Correct
[[ "$phone" =~ "$pattern" ]]             #  Wrong - treats as literal
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

validate_file() {
  local -- file="$1"
  local -- required_ext="$2"

  # File tests - variables quoted
  [[ ! -f "$file" ]] && { error "File not found: $file"; return 2; }
  [[ ! -r "$file" ]] && { error "File not readable: $file"; return 5; }
  [[ ! -s "$file" ]] && { error "File is empty: $file"; return 22; }

  # Extension check - pattern matching
  if [[ "$file" == *."$required_ext" ]]; then
    info "File has correct extension: .$required_ext"
  else
    error "File must have .$required_ext extension"
    return 22
  fi
  return 0
}

process_config() {
  local -- config_file="$1"
  local -- key value

  while IFS='=' read -r key value; do
    # Empty/comment checks - variables quoted
    [[ -z "$key" ]] && continue
    [[ "$key" == \#* ]] && continue

    # String comparison - quote variables
    if [[ "$key" == 'timeout' ]]; then
      # Integer comparison - quote variable
      if [[ "$value" -gt 0 ]]; then
        info "Timeout: $value seconds"
      else
        error "Timeout must be positive: $value"
        return 22
      fi
    elif [[ "$key" == 'mode' ]]; then
      # Multi-value check
      if [[ "$value" == 'production' || "$value" == 'development' ]]; then
        info "Mode: $value"
      else
        error "Invalid mode: $value"
        return 22
      fi
    fi
  done < "$config_file"
}

validate_input() {
  local -- input="$1"
  local -- email_pattern='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

  # Empty/length checks - quote variables
  [[ -z "$input" ]] && { error 'Input cannot be empty'; return 22; }
  [[ "${#input}" -lt 3 ]] && { error "Input too short: minimum 3 characters"; return 22; }

  # Pattern matching - glob
  [[ "$input" == admin* ]] && { warn "Input starts with 'admin' - reserved prefix"; return 1; }

  # Regex matching - pattern variable unquoted
  if [[ "$input" =~ $email_pattern ]]; then
    info "Valid email format: $input"
  else
    error "Invalid email format: $input"
    return 22
  fi
  return 0
}

main() {
  local -- test_file='data.txt'
  local -- test_config='config.conf'

  validate_file "$test_file" 'txt' || die $? "File validation failed"
  [[ -f "$test_config" ]] && process_config "$test_config"
  validate_input 'user@example.com' || die $? "Input validation failed"
}

main "$@"

#fin
```

**Critical anti-patterns:**

```bash
#  Wrong - unquoted variable with spaces
[[ -f $file ]]
# If $file='my file.txt', becomes: [[ -f my file.txt ]]  # Syntax error!

#  Correct
[[ -f "$file" ]]

#  Wrong - unquoted variable with glob
file='*.txt'
[[ -f $file ]]  # Expands to all .txt files!

#  Correct
[[ -f "$file" ]]  # Tests for literal "*.txt" file

#  Wrong - unquoted empty variable
name=''
[[ -z $name ]]  # Becomes: [[ -z ]] - syntax error!

#  Correct
[[ -z "$name" ]]

#  Wrong - inconsistent quoting
[[ -f $file && -r "$file" ]]

#  Correct - consistent quoting
[[ -f "$file" && -r "$file" ]]

#  Wrong - double quotes for static literal
[[ "$mode" == "production" ]]

#  Correct - single quotes or unquoted
[[ "$mode" == 'production' ]]
[[ "$mode" == production ]]

#  Wrong - quoted regex pattern variable
pattern='^test'
[[ "$input" =~ "$pattern" ]]  # Treats as literal string

#  Correct - unquoted pattern variable
[[ "$input" =~ $pattern ]]
```

**Edge cases:**

**1. Variables with leading dashes:**

```bash
arg='-v'
[[ "$arg" == '-v' ]]  #  Quoted protects against option interpretation
```

**2. Unset variables with nounset:**

```bash
unset var
[[ -z "${var:-}" ]]  #  Safe with set -u
```

**3. Pattern vs literal matching:**

```bash
[[ "$file" == *.txt ]]       #  Pattern matching (glob)
[[ "$file" == '*.txt' ]]     #  Literal string match
```

**Legacy test [ ] command:**

```bash
# Old test - MUST quote (no exceptions)
[ -f "$file" ]               #  Correct
[ -f $file ]                 #  Dangerous!

[ "$var" = "value" ]         #  Correct (= not ==)
[ $var = value ]             #  Wrong

# Modern [[ ]] preferred
[[ -f "$file" ]]             #  Preferred
```

**Summary:**

- **Always quote variables** in all conditional tests
- **File tests**: `[[ -f "$file" ]]`
- **String comparisons**: `[[ "$var" == 'value' ]]` or `[[ "$var" == value ]]` (one-word)
- **Integer comparisons**: `[[ "$count" -eq 0 ]]`
- **Pattern matching**: `[[ "$file" == *.txt ]]` (variable quoted, pattern unquoted)
- **Regex matching**: `[[ "$input" =~ $pattern ]]` (variable quoted, pattern unquoted)
- **Consistency**: Quote all variables uniformly
- **Static literals**: Single quotes for multi-word/special chars, optional for one-word

**Key principle:** Variable quoting in conditionals is mandatory. Every variable reference in a test expression must be quoted for safe, predictable behavior. Static comparison values follow normal quoting rules.
