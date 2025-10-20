## Loops

**Use loops to iterate over collections, process command output, or repeat operations. Bash provides `for`, `while`, and `until` loops, each suited to different iteration patterns. Always prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ proper loop control with `break` and `continue` for early exits and conditional skipping.**

**Rationale:**

- **Collection Processing**: For loops efficiently iterate over arrays, globs, and ranges
- **Stream Processing**: While loops process line-by-line input from commands or files
- **Condition Looping**: While/until loops continue until condition changes
- **Array Safety**: Iterating arrays with `"${array[@]}"` preserves element boundaries
- **Process Substitution**: Using `< <(command)` avoids subshell variable scope issues
- **Loop Control**: Break and continue enable early exit and conditional processing
- **Readability**: Appropriate loop type makes intent immediately clear

**For loops - Array iteration:**

The most common and safest loop pattern in Bash.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Iterate over array elements
process_files() {
  local -a files=(
    'document.txt'
    'file with spaces.pdf'
    'report (final).doc'
  )

  local -- file
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      info "Processing: $file"
      # Process file
    else
      warn "File not found: $file"
    fi
  done
}

# ✓ CORRECT - Iterate with index and value
process_indexed() {
  local -a items=('alpha' 'beta' 'gamma' 'delta')
  local -i index
  local -- item

  for index in "${!items[@]}"; do
    item="${items[$index]}"
    info "Item $index: $item"
  done
}

# ✓ CORRECT - Iterate over arguments
process_arguments() {
  local -- arg

  for arg in "$@"; do
    info "Argument: $arg"
  done
}

main() {
  process_files
  process_indexed
  process_arguments 'arg1' 'arg with spaces' 'arg3'
}

main "$@"

#fin
```

**For loops - Glob patterns:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Iterate over glob matches
process_text_files() {
  local -- file

  # nullglob ensures empty loop if no matches
  for file in "$SCRIPT_DIR"/*.txt; do
    info "Processing text file: $file"
    # Process file
  done
}

# ✓ CORRECT - Multiple glob patterns
process_documents() {
  local -- file

  for file in "$SCRIPT_DIR"/*.{txt,md,rst}; do
    if [[ -f "$file" ]]; then
      info "Processing document: $file"
      # Process file
    fi
  done
}

# ✓ CORRECT - Recursive glob (requires globstar)
process_all_scripts() {
  shopt -s globstar

  local -- script

  for script in "$SCRIPT_DIR"/**/*.sh; do
    if [[ -f "$script" ]]; then
      info "Found script: $script"
      shellcheck "$script"
    fi
  done
}

# ✓ CORRECT - Check if glob matched anything
process_with_check() {
  local -a matches=("$SCRIPT_DIR"/*.log)

  if [[ ${#matches[@]} -eq 0 ]]; then
    warn 'No log files found'
    return 1
  fi

  local -- file
  for file in "${matches[@]}"; do
    info "Processing log: $file"
  done
}

main() {
  process_text_files
  process_documents
  process_all_scripts
  process_with_check
}

main "$@"

#fin
```

**For loops - C-style:**

Use for numeric iteration with known range.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - C-style for loop
count_to_ten() {
  local -i i

  for ((i=1; i<=10; i+=1)); do
    echo "Count: $i"
  done
}

# ✓ CORRECT - Iterate with step
count_by_twos() {
  local -i i

  for ((i=0; i<=20; i+=2)); do
    echo "Even: $i"
  done
}

# ✓ CORRECT - Countdown
countdown() {
  local -i seconds="${1:-10}"
  local -i i

  for ((i=seconds; i>0; i-=1)); do
    echo "T-minus $i seconds..."
    sleep 1
  done

  echo 'Liftoff!'
}

