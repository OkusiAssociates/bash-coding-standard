## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Always prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with break/continue for clarity.**

**Rationale:** For loops handle arrays/globs/ranges efficiently. While loops process line-by-line input. Array iteration with `"${array[@]}"` preserves boundaries. Process substitution `< <(command)` avoids subshell scope issues. Break/continue enable early exit and conditional processing.

**For loops - Array iteration:**

```bash
# ✓ Iterate over array
files=('document.txt' 'file with spaces.pdf')
for file in "${files[@]}"; do
  [[ -f "$file" ]] && info "Processing: $file"
done

# ✓ Iterate with index
items=('alpha' 'beta' 'gamma')
for index in "${!items[@]}"; do
  info "Item $index: ${items[$index]}"
done

# ✓ Iterate over arguments
for arg in "$@"; do
  info "Argument: $arg"
done
```

**For loops - Glob patterns:**

```bash
# ✓ Iterate over glob matches (nullglob ensures empty loop if no matches)
for file in "$SCRIPT_DIR"/*.txt; do
  info "Processing: $file"
done

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
matches=("$SCRIPT_DIR"/*.log)
[[ ${#matches[@]} -eq 0 ]] && { warn 'No log files'; return 1; }
```

**For loops - C-style:**

```bash
# ✓ C-style for loop
for ((i=1; i<=10; i+=1)); do
  echo "Count: $i"
done

# ✓ Iterate with step
for ((i=0; i<=20; i+=2)); do
  echo "Even: $i"
done

# ✓ Array with index
items=('first' 'second' 'third')
for ((i=0; i<${#items[@]}; i+=1)); do
  echo "Index $i: ${items[$i]}"
done
```

**For loops - Brace expansion:**

```bash
# Range expansion
for i in {1..10}; do echo "Number: $i"; done

# Range with step
for i in {0..100..10}; do echo "Multiple: $i"; done

# Character range
for letter in {a..z}; do echo "Letter: $letter"; done

# String expansion
for env in {dev,staging,prod}; do echo "Deploy: $env"; done
```

**While loops - Reading input:**

```bash
# ✓ Read file line by line
line_count=0
while IFS= read -r line; do
  ((line_count+=1))
  echo "Line $line_count: $line"
done < "$file"

# ✓ Process command output (avoid subshell)
count=0
while IFS= read -r line; do
  ((count+=1))
  info "Processing: $line"
done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)
info "Processed $count files"

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
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -o|--output)
      noarg "$@"
      shift
      OUTPUT_DIR="$1"
      ;;
    --) shift; break ;;
    -*) die 22 "Invalid option: $1" ;;
    *) INPUT_FILES+=("$1") ;;
  esac
  shift
done
INPUT_FILES+=("$@")  # Collect remaining after --
```

**While loops - Condition-based:**

```bash
# ✓ Wait for condition
wait_for_file() {
  local -- file="$1" timeout="${2:-30}"
  local -i elapsed=0

  while [[ ! -f "$file" ]]; do
    ((elapsed >= timeout)) && { error "Timeout: $file"; return 1; }
    sleep 1
    ((elapsed+=1))
  done
  success "File appeared after $elapsed seconds"
}

# ✓ Retry with exponential backoff
attempt=1
wait_time=1
while ((attempt <= max_attempts)); do
  if some_command; then return 0; fi

  if ((attempt < max_attempts)); then
    warn "Retrying in $wait_time seconds..."
    sleep "$wait_time"
    wait_time=$((wait_time * 2))
  fi
  ((attempt+=1))
done
```

**Until loops:**

```bash
# ✓ Until loop (opposite of while)
until systemctl is-active --quiet "$service"; do
  ((elapsed >= timeout)) && return 1
  sleep 1
  ((elapsed+=1))
done

# ✗ Generally avoid - while is clearer
until [[ ! -f "$lock_file" ]]; do sleep 1; done

# ✓ Better - equivalent while loop
while [[ -f "$lock_file" ]]; do sleep 1; done
```

**Loop control - break and continue:**

```bash
# ✓ Early exit with break
for file in "${files[@]}"; do
  if [[ -f "$file" && "$file" =~ $pattern ]]; then
    found="$file"
    break  # Stop after first match
  fi
done

# ✓ Skip items with continue
for file in "${files[@]}"; do
  [[ ! -f "$file" ]] && { warn "Not found: $file"; continue; }
  [[ ! -r "$file" ]] && { warn "Not readable: $file"; continue; }

  info "Processing: $file"
  ((processed+=1))
done

# ✓ Break nested loops
for row in "${matrix[@]}"; do
  for col in $row; do
    if [[ "$col" == 'target' ]]; then
      info "Found target"
      break 2  # Break both loops
    fi
  done
done
```

**Infinite loops:**

