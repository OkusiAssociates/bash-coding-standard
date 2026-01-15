## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- **Type Safety**: Integer declarations (`-i`) enforce numeric operations; non-numeric becomes 0
- **Intent Documentation**: Types serve as inline documentation for variable usage
- **Array Safety**: Prevents accidental scalar assignment breaking array operations
- **Scope Control**: `declare`/`local` provide precise variable scoping
- **Error Prevention**: Type mismatches caught early rather than causing subtle bugs

### Declaration Types

**1. Integer variables (`declare -i`)**

```bash
declare -i count=0
declare -i exit_code=1
declare -i port=8080

# Automatic arithmetic evaluation
count=count+1  # Same as: ((count+=1))
count='5 + 3'  # Evaluates to 8, not string "5 + 3"
count='abc'    # Evaluates to 0 (non-numeric becomes 0)
```

Use for: counters, loop indices, exit codes, port numbers, any arithmetic operations.

> **See Also:** BCS0705 for using declared integers in arithmetic comparisons with `(())` instead of `[[ ... -eq ... ]]`

**2. String variables (`declare --`, `local --`)**

```bash
declare -- filename=data.txt
declare -- user_input=''
declare -- config_path=/etc/app/config.conf

# `--` prevents option injection if variable name starts with -
declare -- var_name='-weird'  # Without --, interpreted as option
```

Use for: file paths, user input, configuration values, any text data.

**3. Indexed arrays (`declare -a`)**

```bash
declare -a files=()
declare -a args=(one two three)

files+=('file1.txt')
echo "${files[0]}"   # file1.txt
echo "${files[@]}"   # All elements
echo "${#files[@]}"  # Count

for file in "${files[@]}"; do
  process "$file"
done
```

Use for: lists of items, command arrays, any sequential collection.

**4. Associative arrays (`declare -A`)**

```bash
declare -A config=(
  [app_name]=myapp
  [app_port]=8080
  [app_host]=localhost
)

user_data[name]=Alice
echo "${config[app_name]}"  # myapp
echo "${!config[@]}"        # All keys

# Check if key exists
if [[ -v "config[app_port]" ]]; then
  echo "Port: ${config[app_port]}"
fi

for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done
```

Use for: configuration data, dynamic function dispatch, caching, key-value data.

**5. Read-only constants (`declare -r`)**

```bash
declare -r SCRIPT_VERSION=1.0.0
declare -ir MAX_RETRIES=3
declare -ar ALLOWED_ACTIONS=(start stop restart status)

SCRIPT_VERSION=2.0.0  # bash: VERSION: readonly variable
```

Use for: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, configuration constants.

**6. Local variables in functions (`local --`)**

**MANDATORY: Always use `--` separator with `local` declarations.**

```bash
# ✓ CORRECT - always use `--` separator
process_file() {
  local -- filename=$1
  local -i line_count
  local -a lines

  line_count=$(wc -l < "$filename")
  readarray -t lines < "$filename"
}

# ✗ WRONG - missing `--` separator
process_file_bad() {
  local filename=$1    # If $1 is "-n", behavior changes!
  local name value     # Should be: local -- name value
}
```

Use `local` for ALL function parameters and temporary variables.

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

### Anti-patterns

```bash
# ✗ No type declaration (intent unclear)
count=0
files=()

# ✓ Explicit type declarations
declare -i count=0
declare -a files=()

# ✗ Using strings for numeric operations
max_retries='3'
attempts='0'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!

# ✓ Use integers for numeric operations
declare -i max_retries=3
declare -i attempts=0
if ((attempts < max_retries)); then  # Numeric comparison

# ✗ Forgetting -A for associative arrays
declare CONFIG  # Creates scalar, not associative array
CONFIG[key]='value'  # Treats 'key' as 0, creates indexed array!

# ✓ Explicit associative array declaration
declare -A CONFIG=()
CONFIG[key]='value'

# ✗ Global variables in functions
process_data() {
  temp_var=$1  # Global variable leak!
}

# ✓ Local variables in functions
process_data() {
  local -- temp_var=$1
  local -- result
  result=$(process "$temp_var")
}

# ✗ Scalar assignment to array variable
declare -a files=()
files=file.txt  # Overwrites array with scalar!

# ✓ Array assignment
files=(file.txt)   # Array with one element
files+=(file.txt)  # Append to array
```

### Edge Cases

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
```

**3. Array assignment syntax:**

```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Array with 2 elements
declare -a arr3              # Declare without initialization
declare -a arr4='string'     # arr4 is string, NOT array!
declare -a arr5=('string')   # Array with one element
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

### Summary

| Type | Declaration | Use Case |
|------|-------------|----------|
| Integer | `declare -i` | counters, exit codes, ports |
| String | `declare --` | paths, text, user input |
| Indexed array | `declare -a` | lists, sequences |
| Associative array | `declare -A` | key-value maps, configs |
| Constant | `declare -r` | immutable values |
| Local | `local --` | ALL function variables |

Combine modifiers: `local -i`, `local -a`, `readonly -A`. Always use `--` separator to prevent option injection.