# ✓ CORRECT - Array processing with index
process_with_index() {
  local -a items=('first' 'second' 'third' 'fourth')
  local -i i

  for ((i=0; i<${#items[@]}; i+=1)); do
    echo "Index $i: ${items[$i]}"
  done
}

main() {
  count_to_ten
  count_by_twos
  countdown 5
  process_with_index
}

main "$@"

#fin
```

**For loops - Brace expansion and sequences:**

```bash
# Range expansion (Bash 4+)
for i in {1..10}; do
  echo "Number: $i"
done

# Range with step (Bash 4+)
for i in {0..100..10}; do
  echo "Multiple of 10: $i"
done

# Character range
for letter in {a..z}; do
  echo "Letter: $letter"
done

# Brace expansion with strings
for env in {dev,staging,prod}; do
  echo "Deploy to: $env"
done

# Zero-padded numbers
for file in file{001..100}.txt; do
  echo "Filename: $file"
done
```

**While loops - Reading input:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Read file line by line
read_file() {
  local -- file="$1"
  local -- line
  local -i line_count=0

  while IFS= read -r line; do
    ((line_count+=1))
    echo "Line $line_count: $line"
  done < "$file"

  info "Total lines: $line_count"
}

# ✓ CORRECT - Process command output (avoid subshell)
process_command_output() {
  local -- line
  local -i count=0

  while IFS= read -r line; do
    ((count+=1))
    info "Processing: $line"
  done < <(find "$SCRIPT_DIR" -name '*.txt' -type f)

  info "Processed $count files"
}

# ✓ CORRECT - Read null-delimited input
process_null_delimited() {
  local -- file

  while IFS= read -r -d '' file; do
    info "Processing: $file"
  done < <(find "$SCRIPT_DIR" -name '*.sh' -type f -print0)
}

# ✓ CORRECT - Read CSV with custom delimiter
read_csv() {
  local -- csv_file="$1"
  local -- name email age

  while IFS=',' read -r name email age; do
    info "Name: $name, Email: $email, Age: $age"
  done < "$csv_file"
}

# ✓ CORRECT - Read with timeout
read_with_timeout() {
  local -- input

  info 'Enter your name (10 second timeout):'

  if read -r -t 10 input; then
    success "Hello, $input!"
  else
    warn 'Timed out waiting for input'
    return 1
  fi
}

main() {
  local -- test_file='/tmp/test.txt'
  echo -e "Line 1\nLine 2\nLine 3" > "$test_file"

  read_file "$test_file"
  process_command_output
  process_null_delimited

  rm -f "$test_file"
}

main "$@"

#fin
```

**While loops - Argument parsing:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- OUTPUT_DIR=''
declare -a INPUT_FILES=()

noarg() {
  if (($# < 2)) || [[ "$2" =~ ^- ]]; then
    die 22 "Option $1 requires an argument"
  fi
}

# ✓ CORRECT - While loop for argument parsing
main() {
  while (($#)); do
    case $1 in
      -v|--verbose)
        VERBOSE=1
        ;;

      -n|--dry-run)
        DRY_RUN=1
        ;;

      -o|--output)
        noarg "$@"
        shift
        OUTPUT_DIR="$1"
        ;;

      -h|--help)
        usage
        return 0
        ;;

      --)
        shift
        break
        ;;

      -*)
        die 22 "Invalid option: $1"
        ;;

      *)
        INPUT_FILES+=("$1")
        ;;
    esac
    shift
  done

  # Collect remaining arguments after --
  INPUT_FILES+=("$@")

  readonly -- VERBOSE DRY_RUN OUTPUT_DIR
  readonly -a INPUT_FILES

  # Validate
  if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
    die 22 'No input files specified'
  fi

  # Process files
  local -- file
  for file in "${INPUT_FILES[@]}"; do
    ((DRY_RUN)) && info "[DRY-RUN] Would process: $file"
    ((DRY_RUN)) || info "Processing: $file"
  done
}

main "$@"

#fin
```

**While loops - Condition-based:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Wait for condition
wait_for_file() {
  local -- file="$1"
  local -i timeout="${2:-30}"
  local -i elapsed=0

  info "Waiting for file: $file"

  while [[ ! -f "$file" ]]; do
    if ((elapsed >= timeout)); then
      error "Timeout waiting for file: $file"
      return 1
    fi

    sleep 1
    ((elapsed+=1))
  done

  success "File appeared after $elapsed seconds"
}

# ✓ CORRECT - Retry with exponential backoff
retry_command() {
  local -i max_attempts=5
  local -i attempt=1
  local -i wait_time=1

  while ((attempt <= max_attempts)); do
    info "Attempt $attempt of $max_attempts"

    if some_command; then
      success 'Command succeeded'
      return 0
    fi

    if ((attempt < max_attempts)); then
      warn "Failed, retrying in $wait_time seconds..."
      sleep "$wait_time"
      wait_time=$((wait_time * 2))  # Exponential backoff
    fi

    ((attempt+=1))
  done

  error 'All retry attempts failed'
  return 1
}

# ✓ CORRECT - Process until resource available
process_queue() {
  local -i max_items=100
  local -i processed=0

  while ((processed < max_items)); do
    if ! get_next_item; then
      info 'Queue empty'
      break
    fi

    process_item
    ((processed+=1))
  done

  info "Processed $processed items"
}

main() {
  wait_for_file '/tmp/ready.txt' 10
  retry_command
  process_queue
}

main "$@"

#fin
```

