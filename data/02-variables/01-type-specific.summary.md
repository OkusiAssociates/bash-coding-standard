## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- Type Safety: Integer declarations (`-i`) enforce numeric operations, catch non-numeric assignments
- Intent Documentation: Types serve as inline documentation showing variable usage
- Array Safety: Prevents accidental scalar assignment breaking array operations
- Performance: Type-specific operations are faster than string-based operations
- Error Prevention: Type mismatches caught early rather than causing subtle bugs

**All declaration types:**

**1. Integer variables (`declare -i`)**

```bash
declare -i count=0
declare -i exit_code=1
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"

# Type enforcement
count='abc'  # Evaluates to 0 (non-numeric becomes 0)
```

**Use for:** Counters, loop indices, exit codes, port numbers, numeric flags, any variable in arithmetic operations.

> **See Also:** BCS0705 for using declared integers in arithmetic comparisons with `(())` instead of `[[ ... -eq ... ]]`

**2. String variables (`declare --`, `local --`)**

```bash
declare -- filename=data.txt
declare -- user_input=''
declare -- config_path=/etc/app/config.conf

# `--` prevents option injection if variable name starts with -
declare -- var_name='-weird'  # Without --, interpreted as option
```

**Use for:** File paths, user input, configuration values, any text data. Default choice for most variables.

**3. Indexed arrays (`declare -a`)**

```bash
declare -a files=()
declare -a args=(one two three)

files+=('file1.txt')
files+=('file2.txt')

echo "${files[0]}"   # file1.txt
echo "${files[@]}"   # All elements
echo "${#files[@]}"  # Count: 2

for file in "${files[@]}"; do
  process "$file"
done
```

**Use for:** Lists of items (files, arguments, options), command arrays, any sequential collection.

**4. Associative arrays (`declare -A`)**

```bash
declare -A config=(
  [app_name]=myapp
  [app_port]=8080
  [app_host]=localhost
)

declare -A user_data=()
user_data[name]=Alice
user_data[email]='alice@example.com'

echo "${config[app_name]}"  # myapp
echo "${!config[@]}"        # All keys
echo "${config[@]}"         # All values

# Check if key exists
if [[ -v "config[app_port]" ]]; then
  echo "Port configured: ${config[app_port]}"
fi

for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

**Use for:** Configuration data (key-value pairs), dynamic function dispatch, caching/memoization.

**5. Read-only constants (`readonly --`)**

```bash
readonly -- VERSION=1.0.0
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=(start stop restart status)

VERSION=2.0.0  # bash: VERSION: readonly variable
```

**Use for:** VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration values that shouldn't change, magic numbers/strings.

**6. Local variables in functions (`local --`)**

**MANDATORY: Always use `--` separator with `local` declarations.** Prevents option injection if variable name or value starts with `-`.

```bash
# ✓ CORRECT - always use `--` separator
process_file() {
  local -- filename=$1
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"
  echo "Processed $line_count lines"
}

# ✗ WRONG - missing `--` separator
process_file_bad() {
  local filename=$1    # If $1 is "-n", behavior changes!
  local name value     # Should be: local -- name value
}
```

**Use for:** ALL function parameters, ALL temporary variables in functions, variables that shouldn't leak to global scope.

**Combining type and scope:**

```bash
declare -i GLOBAL_COUNT=0

function count_files() {
  local -- dir=$1
  local -i file_count=0
  local -a files

  files=("$dir"/*)

  for file in "${files[@]}"; do
    [[ -f "$file" ]] && file_count+=1 ||:
  done

  echo "$file_count"
}

declare -a PROCESSED_FILES=()
declare -A FILE_STATUS=()
readonly -- CONFIG_FILE=config.conf
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - no type declaration (intent unclear)
count=0
files=()

# ✓ Correct - explicit type declarations
declare -i count=0
declare -a files=()

# ✗ Wrong - using strings for numeric operations
max_retries='3'
attempts='0'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

# ✓ Correct - use integers for numeric operations
declare -i max_retries=3
declare -i attempts=0
if ((attempts < max_retries)); then  # Numeric comparison

# ✗ Wrong - forgetting -A for associative arrays
declare CONFIG  # Creates scalar, not associative array
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

# ✓ Correct - explicit associative array declaration
declare -A CONFIG=()
CONFIG[key]='value'

# ✗ Wrong - global variables in functions
process_data() {
  temp_var=$1  # Global variable leak!
}

# ✓ Correct - local variables in functions
process_data() {
  local -- temp_var=$1
}

# ✗ Wrong - scalar assignment to array variable
declare -a files=()
files=file.txt  # Overwrites array with scalar!

# ✓ Correct - array assignment
declare -a files=()
files=(file.txt)   # Array with one element
files+=(file.txt)  # Append to array
```

**Edge cases:**

**1. Integer overflow:**

```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed int
big_number+=1
echo "$big_number"  # Wraps to negative!

# For very large numbers, use string or bc
declare -- big='99999999999999999999'
result=$(bc <<< "$big + 1")
```

**2. Associative array requires Bash 4.0+:**

```bash
if ((BASH_VERSINFO[0] < 4)); then
  die 1 'Associative arrays require Bash 4.0+'
fi
declare -A config=()
```

**3. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr3              # Declare without initialization

declare -a arr4='string'     # arr4 is string 'string', not array!
declare -a arr5=('string')   # Correct: Array with one element
```

**4. Nameref variables (Bash 4.3+):**

```bash
modify_array() {
  local -n arr_ref=$1  # Nameref to array
  arr_ref+=('new element')
}

declare -a my_array=('a' 'b')
modify_array my_array  # Pass name, not value
echo "${my_array[@]}"  # Output: a b new element
```

**Summary:**
- **`declare -i`**: integers (counters, exit codes, ports)
- **`declare --`**: strings (paths, text, user input)
- **`declare -a`**: indexed arrays (lists, sequences)
- **`declare -A`**: associative arrays (key-value maps, configs)
- **`readonly --`**: constants that shouldn't change
- **`local`**: ALL variables in functions (prevent global leaks)
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`
- **Always use `--`**: separator prevents option injection

**Key principle:** Explicit type declarations serve as inline documentation and enable type checking. `declare -i count=0` tells both Bash and readers: "This variable holds an integer for arithmetic operations."
