## Case Statements

**Use `case` statements for multi-way branching based on pattern matching. Case statements are more readable and efficient than long `if/elif` chains when testing a single value against multiple patterns. Choose compact format for simple single-action cases, and expanded format for multi-line logic.**

**Rationale:**

- **Readability & Maintainability**: Clearer than if/elif chains; easy to add/remove/reorder cases
- **Performance**: Single evaluation vs multiple if/elif tests
- **Pattern Matching**: Native wildcards, alternation, character classes
- **Argument Parsing**: Ideal for command-line options
- **Exhaustive Handling**: Default `*)` ensures all cases handled
- **Visual Organization**: Column alignment clarifies structure

**When to use case vs if/elif:**

```bash
# ✓ Case for - single variable, multiple patterns
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✓ Case for - pattern matching
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
esac

# ✗ if/elif for - different variables or complex conditions
if [[ ! -f "$file" ]]; then
  die 2 "File not found: $file"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable: $file"
fi
```

**Compact format** - single action per case:

```bash
# Guidelines: action + ;; on same line, align ;; at column 14-18, no blank lines
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions:

```bash
# Guidelines: action on next line indented, ;; on separate line, blank line after ;;
while (($#)); do
  case $1 in
    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX/bin"
                      ;;

    -v|--verbose)     VERBOSE=1
                      info 'Verbose mode enabled'
                      ;;

    -*)               error "Invalid option: $1"
                      exit 22
                      ;;
  esac
  shift
done
```

**Pattern syntax:**

```bash
# 1. Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  'admin@example.com') echo 'Admin' ;;  # Quote if special chars
esac

# 2. Wildcards
case "$filename" in
  *.txt) echo 'Text file' ;;           # * = any characters
  ??) echo 'Two-char code' ;;          # ? = single character
  /usr/*) echo 'System path' ;;        # Prefix matching
esac

# 3. Alternation (OR)
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  *.txt|*.md|*.rst) echo 'Text document' ;;
esac

# 4. Extglob patterns (requires shopt -s extglob)
case "$input" in
  ?(s)) echo 'zero or one' ;;
  *(s)) echo 'zero or more' ;;
  +(s)) echo 'one or more' ;;
  @(start|stop)) echo 'exactly one' ;;
  !(*.tmp|*.bak)) echo 'not tmp/bak' ;;
esac

# 5. Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [!a-zA-Z0-9]) echo 'Special' ;;
esac
```

**Complete argument parsing:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0 FORCE=0
declare -- OUTPUT_DIR='' CONFIG_FILE="$SCRIPT_DIR/config.conf"
declare -a INPUT_FILES=()

main() {
  while (($#)); do
    case $1 in
      -v|--verbose)     VERBOSE=1 ;;
      -n|--dry-run)     DRY_RUN=1 ;;
      -f|--force)       FORCE=1 ;;
      -o|--output)      noarg "$@"; shift; OUTPUT_DIR="$1" ;;
      -c|--config)      noarg "$@"; shift; CONFIG_FILE="$1" ;;
      -V|--version)     echo "$SCRIPT_NAME $VERSION"; return 0 ;;
      -h|--help)        usage; return 0 ;;
      --)               shift; break ;;
      -*)               die 22 "Invalid option: $1" ;;
      *)                INPUT_FILES+=("$1") ;;
    esac
    shift
  done

  INPUT_FILES+=("$@")
  readonly -- VERBOSE DRY_RUN FORCE OUTPUT_DIR CONFIG_FILE
  readonly -a INPUT_FILES

  [[ ${#INPUT_FILES[@]} -eq 0 ]] && die 22 'No input files specified'
}

main "$@"
#fin
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file="$1" filename="${file##*/}"

  case "$filename" in
    *.txt|*.md|*.rst)        process_text "$file" ;;
    *.jpg|*.jpeg|*.png|*.gif) process_image "$file" ;;
    *.pdf)                   process_pdf "$file" ;;
    *.sh|*.bash)             shellcheck "$file" ;;
    .*)                      warn "Skip hidden: $file"; return 0 ;;
    *.tmp|*.bak|*~)          warn "Skip temp: $file"; return 0 ;;
    *)                       error "Unknown type: $file"; return 1 ;;
  esac
}
```

**Service control:**

```bash
main() {
  local -- action="${1:-}"
  [[ -z "$action" ]] && die 22 'No action specified'

  case "$action" in
    start)      start_service ;;
    stop)       stop_service ;;
    restart)    restart_service ;;
    status)     status_service ;;
    reload)     reload_service ;;
    st|stat)    status_service ;;    # Aliases
    *)          die 22 "Invalid action: $action" ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting literal patterns
case "$value" in
  "start") echo 'Starting...' ;;  # Don't quote literals
esac

# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - unquoted test variable
case $filename in  # Unquoted!
  *.txt) process ;;
esac

# ✓ Correct - quote test variable
case "$filename" in
  *.txt) process ;;
esac

# ✗ Wrong - if/elif for pattern matching
if [[ "$ext" == 'txt' ]]; then
  process_text
elif [[ "$ext" == 'pdf' ]]; then
  process_pdf
fi

# ✓ Correct - use case
case "$ext" in
  txt) process_text ;;
  pdf) process_pdf ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac  # Silent failure!

# ✓ Correct - always include default
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✗ Wrong - inconsistent format
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift       # Mixing compact/expanded
      OUTPUT="$1"
      ;;
esac

# ✓ Correct - consistent format
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift; OUTPUT="$1" ;;
esac

# ✗ Wrong - poor alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force) FORCE=1 ;;  # Inconsistent
esac

# ✓ Correct - aligned
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force)   FORCE=1 ;;
esac

# ✗ Wrong - missing ;; terminator
case "$value" in
  start) start_service
  stop) stop_service  # No ;;
esac

# ✓ Correct
case "$value" in
  start) start_service ;;
  stop) stop_service ;;
esac

# ✗ Wrong - regex patterns (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;  # Matches single digit only!
esac

# ✓ Correct - extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac
# Or:
if [[ "$input" =~ ^[0-9]+$ ]]; then
  echo 'Number'
fi

# ✗ Wrong - side effects in patterns
case "$value" in
  $(complex_function)) echo 'Match' ;;  # Called every case!
esac

# ✓ Correct - evaluate once
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac
```

**Edge cases:**

```bash
# Empty string
case "$value" in
  '') echo 'Empty' ;;
  *) echo "Value: $value" ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt') echo 'Parentheses' ;;
  'file$special.txt') echo 'Dollar' ;;
esac

# Numeric strings (not arithmetic)
case "$port" in
  80|443) echo 'Web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four-digit' ;;
esac

# Case in functions with return codes
validate_input() {
  local -- input="$1"
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) warn 'Should be lowercase'; return 1 ;;
    '') error 'Empty'; return 22 ;;
    *) error 'Invalid'; return 1 ;;
  esac
}

# Multi-level routing
main() {
  case "$1" in
    user) handle_user_commands "${@:2}" ;;
    group) handle_group_commands "${@:2}" ;;
    *) die 22 "Invalid: $1" ;;
  esac
}
```

**Summary:**

- Use case for single-variable pattern matching, not if/elif chains
- Compact format: single-line actions with aligned `;;`
- Expanded format: multi-line actions, `;;` on separate line
- Always quote test variable: `case "$var" in`
- Don't quote literal patterns: `start)` not `"start")`
- Always include default `*)` case
- Use alternation `|` for multiple patterns
- Leverage wildcards (`*.txt`) and extglob (`@(a|b)`, `!(*.tmp)`)
- Consistent alignment and format
- Terminate every branch with `;;`
