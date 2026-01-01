### Arrays

**Rule: BCS0207**

Array declaration, usage, and safe list handling.

---

#### Rationale

Arrays preserve element boundaries regardless of content, prevent word splitting with `"${array[@]}"`, protect wildcards from glob expansion, and enable safe command construction with arbitrary arguments.

---

#### Declaration

```bash
# Indexed arrays (explicit declaration)
declare -a paths=()           # Empty array
declare -a colors=(red green blue)

# Local arrays in functions
local -a found_files=()

# Associative arrays (Bash 4.0+)
declare -A config=()
config['key']='value'
```

#### Adding Elements

```bash
# Append single element
paths+=("$1")

# Append multiple elements
args+=("$arg1" "$arg2" "$arg3")

# Append another array
all_files+=("${config_files[@]}")
```

#### Iteration

```bash
# ✓ Correct - quoted expansion, handles spaces
for path in "${paths[@]}"; do
  process "$path"
done

# ✗ Wrong - unquoted, breaks with spaces
for path in ${paths[@]}; do
  process "$path"
done
```

#### Length and Checking

```bash
count=${#files[@]}            # Get number of elements

# Check if empty
if ((${#array[@]} == 0)); then
  info 'Array is empty'
fi

# Set default if empty
((${#paths[@]})) || paths=('.')
```

#### Reading Into Arrays

```bash
# Split string by delimiter
IFS=',' read -ra fields <<< "$csv_line"

# From command output (preferred)
readarray -t lines < <(grep pattern file)
mapfile -t files < <(find . -name "*.txt")

# From file
readarray -t config_lines < config.txt
```

#### Element Access

```bash
first=${array[0]}             # Single element (0-indexed)
last=${array[-1]}             # Last element (Bash 4.3+)

"${array[@]}"                 # All elements as separate words
"${array[*]}"                 # All as single word (rare)

"${array[@]:2}"               # Slice from index 2
"${array[@]:1:3}"             # 3 elements from index 1
```

---

#### Safe Command Construction

```bash
# Build command with variable arguments
local -a cmd=(myapp '--config' "$config_file")

# Add conditional arguments
((verbose)) && cmd+=('--verbose') ||:
[[ -z "$output" ]] || cmd+=('--output' "$output")

# Execute safely
"${cmd[@]}"
```

#### Collecting Arguments During Parsing

```bash
declare -a input_files=()
while (($#)); do
  case $1 in
    -*)  handle_option "$1" ;;
    *)   input_files+=("$1") ;;
  esac
  shift
done

# Process collected files
for file in "${input_files[@]}"; do
  process_file "$file"
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted expansion
rm ${files[@]}
# ✓ Correct - quoted expansion
rm "${files[@]}"

# ✗ Wrong - word splitting to create array
array=($string)
# ✓ Correct - explicit
readarray -t array <<< "$string"

# ✗ Wrong - using [*] in iteration
for item in "${array[*]}"; do
# ✓ Correct - use [@]
for item in "${array[@]}"; do
```

---

#### Operator Summary

| Operation | Syntax | Description |
|-----------|--------|-------------|
| Declare | `declare -a arr=()` | Create empty array |
| Append | `arr+=("value")` | Add element |
| Length | `${#arr[@]}` | Number of elements |
| All elements | `"${arr[@]}"` | Each as separate word |
| Single element | `"${arr[i]}"` | Element at index i |
| Last element | `"${arr[-1]}"` | Last element |
| Slice | `"${arr[@]:2:3}"` | 3 elements from index 2 |
| Indices | `"${!arr[@]}"` | All array indices |

**Key principle:** Always quote array expansions: `"${array[@]}"` to preserve spacing and prevent word splitting.

#fin
