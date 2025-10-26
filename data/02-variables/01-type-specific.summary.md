## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**

- **Type Safety**: Integer declarations (`-i`) enforce numeric operations and catch non-numeric assignments
- **Intent Documentation**: Explicit types serve as inline documentation
- **Array Safety**: Array declarations prevent accidental scalar assignment
- **Scope Control**: `declare`/`local` provide precise variable scoping
- **Performance**: Type-specific operations are faster than string-based operations
- **Error Prevention**: Type mismatches caught early

**All declaration types:**

**1. Integer variables (`declare -i`)**

Variables holding numeric values for arithmetic operations.

```bash
declare -i count=0
declare -i exit_code=1
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"

# Type enforcement
count='abc'  # Evaluates to 0 (non-numeric becomes 0)
echo "$count"  # Output: 0
```

**Use for:** Counters, loop indices, exit codes, port numbers, numeric flags, any arithmetic operations.

**2. String variables (`declare --`)**

Variables holding text strings. The `--` prevents option injection.

```bash
declare -- filename='data.txt'
declare -- user_input=''
declare -- config_path="/etc/app/config.conf"

# `--` prevents option injection if variable name starts with -
declare -- var_name='-weird'  # Without --, interpreted as option
```

**Use for:** File paths, user input, configuration values, text data.

**3. Indexed arrays (`declare -a`)**

Ordered lists indexed by integers (0, 1, 2, ...).

```bash
declare -a files=()
declare -a args=('one' 'two' 'three')

# Add elements
files+=('file1.txt')
files+=('file2.txt')

# Access elements
echo "${files[0]}"  # file1.txt
echo "${files[@]}"  # All elements
echo "${#files[@]}"  # Count: 2

# Iterate
for file in "${files[@]}"; do
  process "$file"
done
```

**Use for:** Lists of items (files, arguments, options), command arrays, any sequential collection.

**4. Associative arrays (`declare -A`)**

Key-value maps (hash tables, dictionaries).

```bash
declare -A config=(
  [app_name]='myapp'
  [app_port]='8080'
  [app_host]='localhost'
)

# Add/modify elements
declare -A user_data=()
user_data[name]='Alice'
user_data[email]='alice@example.com'

# Access elements
echo "${config[app_name]}"  # myapp
echo "${!config[@]}"  # All keys
echo "${config[@]}"  # All values

# Check if key exists
if [[ -v "config[app_port]" ]]; then
  echo "Port configured: ${config[app_port]}"
fi

# Iterate over keys
for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

**Use for:** Configuration data (key-value pairs), dynamic function dispatch, caching/memoization.

**5. Read-only constants (`readonly --`)**

Variables that never change after initialization.

```bash
readonly -- VERSION='1.0.0'
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=('start' 'stop' 'restart' 'status')

# Attempt to modify fails
VERSION='2.0.0'  # bash: VERSION: readonly variable
```

**Use for:** VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration values, magic numbers/strings.

**6. Local variables in functions (`local`)**

Variables scoped to function, not visible outside.

```bash
process_file() {
  local -- filename="$1"
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"

  echo "Processed $line_count lines"
}

# filename, line_count, lines don't exist here
```

**Use for:** ALL function parameters, ALL temporary variables in functions.

**Combining type and scope:**

```bash
# Global declarations
declare -i GLOBAL_COUNT=0
declare -a PROCESSED_FILES=()
declare -A FILE_STATUS=()
readonly -- CONFIG_FILE='config.conf'