**Until loops:**

Until loops are less common but useful when the logic reads better as "until condition becomes true."

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Until loop (opposite of while)
wait_for_service() {
  local -- service="$1"
  local -i timeout="${2:-60}"
  local -i elapsed=0

  info "Waiting for service: $service"

  # Loop UNTIL service is running
  until systemctl is-active --quiet "$service"; do
    if ((elapsed >= timeout)); then
      error "Timeout waiting for service: $service"
      return 1
    fi

    sleep 1
    ((elapsed+=1))
  done

  success "Service started after $elapsed seconds"
}

# ✓ CORRECT - Until condition met
wait_until_ready() {
  local -- status_file="$1"
  local -i max_wait=30
  local -i waited=0

  until [[ -f "$status_file" && "$(cat "$status_file")" == 'READY' ]]; do
    if ((waited >= max_wait)); then
      error 'Timeout waiting for ready status'
      return 1
    fi

    sleep 1
    ((waited+=1))
  done

  info 'System ready'
}

# ✗ Generally avoid - while is usually clearer
# This until loop is confusing:
until [[ ! -f "$lock_file" ]]; do
  sleep 1
done

# ✓ Better - equivalent while loop is clearer:
while [[ -f "$lock_file" ]]; do
  sleep 1
done

main() {
  wait_for_service 'nginx' 30
  wait_until_ready '/tmp/status.txt'
}

main "$@"

#fin
```

**Loop control - break and continue:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Early exit with break
find_first_match() {
  local -- pattern="$1"
  local -a files=("$SCRIPT_DIR"/*)
  local -- file
  local -- found=''

  for file in "${files[@]}"; do
    if [[ -f "$file" && "$file" =~ $pattern ]]; then
      found="$file"
      info "Found match: $file"
      break  # Stop searching after first match
    fi
  done

  if [[ -n "$found" ]]; then
    echo "$found"
    return 0
  else
    return 1
  fi
}

# ✓ CORRECT - Skip items with continue
process_valid_files() {
  local -a files=("$@")
  local -- file
  local -i processed=0
  local -i skipped=0

  for file in "${files[@]}"; do
    # Skip non-existent files
    if [[ ! -f "$file" ]]; then
      warn "File not found: $file"
      ((skipped+=1))
      continue
    fi

    # Skip files we can't read
    if [[ ! -r "$file" ]]; then
      warn "File not readable: $file"
      ((skipped+=1))
      continue
    fi

    # Skip empty files
    if [[ ! -s "$file" ]]; then
      warn "File is empty: $file"
      ((skipped+=1))
      continue
    fi

    # Process file
    info "Processing: $file"
    # ... processing logic ...
    ((processed+=1))
  done

  info "Processed: $processed, Skipped: $skipped"
}

# ✓ CORRECT - Break out of nested loops
find_in_matrix() {
  local -a matrix=(
    'row1col1 row1col2 row1col3'
    'row2col1 row2col2 row2col3'
    'row3col1 target row3col3'
  )

  local -- row col
  local -i found=0

  for row in "${matrix[@]}"; do
    for col in $row; do
      if [[ "$col" == 'target' ]]; then
        info "Found target in row: $row"
        found=1
        break 2  # Break out of both loops
      fi
    done
  done

  ((found))
}

# ✓ CORRECT - Continue in while loop
process_log_file() {
  local -- log_file="$1"
  local -- line
  local -i errors=0

  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Skip comments
    [[ "$line" =~ ^# ]] && continue

    # Process error lines
    if [[ "$line" =~ ERROR ]]; then
      error "Error found: $line"
      ((errors+=1))
    fi
  done < "$log_file"

  info "Found $errors errors"
  return "$errors"
}

main() {
  find_first_match 'test'
  process_valid_files file1.txt file2.txt file3.txt
  find_in_matrix
  process_log_file '/var/log/app.log'
}

main "$@"

#fin
```

