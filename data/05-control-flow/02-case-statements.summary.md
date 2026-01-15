## Case Statements

**Use `case` for multi-way branching on pattern matching. More readable and efficient than if/elif chains for single-value tests. Use compact format for simple single-action cases, expanded format for multi-line logic. Always align actions consistently.**

**Rationale:**
- Pattern matching: Native wildcards, alternation, character classes
- Performance: Single evaluation vs multiple if/elif tests
- Maintainability: Easy to add/remove/reorder cases
- `*)` default ensures all possibilities handled

**When to use case vs if/elif:**

```bash
# ✓ Use case - single variable against multiple values
case "$action" in
  start)   start_service ;;
  stop)    stop_service ;;
  restart) restart_service ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Use case - pattern matching needed
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
  *)     die 22 'Unsupported file type' ;;
esac

# ✗ Use if/elif - testing different variables or complex conditions
if [[ ! -f "$file" ]]; then
  die 2 "File not found ${file@Q}"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable ${file@Q}"
fi
```

**Case expression quoting:**

No quotes needed on case expression—word splitting doesn't apply:

```bash
# ✓ CORRECT - no quotes needed
case ${1:-} in
  --help) show_help ;;
esac

# ✗ UNNECESSARY - quotes don't add value
case "${1:-}" in
  --help) show_help ;;
esac
```

**Compact format** - single-action cases, `;;` on same line, aligned at column 14-18:

```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE=$1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions, `;;` on separate line:

```bash
while (($#)); do
  case $1 in
    -p|--prefix)   noarg "$@"
                   shift
                   PREFIX=$1
                   BIN_DIR="$PREFIX"/bin
                   ((VERBOSE)) && info "Prefix set to: $PREFIX" ||:
                   ;;

    -[bpvqVh]*) #shellcheck disable=SC2046 #split up single options
                   set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
                   ;;

    -*)            die 22 "Invalid option ${1@Q}" ;;
  esac
  shift
done
```

**Pattern matching syntax:**

```bash
# Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  stop)  echo 'Stopping...' ;;
esac

# Wildcard patterns
case "$filename" in
  *.txt) echo 'Text file' ;;
  *.pdf) echo 'PDF file' ;;
  *)     echo 'Unknown' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) show_help; exit 0 ;;
  *.txt|*.md|*.rst) echo 'Text document' ;;
esac

# Character classes with extglob
shopt -s extglob
case "$input" in
  ?(pattern))     echo 'zero or one' ;;
  *(pattern))     echo 'zero or more' ;;
  +(pattern))     echo 'one or more' ;;
  @(start|stop))  echo 'exactly one' ;;
  !(*.tmp|*.bak)) echo 'anything except' ;;
esac

# Bracket expressions
case "$char" in
  [0-9])          echo 'Digit' ;;
  [a-z])          echo 'Lowercase' ;;
  [!a-zA-Z0-9])   echo 'Special character' ;;
esac
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;  # Don't quote literal patterns
esac

# ✓ Correct - unquoted literal patterns
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - using if/elif for simple pattern matching
if [[ "$ext" == 'txt' ]]; then
  process_text
elif [[ "$ext" == 'pdf' ]]; then
  process_pdf
fi

# ✓ Correct - case is clearer
case "$ext" in
  txt) process_text ;;
  pdf) process_pdf ;;
  *)   die 1 'Unknown type' ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop)  stop_service ;;
esac  # What if $action is 'restart'? Silent failure!

# ✗ Wrong - inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT=$1
      ;;              # Mixing compact and expanded
esac

# ✗ Wrong - missing ;; terminator
case "$value" in
  start) start_service
  stop) stop_service   # Missing ;;
esac

# ✗ Wrong - regex patterns (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;  # Matches single digit only!
esac

# ✓ Correct - use extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac

# ✗ Wrong - side effects in patterns
case "$value" in
  $(complex_function)) echo 'Match' ;;  # Called for every case!
esac

# ✓ Correct - evaluate once before case
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac

# ✗ Wrong - nested case for multiple variables
case "$var1" in
  value1) case "$var2" in
    value2) action ;;
  esac ;;
esac

# ✓ Correct - use if for multiple variable tests
if [[ "$var1" == value1 && "$var2" == value2 ]]; then
  action
fi
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '')  echo 'Empty string' ;;
  *)   echo "Value: $value" ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt')      echo 'Match parentheses' ;;
  'file [backup].txt') echo 'Match brackets' ;;
esac

# Numeric patterns (as strings)
case "$port" in
  80|443)  echo 'Standard web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four-digit port' ;;
esac
# For numeric comparison, use (()) instead

# Return values in functions
validate_input() {
  local -- input=$1
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) return 1 ;;
    '')     return 22 ;;
    *)      return 1 ;;
  esac
}
```

**Summary:**
- Use case for pattern matching single variable against multiple patterns
- Compact format: single-line actions with aligned `;;`
- Expanded format: multi-line actions with `;;` on separate line
- Don't quote case expression; don't quote literal patterns
- Always include `*)` default case
- Use `|` for alternation, `*` `?` for wildcards, extglob for advanced patterns
- Use if/elif for multiple variables, ranges, complex conditions
- Terminate every branch with `;;`
