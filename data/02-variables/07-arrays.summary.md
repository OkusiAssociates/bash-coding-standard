### Arrays

**Rule: BCS0207** (Merged from BCS0501 + BCS0502)

Array declaration, usage, and safe list handling.

---

#### Rationale

Arrays provide element preservation (boundaries maintained regardless of content), no word splitting with `"${array[@]}"`, glob safety (wildcards preserved literally), and safe command construction with arbitrary arguments.

---

#### Declaration

```bash
declare -a paths=()           # Empty indexed array
declare -a colors=(red green blue)
local -a found_files=()       # Local arrays in functions
declare -A config=()          # Associative arrays (Bash 4.0+)
config['key']='value'
```

#### Adding Elements

```bash
paths+=("$1")                        # Append single element
args+=("$arg1" "$arg2" "$arg3")      # Append multiple
all_files+=("${config_files[@]}")    # Append another array
```

#### Iteration

```bash
# ✓ Correct - quoted expansion, handles spaces
for path in "${paths[@]}"; do
  process "$path"
done

# ✗ Wrong - unquoted, breaks with spaces
for path in ${paths[@]}; do
```

#### Length and Checking

```bash
count=${#files[@]}                    # Get number of elements
if ((${#array[@]} == 0)); then        # Check if empty
  info 'Array is empty'
fi
((${#paths[@]})) || paths=('.')       # Set default if empty
```

#### Reading Into Arrays

```bash
IFS=',' read -ra fields <<< "$csv_line"      # Split by delimiter
readarray -t lines < <(grep pattern file)    # From command (preferred)
mapfile -t files < <(find . -name "*.txt")
readarray -t config_lines < config.txt       # From file
```

#### Element Access

```bash
first=${array[0]}           # Single element (0-indexed)
last=${array[-1]}           # Bash 4.3+
"${array[@]}"               # All elements as separate words
"${array[*]}"               # All as single word (rare)
"${array[@]:2}"             # Slice from index 2
"${array[@]:1:3}"           # 3 elements from index 1
```

---

#### Safe Command Construction

```bash
local -a cmd=(myapp '--config' "$config_file")
((verbose)) && cmd+=('--verbose') ||:
[[ -z "$output" ]] || cmd+=('--output' "$output")
"${cmd[@]}"                 # Execute safely
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
for file in "${input_files[@]}"; do
  process_file "$file"
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - unquoted expansion
rm ${files[@]}
# ✓ Correct
rm "${files[@]}"

# ✗ Wrong - word splitting to create array
array=($string)
# ✓ Correct
readarray -t array <<< "$string"

# ✗ Wrong - using [*] in iteration
for item in "${array[*]}"; do
# ✓ Correct
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