**Infinite loops:**

> **Performance Note:** Benchmark testing (Bash 5.2.21, 13th Gen Intel i9-13900HX) demonstrates significant performance differences between infinite loop constructs:
>
> | Construct | 100K iterations | 1M iterations | 5M iterations | 1M with work | Performance |
> |-----------|----------------|---------------|---------------|--------------|-------------|
> | `while ((1))` | 0.091s | 0.885s | 4.270s | 1.432s | **Baseline (fastest)** ⚡ |
> | `while :` | 0.102s | 1.009s | 4.837s | 1.575s | +9-14% slower |
> | `while true` | 0.110s | 1.079s | 5.231s | 1.647s | **+15-22% slower** 🐌 |
>
> **Recommendation:** Use `while ((1))` for optimal performance. Use `while :` for POSIX compatibility. Avoid `while true` due to command execution overhead.
>
> See `/ai/scripts/bcx/docs/BENCHMARK-RESULTS.md` for complete analysis.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ RECOMMENDED - Infinite loop with break condition (fastest option)
monitor_service() {
  local -- service="$1"
  local -i interval="${2:-5}"

  info "Monitoring service: $service (interval: ${interval}s)"

  while ((1)); do
    if ! systemctl is-active --quiet "$service"; then
      error "Service $service is down!"
      # Could send alert here
    else
      info "Service $service is running"
    fi

    sleep "$interval"
  done
}

# ✓ RECOMMENDED - Infinite loop with exit condition
daemon_loop() {
  local -- pid_file='/var/run/daemon.pid'

  # Create PID file
  echo "$$" > "$pid_file"

  # Cleanup on exit
  trap 'rm -f "$pid_file"' EXIT

  info 'Daemon started'

  while ((1)); do
    # Check if we should stop
    if [[ ! -f "$pid_file" ]]; then
      info 'PID file removed, stopping daemon'
      break
    fi

    # Do work
    process_queue

    # Sleep between iterations
    sleep 1
  done

  info 'Daemon stopped'
}

# ✓ RECOMMENDED - Interactive loop
interactive_menu() {
  local -- choice

  while ((1)); do
    echo ''
    echo 'Menu:'
    echo '  1) Start service'
    echo '  2) Stop service'
    echo '  3) Check status'
    echo '  q) Quit'
    echo ''
    read -r -p 'Choice: ' choice

    case "$choice" in
      1) start_service ;;
      2) stop_service ;;
      3) check_status ;;
      q|Q) info 'Goodbye!'; break ;;
      *) warn 'Invalid choice' ;;
    esac
  done
}

# ✓ ACCEPTABLE - POSIX-compatible infinite loop (for /bin/sh scripts)
posix_daemon() {
  # Use while : when POSIX compatibility is required
  while :; do
    process_item || break
    sleep 1
  done
}

# ✗ AVOID - Slowest option due to command execution overhead
slow_monitor() {
  while true; do  # Not recommended: 15-22% slower than while ((1))
    check_status
    sleep 5
  done
}

main() {
  # monitor_service 'nginx' 10  # Would run forever
  # daemon_loop  # Would run forever
  interactive_menu
}

main "$@"

#fin
```

**Nested loops:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ✓ CORRECT - Process matrix data
process_matrix() {
  local -a rows=('row1' 'row2' 'row3')
  local -a cols=('col1' 'col2' 'col3')
  local -- row col

  for row in "${rows[@]}"; do
    for col in "${cols[@]}"; do
      echo "Processing: $row, $col"
    done
  done
}

# ✓ CORRECT - Cross-product iteration
test_combinations() {
  local -a environments=('dev' 'staging' 'prod')
  local -a regions=('us-east' 'us-west' 'eu-west')
  local -- env region

  for env in "${environments[@]}"; do
    for region in "${regions[@]}"; do
      info "Testing: $env in $region"
      # Run tests
    done
  done
}

# ✓ CORRECT - Process directory tree
process_tree() {
  local -- base_dir="$1"
  local -a dirs=("$base_dir"/*)
  local -- dir file

  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    info "Processing directory: $dir"

    for file in "$dir"/*; do
      if [[ -f "$file" ]]; then
        info "  Processing file: $file"
      fi
    done
  done
}

main() {
  process_matrix
  test_combinations
  process_tree "$SCRIPT_DIR"
}

main "$@"

#fin
```