# Function with local typed variables
count_files() {
  local -- dir="$1"
  local -i file_count=0
  local -a files

  files=("$dir"/*)

  for file in "${files[@]}"; do
    [[ -f "$file" ]] && ((file_count+=1))
  done

  echo "$file_count"
}
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

# Integer variables
declare -i VERBOSE=0
declare -i ERROR_COUNT=0
declare -i MAX_RETRIES=3

# String variables
declare -- LOG_FILE="/var/log/$SCRIPT_NAME.log"
declare -- CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Indexed arrays
declare -a FILES_TO_PROCESS=()
declare -a FAILED_FILES=()

# Associative arrays
declare -A CONFIG=([timeout]='30' [retries]='3' [verbose]='false')
declare -A FILE_CHECKSUMS=()

# Color Definitions
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

# Utility Functions
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    info)    prefix+=" ${CYAN}É${NC}" ;;
    warn)    prefix+=" ${YELLOW}²${NC}" ;;
    success) prefix+=" ${GREEN}${NC}" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }

# Business Logic Functions
process_file() {
  local -- input_file="$1"
  local -i attempt=0 success=0
  local -- checksum

  while ((attempt < MAX_RETRIES && !success)); do
    ((attempt+=1))
    info "Processing $input_file (attempt $attempt)"

    if process_command "$input_file"; then
      success=1
      checksum=$(sha256sum "$input_file" | cut -d' ' -f1)
      FILE_CHECKSUMS["$input_file"]="$checksum"
      info "Success: $input_file ($checksum)"
    else
      warn "Failed: $input_file (attempt $attempt/$MAX_RETRIES)"
      ((ERROR_COUNT+=1))
    fi
  done

  if ((success)); then
    return 0
  else
    FAILED_FILES+=("$input_file")
    return 1
  fi
}

main() {
  FILES_TO_PROCESS=("$SCRIPT_DIR"/data/*.txt)

  local -- file
  for file in "${FILES_TO_PROCESS[@]}"; do
    process_file "$file"
  done

  info "Processed: ${#FILES_TO_PROCESS[@]} files"
  info "Errors: $ERROR_COUNT"
  info "Failed: ${#FAILED_FILES[@]} files"

  local -- filename
  for filename in "${!FILE_CHECKSUMS[@]}"; do
    info "Checksum: $filename = ${FILE_CHECKSUMS[$filename]}"
  done

  ((ERROR_COUNT == 0))
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - no type declaration
count=0
files=()

#  Correct - explicit type declarations
declare -i count=0
declare -a files=()

#  Wrong - strings for numeric operations
max_retries='3'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

#  Correct - integers for numeric operations
declare -i max_retries=3
declare -i attempts=0
if ((attempts < max_retries)); then

#  Wrong - forgetting -A for associative arrays
declare CONFIG  # Creates scalar, not associative array
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

#  Correct - explicit associative array declaration
declare -A CONFIG=()
CONFIG[key]='value'

#  Wrong - global variables in functions
process_data() {
  temp_var="$1"  # Global variable leak!
}

#  Correct - local variables in functions
process_data() {
  local -- temp_var="$1"
}

#  Wrong - forgetting -- separator
declare filename='-weird'  # Interpreted as option!

#  Correct - use -- separator
declare -- filename='-weird'

#  Wrong - scalar assignment to array
declare -a files=()
files='file.txt'  # Overwrites array with scalar!

#  Correct - array assignment
declare -a files=()
files=('file.txt')  # Array with one element
files+=('file.txt')  # Or append

#  Wrong - readonly without type
readonly VAR='value'

#  Correct - combine readonly with type
readonly -- VAR='value'
readonly -i COUNT=10
```

**Edge cases:**

**1. Integer overflow:**

```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed int
((big_number+=1))
echo "$big_number"  # Wraps to negative!

# For very large numbers, use string or bc
declare -- big='99999999999999999999'
result=$(bc <<< "$big + 1")
```

**2. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr4='string'     # Creates scalar, not array!
declare -a arr5=('string')   # Array with one element
```

**3. Nameref variables (Bash 4.3+):**

```bash
# Pass array by reference
modify_array() {
  local -n arr_ref=$1  # Nameref to array
  arr_ref+=('new element')
}

declare -a my_array=('a' 'b')
modify_array my_array  # Pass name, not value
echo "${my_array[@]}"  # Output: a b new element
```

**Summary:**

- **`declare -i`** for integers (counters, exit codes, ports)
- **`declare --`** for strings (paths, text, user input)
- **`declare -a`** for indexed arrays (lists, sequences)
- **`declare -A`** for associative arrays (key-value maps, configs)
- **`readonly --`** for constants
- **`local`** for ALL function variables
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`
- **Always use `--`** to prevent option injection

**Key principle:** Explicit type declarations serve as inline documentation and enable type checking. When you declare `declare -i count=0`, you're telling both Bash and future readers: "This variable holds an integer and will be used in arithmetic operations."
