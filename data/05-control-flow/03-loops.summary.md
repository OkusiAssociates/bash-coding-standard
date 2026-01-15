## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- For loops efficiently iterate over arrays, globs, and ranges
- While loops process line-by-line input from commands or files
- `"${array[@]}"` preserves element boundaries; `< <(command)` avoids subshell scope issues
- Break and continue enable early exit and conditional processing

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
local -a files=('document.txt' 'file with spaces.pdf')
local -- file
for file in "${files[@]}"; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# ✓ Iterate with index
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
# nullglob ensures empty loop if no matches
shopt -s nullglob
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing ${file@Q}"
done

# Multiple patterns (check existence for brace expansion)
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done
```

**For loops - C-style:**

```bash
# ✓ C-style for loop (use +=1, not ++)
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Iterate with step
for ((i=0; i<=20; i+=2)); do echo "Even: $i"; done

# ✓ Countdown
for ((i=seconds; i>0; i-=1)); do sleep 1; done
```

**For loops - Brace expansion:**

```bash
for i in {1..10}; do echo "$i"; done           # Range
for i in {0..100..10}; do echo "$i"; done      # With step
for letter in {a..z}; do echo "$letter"; done  # Characters
for env in {dev,staging,prod}; do deploy "$env"; done
for file in file{001..100}.txt; do touch "$file"; done  # Zero-padded
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
while IFS= read -r line; do
  echo "$line"
done < "$file"

# ✓ Process command output (avoid subshell)
while IFS= read -r line; do
  count+=1
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

# ✓ Null-delimited input (handles special filenames)
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

# ✓ CSV with custom delimiter
while IFS=',' read -r name email age; do
  info "Name: $name, Email: $email, Age: $age"
done < "$csv_file"
```

**While loops - Argument parsing:**

```bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE+=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_DIR=$1 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
INPUT_FILES+=("$@")  # Collect remaining after --
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition with timeout
while [[ ! -f "$file" ]]; do
  ((elapsed >= timeout)) && { error "Timeout"; return 1; }
  sleep 1; elapsed+=1
done

# ✓ Retry with exponential backoff
while ((attempt <= max_attempts)); do
  some_command && return 0
  ((attempt < max_attempts)) && sleep "$wait_time"
  wait_time=$((wait_time * 2)); attempt+=1
done
```

**Until loops:**

```bash
# ✓ Loop UNTIL service is running
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; elapsed+=1
done

# ✗ Confusing until - prefer while with opposite condition
until [[ ! -f "$lock_file" ]]; do sleep 1; done  # Confusing
while [[ -f "$lock_file" ]]; do sleep 1; done    # ✓ Clearer
```

**Loop control - break and continue:**

```bash
# ✓ Early exit with break
for file in "${files[@]}"; do
  [[ "$file" =~ $pattern ]] && { found="$file"; break; }
done

# ✓ Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && { skipped+=1; continue; }
  [[ ! -r "$file" ]] && { skipped+=1; continue; }
  process "$file"; processed+=1
done

# ✓ Break out of nested loops with level
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && break 2  # Break both loops
  done
done
```

**Infinite loops:**

> **Performance (Bash 5.2.21, Intel i9-13900HX):**
> - `while ((1))` — **Fastest** ⚡
> - `while :` — +9-14% slower (use for POSIX)
> - `while true` — +15-22% slower 🐌 (avoid)

```bash
# ✓ RECOMMENDED - fastest
while ((1)); do
  systemctl is-active --quiet "$service" || error "Service down!"
  sleep "$interval"
done

# ✓ ACCEPTABLE - POSIX-compatible
while :; do process_item || break; sleep 1; done

# ✗ AVOID - slowest
while true; do check_status; sleep 5; done
```

**Anti-patterns:**

```bash
# ✗ Iterating unquoted string
for file in $files_str; do echo "$file"; done  # Word splitting!
# ✓ Use array
for file in "${files[@]}"; do echo "$file"; done

# ✗ Parsing ls output
for file in $(ls *.txt); do process "$file"; done  # NEVER!
# ✓ Use glob directly
for file in *.txt; do process "$file"; done

# ✗ Pipe to while (subshell loses variables)
cat file.txt | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Process substitution
while read -r line; do count+=1; done < <(cat file.txt)

# ✗ Unquoted array expansion
for item in ${array[@]}; do echo "$item"; done
# ✓ Quoted
for item in "${array[@]}"; do echo "$item"; done

# ✗ C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do echo "$i"; done
# ✓ Use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

# ✗ Redundant comparison
while (($# > 0)); do shift; done
# ✓ Idiomatic
while (($#)); do shift; done

# ✗ Ambiguous break in nested loops
for i in {1..10}; do for j in {1..10}; do break; done; done
# ✓ Explicit break level
for i in {1..10}; do for j in {1..10}; do break 2; done; done

# ✗ Missing -r flag
while read line; do echo "$line"; done < file.txt
# ✓ Always use -r
while IFS= read -r line; do echo "$line"; done < file.txt
```

**Edge cases:**

```bash
# Empty array - zero iterations, no errors
for item in "${empty[@]}"; do echo "$item"; done

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# Loop variable scope - not local, persists after loop
for i in {1..5}; do :; done
echo "$i"  # Prints: 5

# ✓ CORRECT - declare locals BEFORE loops
process_links() {
  local -- target
  local -i count=0
  for link in "$BIN_DIR"/*; do
    target=$(readlink "$link")
    count+=1
  done
}

# ✗ WRONG - declaring inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do
  local target  # Re-executed each iteration
  target=$(readlink "$link")
done
```

**Summary:**
- **For loops** — arrays, globs, known ranges
- **While loops** — reading input, argument parsing, conditions
- **Until loops** — rarely needed, prefer while with opposite condition
- **Infinite loops** — `while ((1))` fastest; `while :` for POSIX; avoid `while true`
- **Always quote arrays** — `"${array[@]}"`
- **Process substitution** — `< <(command)` to avoid subshell
- **Use i+=1 not i++** — ++ fails with set -e when 0
- **IFS= read -r** — always with while loops
- **break N** — specify level for nested loops