> **Performance:** `while ((1))` is fastest (baseline). `while :` is 9-14% slower. `while true` is 15-22% slower (command execution overhead).
>
> **Recommendation:** Use `while ((1))` for performance. Use `while :` for POSIX compatibility. Avoid `while true`.

```bash
# ✓ RECOMMENDED - Fastest infinite loop
while ((1)); do
  if ! systemctl is-active --quiet "$service"; then
    error "Service down!"
  fi
  sleep "$interval"
done

# ✓ With exit condition
while ((1)); do
  [[ ! -f "$pid_file" ]] && break
  process_queue
  sleep 1
done

# ✓ Interactive menu
while ((1)); do
  read -r -p 'Choice: ' choice
  case "$choice" in
    1) start_service ;;
    2) stop_service ;;
    q|Q) break ;;
    *) warn 'Invalid' ;;
  esac
done

# ✓ ACCEPTABLE - POSIX compatibility
while :; do
  process_item || break
  sleep 1
done

# ✗ AVOID - Slowest (15-22% slower)
while true; do
  check_status
  sleep 5
done
```

**Anti-patterns:**

```bash
# ✗ Wrong - iterating unquoted string (word splitting)
for file in $files_str; do echo "$file"; done

# ✓ Correct - iterate array
for file in "${files[@]}"; do echo "$file"; done

# ✗ Wrong - parsing ls output
for file in $(ls *.txt); do process "$file"; done

# ✓ Correct - use glob
for file in *.txt; do process "$file"; done

# ✗ Wrong - pipe to while (subshell issue)
count=0
cat file.txt | while read -r line; do ((count+=1)); done
echo "$count"  # Still 0!

# ✓ Correct - process substitution
count=0
while read -r line; do ((count+=1)); done < <(cat file.txt)
echo "$count"  # Correct

# ✗ Wrong - unquoted array
for item in ${array[@]}; do echo "$item"; done

# ✓ Correct - quoted
for item in "${array[@]}"; do echo "$item"; done

# ✗ Wrong - C-style with ++ (fails with set -e when i=0)
for ((i=0; i<10; i++)); do echo "$i"; done

# ✓ Correct - use +=1
for ((i=0; i<10; i+=1)); do echo "$i"; done

# ✗ Wrong - redundant comparison
while (($# > 0)); do shift; done

# ✓ Correct - arithmetic context
while (($#)); do shift; done

# ✗ Wrong - seq (external command)
for i in $(seq 1 10); do echo "$i"; done

# ✓ Correct - brace expansion
for i in {1..10}; do echo "$i"; done

# ✗ Wrong - missing -r flag
while read line; do echo "$line"; done < file.txt

# ✓ Correct - always use -r
while IFS= read -r line; do echo "$line"; done < file.txt

# ✗ Wrong - modifying array during iteration
for item in "${array[@]}"; do
  array+=("$item")  # Dangerous!
done

# ✓ Correct - create new array
for item in "${original[@]}"; do
  modified+=("$item" "$item")
done
```

**Edge cases:**

```bash
# Empty arrays - safe (zero iterations)
empty=()
for item in "${empty[@]}"; do echo "$item"; done  # Never executes

# Arrays with empty elements - iterates including empties
array=('' 'item2' '' 'item4')
for item in "${array[@]}"; do echo "[$item]"; done  # 4 iterations

# Glob with nullglob
shopt -s nullglob
for file in /none/*.txt; do echo "$file"; done  # Zero iterations if no matches

# Without nullglob - executes once with literal
shopt -u nullglob
for file in /none/*.txt; do
  [[ ! -e "$file" ]] && break  # Detect no match
done

# Loop variables persist after loop
for i in {1..5}; do echo "$i"; done
echo "$i"  # Prints: 5

# Empty file - zero iterations
while read -r line; do count+=1; done < empty.txt  # count stays 0
```

**Summary:**

- **For loops:** arrays, globs, known ranges, brace expansion
- **While loops:** reading input, argument parsing, condition-based iteration, retry logic
- **Until loops:** rarely used, prefer while with opposite condition
- **Infinite loops:** `while ((1))` fastest, `while :` POSIX-compatible, avoid `while true`
- **Always quote:** `"${array[@]}"` for safe iteration
- **Process substitution:** `< <(command)` avoids subshell issues in while loops
- **Use i+=1 not i++:** ++ fails with set -e when 0
- **Arithmetic context:** `while (($#))` not `while (($# > 0))`
- **Break/continue:** early exit and skipping, specify level for nested (`break 2`)
- **IFS= read -r:** always use when reading lines
- **Never parse ls:** use globs or find with process substitution
- **Check glob matches:** with nullglob or explicit test

**Key principle:** Choose loop type matching iteration pattern. For loops for collections/ranges. While loops for streaming/conditions. Always prefer arrays over string parsing, use process substitution to avoid subshells, and use explicit loop control for clarity.