**Complete example - File processor with multiple loop types:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# ============================================================================
# Global Variables
# ============================================================================

declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i MAX_RETRIES=3
declare -- OUTPUT_DIR=''
declare -a INPUT_PATTERNS=()

# ============================================================================
# Messaging Functions
# ============================================================================

_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    info) prefix+=" ◉" ;;
    warn) prefix+=" ⚠" ;;
    error) prefix+=" ✗" ;;
    success) prefix+=" ✓" ;;
    *) ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}

info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
success() { >&2 _msg "$@"; }

die() {
  (($# > 2)) && error "${@:2}"
  exit "${1:-1}"
}

# ============================================================================
# Helper Functions
# ============================================================================

noarg() {
  (($# > 1)) && [[ "${2:0:1}" != '-' ]] || die 22 "Option ${1@Q} requires an argument"
}

# Retry command with backoff
retry_with_backoff() {
  local -i attempt=1
  local -i wait_time=1

  while ((attempt <= MAX_RETRIES)); do
    ((VERBOSE)) && info "Attempt $attempt of $MAX_RETRIES"

    if "$@"; then
      return 0
    fi

    if ((attempt < MAX_RETRIES)); then
      warn "Failed, retrying in $wait_time seconds..."
      sleep "$wait_time"
      wait_time=$((wait_time * 2))
    fi

    ((attempt+=1))
  done

  error "All $MAX_RETRIES attempts failed"
  return 1
}

# ============================================================================
# Business Logic
# ============================================================================

# Process single file with retry logic
process_file() {
  local -- file="$1"

  # Validate file
  if [[ ! -f "$file" ]]; then
    error "File not found ${file@Q}"
    return 2
  fi

  if [[ ! -r "$file" ]]; then
    error "File not readable ${file@Q}"
    return 1
  fi

  if [[ ! -s "$file" ]]; then
    warn "File is empty ${file@Q}"
    return 0
  fi

  if ((DRY_RUN)); then
    info "[DRY-RUN] Would process: $file"
    return 0
  fi

  info "Processing: $file"

  # Process file line by line
  local -- line
  local -i line_count=0

  while IFS= read -r line; do
    # Skip empty lines
    [[ -n "$line" ]] || continue

    # Skip comments
    [[ ! "$line" =~ ^# ]] || continue

    ((line_count+=1))
    ((VERBOSE)) && info "  Line $line_count: $line" || :

    # Process line (with retry)
    retry_with_backoff process_line "$line" || {
      error "Failed to process line $line_count in ${file@Q}"
      return 1
    }
  done < "$file"

  success "Processed $line_count lines from: $file"
  return 0
}

process_line() {
  local -- line="$1"
  # Line processing logic here
  sleep 0.1  # Simulate work
}

# Collect files matching patterns
collect_files() {
  local -a files=()
  local -- pattern file

  # Iterate over each pattern
  for pattern in "${INPUT_PATTERNS[@]}"; do
    ((VERBOSE)) && info "Searching for pattern: $pattern"

    # Iterate over glob matches
    for file in $pattern; do
      # Check if glob matched anything
      if [[ ! -e "$file" ]]; then
        ((VERBOSE)) && warn "No matches for pattern: $pattern"
        continue
      fi

      if [[ -f "$file" ]]; then
        files+=("$file")
      fi
    done
  done

  # Check if we found any files
  if [[ ${#files[@]} -eq 0 ]]; then
    error 'No files found matching patterns'
    return 1
  fi

  # Return files (print to stdout)
  printf '%s\n' "${files[@]}"
}

# ============================================================================
# Main Function
# ============================================================================

main() {
  # Parse arguments with while loop
  while (($#)); do
    case $1 in
      -v|--verbose)
        VERBOSE=1
        ;;

      -n|--dry-run)
        DRY_RUN=1
        ;;

      -r|--retries)
        noarg "$@"
        shift
        MAX_RETRIES="$1"
        ;;

      -o|--output)
        noarg "$@"
        shift
        OUTPUT_DIR="$1"
        ;;

      -h|--help)
        echo 'Usage: script.sh [OPTIONS] PATTERN...'
        echo 'Options:'
        echo '  -v, --verbose    Verbose output'
        echo '  -n, --dry-run    Dry-run mode'
        echo '  -r, --retries N  Max retry attempts'
        echo '  -o, --output DIR Output directory'
        return 0
        ;;

      --)
        shift
        INPUT_PATTERNS+=("$@")
        break
        ;;

      -*)
        die 22 "Invalid option: $1"
        ;;

      *)
        INPUT_PATTERNS+=("$1")
        ;;
    esac
    shift
  done

  # Collect remaining arguments
  INPUT_PATTERNS+=("$@")

  # Make variables readonly
  readonly -- VERBOSE DRY_RUN MAX_RETRIES OUTPUT_DIR
  readonly -a INPUT_PATTERNS

  # Validate
  if [[ ${#INPUT_PATTERNS[@]} -eq 0 ]]; then
    die 22 'No file patterns specified'
  fi

  # Display configuration
  if ((VERBOSE)); then
    info "$SCRIPT_NAME $VERSION"
    info "Patterns: ${INPUT_PATTERNS[*]}"
    info "Max retries: $MAX_RETRIES"
    ((DRY_RUN)) && info '[DRY-RUN] Mode enabled'
  fi

  # Collect matching files
  local -a files
  if ! readarray -t files < <(collect_files); then
    die 1 'Failed to collect files'
  fi

  info "Found ${#files[@]} files to process"

  # Process each file with for loop
  local -- file
  local -i success_count=0
  local -i error_count=0

  for file in "${files[@]}"; do
    if process_file "$file"; then
      ((success_count+=1))
    else
      ((error_count+=1))
    fi
  done

  # Report results
  info "Results: $success_count succeeded, $error_count failed"

  # Return appropriate exit code
  ((error_count == 0))
}

# ============================================================================
# Script Invocation
# ============================================================================

main "$@"

#fin
```

**Anti-patterns to avoid:**

```bash
# ✗ Wrong - iterating over unquoted string
files_str="file1.txt file2.txt file with spaces.txt"
for file in $files_str; do  # Word splitting!
  echo "$file"
done

# ✓ Correct - iterate over array
files=('file1.txt' 'file2.txt' 'file with spaces.txt')
for file in "${files[@]}"; do
  echo "$file"
done

# ✗ Wrong - parsing ls output
for file in $(ls *.txt); do  # NEVER parse ls!
  process "$file"
done

# ✓ Correct - use glob directly
for file in *.txt; do
  process "$file"
done

# ✗ Wrong - pipe to while (subshell issue)
count=0
cat file.txt | while read -r line; do
  ((count+=1))
done
echo "$count"  # Still 0!

# ✓ Correct - process substitution
count=0
while read -r line; do
  ((count+=1))
done < <(cat file.txt)
echo "$count"  # Correct value

# ✗ Wrong - unquoted array in for loop
array=('item 1' 'item 2')
for item in ${array[@]}; do  # Unquoted!
  echo "$item"
done

# ✓ Correct - quoted array expansion
for item in "${array[@]}"; do
  echo "$item"
done

# ✗ Wrong - C-style loop with ++
for ((i=0; i<10; i++)); do  # Fails with set -e when i=0!
  echo "$i"
done

# ✓ Correct - use +=1 instead
for ((i=0; i<10; i+=1)); do
  echo "$i"
done

# ✗ Wrong - redundant comparison in arithmetic context
while (($# > 0)); do  # Nonsense: $# is already truthy when non-zero
  case $1 in
    --opt) shift ;;
  esac
  shift
done

# ✓ Correct - arithmetic context evaluates non-zero as true
while (($#)); do  # Clean and idiomatic
  case $1 in
    --opt) shift ;;
  esac
  shift
done

# ✗ Wrong - break with no argument (ambiguous in nested loops)
for i in {1..10}; do
  for j in {1..10}; do
    if ((i * j > 50)); then
      break  # Breaks inner loop only - unclear
    fi
  done
done

# ✓ Correct - explicit break level
for i in {1..10}; do
  for j in {1..10}; do
    if ((i * j > 50)); then
      break 2  # Break both loops - clear intent
    fi
  done
done

# ✗ Wrong - modifying array during iteration
array=(a b c d)
for item in "${array[@]}"; do
  array+=("$item")  # Dangerous - modifies array being iterated!
done

# ✓ Correct - create new array
original=(a b c d)
modified=()
for item in "${original[@]}"; do
  modified+=("$item" "$item")  # Safe - different array
done

# ✗ Wrong - seq for iteration (external command)
for i in $(seq 1 10); do  # Unnecessary external command
  echo "$i"
done

# ✓ Correct - use brace expansion
for i in {1..10}; do
  echo "$i"
done

# ✗ Wrong - reading file without preserving backslashes
while read line; do  # Missing -r flag
  echo "$line"
done < file.txt

# ✓ Correct - always use -r with read
while IFS= read -r line; do
  echo "$line"
done < file.txt

# ✗ Wrong - infinite loop without safety check
while ((1)); do
  process_item
  # No break condition - runs forever!
done

# ✓ Correct - infinite loop with exit condition (using fastest construct)
iteration=0
max_iterations=1000
while ((1)); do
  process_item

  ((iteration+=1))
  if ((iteration >= max_iterations)); then
    warn 'Max iterations reached'
    break
  fi
done
```

**Edge cases:**

**1. Empty arrays:**

```bash
# Empty array is safe to iterate
empty=()

# Zero iterations - no errors
for item in "${empty[@]}"; do
  echo "$item"  # Never executes
done
```

**2. Arrays with empty elements:**

```bash
# Array with empty string element
array=('' 'item2' '' 'item4')

# Iterates 4 times, including empty strings
for item in "${array[@]}"; do
  echo "Item: [$item]"
done
# Output:
# Item: []
# Item: [item2]
# Item: []
# Item: [item4]
```

**3. Glob with no matches:**

```bash
# With nullglob enabled
shopt -s nullglob

for file in /nonexistent/*.txt; do
  echo "$file"  # Never executes if no matches
done

# Without nullglob
shopt -u nullglob

for file in /nonexistent/*.txt; do
  # Executes once with literal: /nonexistent/*.txt
  if [[ ! -e "$file" ]]; then
    echo 'No matches'
    break
  fi
  echo "$file"
done
```

**4. Loop variable scope:**

```bash
# Loop variables are not local
for i in {1..5}; do
  echo "$i"
done
echo "i is still available: $i"  # Prints: 5

# Make loop variable local explicitly if needed
process_items() {
  local -i i

  for i in {1..5}; do
    echo "$i"
  done
  # i goes out of scope here
}
```

**5. Reading empty files:**

```bash
# Empty file
touch empty.txt

declare -i count=0
while read -r line; do
  count+=1
done < empty.txt

echo "Count: $count"  # Output: 0 (zero iterations)
```

**Summary:**

- **For loops** - best for arrays, globs, and known ranges
- **While loops** - best for reading input, argument parsing, and condition-based iteration
- **Until loops** - rarely used, prefer while with opposite condition
- **Infinite loops** - use `while ((1))` for optimal performance, `while :` for POSIX compatibility, avoid `while true` (15-22% slower)
- **Always quote arrays** - `"${array[@]}"` for safe iteration
- **Use process substitution** - `< <(command)` to avoid subshell in while loops
- **Prefer arrays over strings** - for file lists and collections
- **Never parse ls** - use glob patterns or find with process substitution
- **Use i+=1 not i++** - ++ returns original value, fails with set -e when 0
- **Avoid redundant comparisons** - use `while (($#))` not `while (($# > 0))` in arithmetic context
- **Break and continue** - for early exit and conditional skipping
- **Specify break level** - `break 2` for nested loops
- **IFS= read -r** - always use with while loops reading input
- **Check glob matches** - with nullglob or explicit check

**Key principle:** Choose the loop type that matches your iteration pattern: for loops for collections and ranges, while loops for streaming input and conditions. Always prefer array iteration over string parsing, use process substitution to avoid subshell issues, and employ explicit loop control with break/continue for clarity. The loop type should make your intent immediately obvious to readers.
