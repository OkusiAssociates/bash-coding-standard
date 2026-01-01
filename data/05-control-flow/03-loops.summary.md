## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue`.**

**Rationale:**
- For loops efficiently iterate over arrays, globs, and ranges
- While loops process line-by-line input from commands or files
- Process substitution `< <(command)` avoids subshell variable scope issues
- Proper loop type makes intent immediately clear

**For loops - Array iteration:**

```bash
# ✓ Iterate over array elements
process_files() {
  local -a files=('document.txt' 'file with spaces.pdf' 'report (final).doc')
  local -- file
  for file in "${files[@]}"; do
    [[ -f "$file" ]] && info "Processing ${file@Q}" || warn "Not found ${file@Q}"
  done
}

# ✓ Iterate with index and value
local -a items=('alpha' 'beta' 'gamma')
local -i index; local -- item
for index in "${!items[@]}"; do
  item="${items[$index]}"
  info "Item $index: $item"
done

# ✓ Iterate over arguments
for arg in "$@"; do info "Argument: $arg"; done
```

**For loops - Glob patterns:**

```bash
# ✓ Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing ${file@Q}"
done

# ✓ Multiple glob patterns
for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
  [[ -f "$file" ]] && info "Processing ${file@Q}"
done

# ✓ Recursive glob (requires globstar)
shopt -s globstar
for script in "$SCRIPT_DIR"/**/*.sh; do
  [[ -f "$script" ]] && shellcheck "$script"
done

# ✓ Check if glob matched anything
local -a matches=("$SCRIPT_DIR"/*.log)
if [[ ${#matches[@]} -eq 0 ]]; then warn 'No log files found'; return 1; fi
```

**For loops - C-style:**

```bash
# ✓ C-style for loop (MUST use i+=1, never i++)
local -i i
for ((i=1; i<=10; i+=1)); do echo "Count: $i"; done

# ✓ Iterate with step
for ((i=0; i<=20; i+=2)); do echo "Even: $i"; done

# ✓ Countdown
for ((i=10; i>0; i-=1)); do echo "T-minus $i"; sleep 1; done
```

**Brace expansion:**

```bash
for i in {1..10}; do echo "$i"; done           # Range
for i in {0..100..10}; do echo "$i"; done      # Range with step
for letter in {a..z}; do echo "$letter"; done  # Character range
for env in {dev,staging,prod}; do echo "$env"; done  # Strings
for file in file{001..100}.txt; do echo "$file"; done  # Zero-padded
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
local -- line; local -i line_count=0
while IFS= read -r line; do
  line_count+=1
  echo "Line $line_count: $line"
done < "$file"

# ✓ Process command output (avoid subshell)
local -i count=0
while IFS= read -r line; do
  count+=1
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

# ✓ Read null-delimited input
while IFS= read -r -d '' file; do
  info "Processing: $file"
done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)

# ✓ Read CSV with custom delimiter
while IFS=',' read -r name email age; do
  info "Name: $name, Email: $email, Age: $age"
done < "$csv_file"
```

**While loops - Argument parsing:**

```bash
main() {
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
  INPUT_FILES+=("$@")  # Remaining after --
}
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition
wait_for_file() {
  local -- file=$1; local -i timeout=${2:-30} elapsed=0
  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && { error "Timeout"; return 1; }
    sleep 1; elapsed+=1
  done
}

# ✓ Retry with exponential backoff
retry_command() {
  local -i max=5 attempt=1 wait=1
  while ((attempt <= max)); do
    some_command && return 0
    ((attempt < max)) && { sleep "$wait"; wait=$((wait * 2)); }
    attempt+=1
  done
  return 1
}
```

**Until loops:**

```bash
# ✓ Loop UNTIL service is running
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1; elapsed+=1
done

# ✓ Generally prefer while (clearer)
# ✗ Confusing: until [[ ! -f "$lock_file" ]]; do sleep 1; done
# ✓ Clearer:   while [[ -f "$lock_file" ]]; do sleep 1; done
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
  processed+=1
done

# ✓ Break out of nested loops
for row in "${matrix[@]}"; do
  for col in $row; do
    [[ "$col" == 'target' ]] && break 2  # Break both loops
  done
done
```

**Infinite loops performance:**

| Construct | Performance |
|-----------|-------------|
| `while ((1))` | **Baseline (fastest)** ⚡ |
| `while :` | +9-14% slower (POSIX) |
| `while true` | +15-22% slower 🐌 |

```bash
# ✓ RECOMMENDED - fastest
while ((1)); do
  check_status
  [[ ! -f "$pid_file" ]] && break
  sleep 1
done

# ✓ ACCEPTABLE - POSIX compatibility
while :; do process_item || break; done

# ✗ AVOID - slowest
while true; do check_status; done
```

**Anti-patterns:**

```bash
# ✗ Wrong - iterating over unquoted string
for file in $files_str; do echo "$file"; done
# ✓ Correct - iterate over array
for file in "${files[@]}"; do echo "$file"; done

# ✗ Wrong - parsing ls output (NEVER!)
for file in $(ls *.txt); do process "$file"; done
# ✓ Correct - use glob directly
for file in *.txt; do process "$file"; done

# ✗ Wrong - pipe to while (subshell issue)
count=0; cat file.txt | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Correct - process substitution
while read -r line; do count+=1; done < <(cat file.txt)

# ✗ Wrong - C-style loop with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do echo "$i"; done
# ✓ Correct - use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

# ✗ Wrong - redundant comparison
while (($# > 0)); do shift; done
# ✓ Correct - arithmetic truthiness
while (($#)); do shift; done

# ✗ Wrong - break without level in nested loops (ambiguous)
for i in {1..10}; do for j in {1..10}; do break; done; done
# ✓ Correct - explicit break level
for i in {1..10}; do for j in {1..10}; do break 2; done; done

# ✗ Wrong - seq for iteration (external command)
for i in $(seq 1 10); do echo "$i"; done
# ✓ Correct - brace expansion
for i in {1..10}; do echo "$i"; done

# ✗ Wrong - missing -r with read
while read line; do echo "$line"; done < file.txt
# ✓ Correct - always use -r
while IFS= read -r line; do echo "$line"; done < file.txt
```

**Edge cases:**

```bash
# Empty arrays - safe, zero iterations
empty=(); for item in "${empty[@]}"; do echo "$item"; done

# Arrays with empty elements - iterates all including empty strings
array=('' 'item2' '' 'item4')
for item in "${array[@]}"; do echo "[$item]"; done  # [],[item2],[],[item4]

# Glob with no matches (nullglob)
shopt -s nullglob
for file in /nonexistent/*.txt; do echo "$file"; done  # Never executes

# ✓ CORRECT - declare locals BEFORE loops
process_links() {
  local -- target; local -i count=0
  for link in "$BIN_DIR"/*; do target=$(readlink "$link"); done
}
# ✗ WRONG - declaring local inside loop (wasteful, misleading)
for link in "$BIN_DIR"/*; do local target; target=$(readlink "$link"); done
```

**Summary:**
- **For loops** - arrays, globs, known ranges
- **While loops** - reading input, argument parsing, condition-based iteration
- **Until loops** - rarely used; prefer while with opposite condition
- **Infinite loops** - `while ((1))` fastest; `while :` for POSIX; avoid `while true`
- **Always quote arrays** - `"${array[@]}"`
- **Use process substitution** - `< <(command)` avoids subshell
- **Never parse ls** - use glob patterns
- **Use i+=1 not i++** - ++ fails with set -e when 0
- **IFS= read -r** - always with while loops reading input
- **Specify break level** - `break 2` for nested loops
