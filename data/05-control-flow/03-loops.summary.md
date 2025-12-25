## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- **Collection Processing**: For loops iterate over arrays, globs, ranges
- **Stream Processing**: While loops process line-by-line input
- **Array Safety**: `"${array[@]}"` preserves element boundaries
- **Process Substitution**: `< <(command)` avoids subshell variable scope issues
- **Loop Control**: Break/continue enable early exit and conditional processing

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
local -a files=('document.txt' 'file with spaces.pdf')
local -- file
for file in "${files[@]}"; do
  [[ -f "$file" ]] && info "Processing: $file"
done

# ✓ Iterate with index and value
local -a items=('alpha' 'beta' 'gamma')
local -i index
for index in "${!items[@]}"; do
  info "Item $index: ${items[$index]}"
done

# ✓ Iterate over arguments
for arg in "$@"; do info "Argument: $arg"; done
```

**For loops - Glob patterns:**

```bash
# ✓ Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do info "Processing: $file"; done

# ✓ Multiple glob patterns
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing: $file"
done

# ✓ Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done

# ✓ Check if glob matched anything
local -a matches=("$SCRIPT_DIR"/*.log)
[[ ${#matches[@]} -eq 0 ]] && return 1
```

**For loops - C-style and brace expansion:**

```bash
# ✓ C-style for loop (use i+=1, never i++)
local -i i
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Countdown with step
for ((i=seconds; i>0; i-=1)); do echo "T-minus $i"; sleep 1; done

# Range and step expansion (Bash 4+)
for i in {1..10}; do echo "$i"; done
for i in {0..100..10}; do echo "Multiple of 10: $i"; done
for letter in {a..z}; do echo "$letter"; done

# Zero-padded numbers
for file in file{001..100}.txt; do echo "$file"; done
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
local -- line; local -i line_count=0
while IFS= read -r line; do
  ((line_count+=1))
done < "$file"

# ✓ Process command output (avoid subshell)
while IFS= read -r line; do ((count+=1)); done < <(find . -name '*.txt')

# ✓ Read null-delimited input (safe for filenames with newlines)
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find . -name '*.sh' -print0)

# ✓ Read CSV with custom delimiter
while IFS=',' read -r name email age; do info "$name, $email, $age"; done < "$csv"

# ✓ Read with timeout
read -r -t 10 input || warn 'Timed out'
```

**While loops - Argument parsing:**

```bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_DIR="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
INPUT_FILES+=("$@")  # Collect remaining arguments after --
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition with timeout
wait_for_file() {
  local -- file="$1"; local -i timeout="${2:-30}" elapsed=0
  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && return 1
    sleep 1; ((elapsed+=1))
  done
}

# ✓ Retry with exponential backoff
local -i attempt=1 wait_time=1
while ((attempt <= max_attempts)); do
  some_command && return 0
  ((attempt < max_attempts)) && { sleep "$wait_time"; wait_time=$((wait_time * 2)); }
  ((attempt+=1))
done
```

**Until loops:**

```bash
# ✓ Until loop (less common, for when logic reads better as "until true")
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; ((elapsed+=1))
done

# ✓ Prefer while with opposite condition (usually clearer)
while [[ -f "$lock_file" ]]; do sleep 1; done  # Better than: until [[ ! -f "$lock_file" ]]
```

**Infinite loops:**

> **Performance:** `while ((1))` is fastest. `while :` is 9-14% slower (use for POSIX). `while true` is 15-22% slower (avoid).

```bash
# ✓ RECOMMENDED - Infinite loop with break condition
while ((1)); do
  systemctl is-active --quiet "$service" || error "Service down!"
  sleep "$interval"
done

# ✓ ACCEPTABLE - POSIX-compatible
while :; do process_item || break; done

# ✗ AVOID - Slowest due to command execution overhead
while true; do check_status; sleep 5; done
```

**Loop control - break and continue:**

```bash
# ✓ Early exit with break
for file in "${files[@]}"; do
  [[ "$file" =~ $pattern ]] && { found="$file"; break; }
done

# ✓ Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && { ((skipped+=1)); continue; }
  [[ ! -r "$file" ]] && { ((skipped+=1)); continue; }
  # Process valid file
done

# ✓ Break out of nested loops with explicit level
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && { found=1; break 2; }
  done
done

# ✓ Continue in while loop
while IFS= read -r line; do
  [[ -z "$line" ]] && continue   # Skip empty lines
  [[ "$line" =~ ^# ]] && continue # Skip comments
  process "$line"
done < "$file"
```

**Anti-patterns:**

```bash
# ✗ Iterating over unquoted string (word splitting!)
for file in $files_str; do ...
# ✓ Iterate over array
for file in "${files[@]}"; do ...

# ✗ Parsing ls output
for file in $(ls *.txt); do ...  # NEVER
# ✓ Use glob directly
for file in *.txt; do ...

# ✗ Pipe to while (subshell - count stays 0)
count=0; cat file.txt | while read -r line; do ((count+=1)); done
# ✓ Process substitution
while read -r line; do ((count+=1)); done < <(cat file.txt)

# ✗ Unquoted array expansion
for item in ${array[@]}; do ...
# ✓ Quoted
for item in "${array[@]}"; do ...

# ✗ C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do ...
# ✓ Use +=1
for ((i=0; i<10; i+=1)); do ...

# ✗ Redundant comparison
while (($# > 0)); do ...
# ✓ Arithmetic truthiness
while (($#)); do ...

# ✗ Ambiguous break in nested loops
break    # Inner only - unclear
# ✓ Explicit
break 2  # Both loops - clear

# ✗ Modifying array during iteration
for item in "${array[@]}"; do array+=("$item"); done  # Dangerous
# ✓ Create new array
for item in "${original[@]}"; do modified+=("$item"); done

# ✗ External seq command
for i in $(seq 1 10); do ...
# ✓ Brace expansion
for i in {1..10}; do ...

# ✗ Missing -r flag (backslash processing)
while read line; do ...
# ✓ Always use -r
while IFS= read -r line; do ...

# ✗ Local declared inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do local target; target=$(readlink "$link"); done
# ✓ Declare before loop
local -- target; for link in "$BIN_DIR"/*; do target=$(readlink "$link"); done
```

**Edge cases:**

```bash
# Empty arrays - zero iterations, no errors
for item in "${empty[@]}"; do echo "$item"; done  # Never executes

# Arrays with empty elements - iterates including empty strings
array=('' 'item2' '')
for item in "${array[@]}"; do echo "[$item]"; done  # Output: [] [item2] []

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# Loop variable scope - not local, persists after loop
for i in {1..5}; do :; done
echo "$i"  # Prints: 5

# IMPORTANT: Declare locals BEFORE loops
process() {
  local -- target; local -i count=0  # Declare here
  for link in "$BIN_DIR"/*; do
    target=$(readlink "$link")       # Use here
    count+=1
  done
}
```

**Summary:**
- **For loops**: arrays, globs, known ranges
- **While loops**: reading input, argument parsing, condition-based
- **Until loops**: rarely needed, prefer while with opposite condition
- **Infinite loops**: `while ((1))` fastest, `while :` POSIX, avoid `while true`
- **Always quote arrays**: `"${array[@]}"`
- **Process substitution**: `< <(command)` avoids subshell
- **Never parse ls**: use globs or find
- **Use i+=1 not i++**: ++ fails with set -e when 0
- **Arithmetic truthiness**: `while (($#))` not `while (($# > 0))`
- **Explicit break level**: `break 2` for nested loops
- **Always IFS= read -r**: preserve whitespace and backslashes
- **Declare locals before loops**: not inside

#fin
