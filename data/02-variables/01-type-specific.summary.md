## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:**
- **Type Safety**: Integer `-i` enforces numeric operations; non-numeric becomes 0
- **Intent Documentation**: Types serve as inline documentation
- **Array Safety**: Prevents accidental scalar assignment breaking array operations
- **Scope Control**: `declare`/`local` provide precise scoping
- **Error Prevention**: Type mismatches caught early

### Declaration Types

**1. Integer (`declare -i`)** - Counters, exit codes, ports, flags, arithmetic variables
```bash
declare -i count=0
count=count+1     # Automatic arithmetic (no $(()) needed)
count='5 + 3'     # Evaluates to 8
count='abc'       # Evaluates to 0
```

**2. String (`declare --`)** - Paths, user input, config values, text data
```bash
declare -- filename='data.txt'
declare -- var_name='-weird'  # -- prevents option injection
```

**3. Indexed Array (`declare -a`)** - Lists, command arrays, sequential collections
```bash
declare -a files=()
files+=('file1.txt')
echo "${files[0]}"      # First element
echo "${files[@]}"      # All elements
echo "${#files[@]}"     # Count
for file in "${files[@]}"; do process "$file"; done
```

**4. Associative Array (`declare -A`)** - Key-value maps, configs, caching
```bash
declare -A config=([app_name]='myapp' [app_port]='8080')
echo "${config[app_name]}"   # Value by key
echo "${!config[@]}"         # All keys
[[ -v "config[app_port]" ]]  # Key exists check
for key in "${!config[@]}"; do echo "$key = ${config[$key]}"; done
```

**5. Read-only (`readonly --`)** - Constants: VERSION, SCRIPT_PATH, config values
```bash
readonly -- VERSION='1.0.0'
readonly -i MAX_RETRIES=3
readonly -a ALLOWED_ACTIONS=('start' 'stop' 'restart')
```

**6. Local (`local --`)** - ALL function variables (MANDATORY `--` separator)
```bash
process_file() {
  local -- filename="$1"    # ✓ Always use --
  local -i line_count       # ✓ Combine with type
  local -a lines
}
```

### Combining Type and Scope

```bash
declare -i GLOBAL_COUNT=0         # Global integer
declare -a PROCESSED_FILES=()     # Global array
declare -A FILE_STATUS=()         # Global associative array

count_files() {
  local -- dir="$1"
  local -i file_count=0
  local -a files=("$dir"/*)
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && ((file_count+=1))
  done
  echo "$file_count"
}
```

### Anti-Patterns

```bash
# ✗ No type declaration (intent unclear)
count=0
# ✓ Explicit type
declare -i count=0

# ✗ Strings for numeric operations
max_retries='3'
if [[ "$attempts" -lt "$max_retries" ]]; then  # String comparison!
# ✓ Integers for numeric operations
declare -i max_retries=3
if ((attempts < max_retries)); then

# ✗ Missing -A for associative arrays
declare CONFIG
CONFIG[key]='value'  # Treats 'key' as 0!
# ✓ Explicit -A
declare -A CONFIG=()

# ✗ Global leak in functions
process_data() { temp_var="$1"; }
# ✓ Local variables
process_data() { local -- temp_var="$1"; }

# ✗ Missing -- separator
declare filename='-weird'  # Interpreted as option!
# ✓ Use -- separator
declare -- filename='-weird'

# ✗ Scalar assignment to array
declare -a files=()
files='file.txt'  # Overwrites array!
# ✓ Array assignment
files=('file.txt')  # Or: files+=('file.txt')
```

### Edge Cases

**Integer overflow:**
```bash
declare -i big_number=9223372036854775807  # Max 64-bit signed
((big_number+=1))  # Wraps to negative!
# For large numbers: declare -- big='99999999999999999999'; result=$(bc <<< "$big + 1")
```

**Associative arrays require Bash 4.0+:**
```bash
if ((BASH_VERSINFO[0] < 4)); then die 1 'Associative arrays require Bash 4.0+'; fi
```

**Array assignment syntax:**
```bash
declare -a arr1=()           # Empty array
declare -a arr2=('a' 'b')    # Two elements
declare -a arr4='string'     # ✗ Creates scalar, not array!
declare -a arr5=('string')   # ✓ Array with one element
```

**Nameref variables (Bash 4.3+):**
```bash
modify_array() {
  local -n arr_ref=$1  # Nameref
  arr_ref+=('new element')
}
declare -a my_array=('a' 'b')
modify_array my_array
echo "${my_array[@]}"  # a b new element
```

### Summary

| Type | Declaration | Use For |
|------|-------------|---------|
| Integer | `declare -i` | Counters, exit codes, ports |
| String | `declare --` | Paths, text, user input |
| Indexed array | `declare -a` | Lists, sequences |
| Associative array | `declare -A` | Key-value maps, configs |
| Constant | `readonly --` | Immutable values |
| Function-local | `local --` | ALL function variables |

Combine modifiers: `local -i`, `local -a`, `readonly -A`. **Always use `--` separator.**
