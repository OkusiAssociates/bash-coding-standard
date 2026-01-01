## Case Statements

**Use `case` for multi-way branching based on pattern matching. More readable and efficient than if/elif chains for single-value tests. Use compact format for single-action cases, expanded format for multi-line logic. Always align consistently and include default `*)` case.**

**Rationale:**
- Clearer than if/elif for pattern-based branching; native wildcards/alternation support
- Faster than multiple if/elif tests (single evaluation of test value)
- Easy to add/reorder cases; default `*)` ensures exhaustive handling

**When to use case vs if/elif:**

```bash
# ✓ Use case - testing single variable against multiple values
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

# ✗ Use if/elif - testing different variables or complex logic
if [[ ! -f "$file" ]]; then
  die 2 "File not found ${file@Q}"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable ${file@Q}"
fi

# ✗ Use if/elif - numeric ranges
if ((value < 0)); then error='negative'
elif ((value <= 10)); then category='small'
else category='large'
fi
```

**Case expression quoting:**

```bash
# ✓ CORRECT - no quotes needed on case expression
case ${1:-} in
  --help) usage ;;
esac

# ✗ UNNECESSARY - quotes don't add value
case "${1:-}" in
  --help) usage ;;
esac
```

Word splitting doesn't apply in case expression context; omitting quotes reduces clutter.

**Compact format** - single action per case:

```bash
# Compact case for simple argument parsing
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    usage; exit 0 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT_FILE="$1" ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** - multi-line actions:

```bash
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      ((VERBOSE)) && info 'Builtin installation enabled' ||:
                      ;;

    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX=$1
                      BIN_DIR="$PREFIX"/bin
                      ;;

    --)               shift
                      break
                      ;;

    -*)               error "Invalid option ${1@Q}"
                      usage
                      exit 22
                      ;;
  esac
  shift
done
```

**Pattern matching syntax:**

```bash
# Literal patterns
case "$value" in
  start) echo 'Starting...' ;;
  stop) echo 'Stopping...' ;;
esac

# Wildcard patterns (globbing)
case "$filename" in
  *.txt) echo 'Text file' ;;
  *.pdf) echo 'PDF file' ;;
  *)     echo 'Unknown file type' ;;
esac

# Question mark - single character
case "$code" in
  ??)  echo 'Two-character code' ;;
  ???) echo 'Three-character code' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  -v|--verbose|verbose) VERBOSE+=1 ;;
esac

# Character classes with extglob
shopt -s extglob
case "$input" in
  ?(pattern))      echo 'zero or one' ;;
  *(pattern))      echo 'zero or more' ;;
  +(pattern))      echo 'one or more' ;;
  @(start|stop))   echo 'exactly one' ;;
  !(*.tmp|*.bak))  echo 'anything except' ;;
esac

# Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [A-Z]) echo 'Uppercase' ;;
esac
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file=$1
  local -- filename=${file##*/}

  case "$filename" in
    *.txt|*.md|*.rst)
      process_text "$file"
      ;;
    *.jpg|*.jpeg|*.png|*.gif)
      process_image "$file"
      ;;
    .*)
      warn "Skipping hidden file ${file@Q}"
      return 0
      ;;
    *.tmp|*.bak|*~)
      warn "Skipping temporary file ${file@Q}"
      return 0
      ;;
    *)
      error "Unknown file type ${file@Q}"
      return 1
      ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting literal patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;
esac
# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac
# What if $action is 'restart'? Silent failure!
# ✓ Always include default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action ${action@Q}" ;;
esac

# ✗ Wrong - inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT=$1
      ;;
esac
# ✓ Correct - consistent compact or expanded

# ✗ Wrong - poor column alignment
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -f|--force) FORCE=1 ;;
esac
# ✓ Correct - aligned columns
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -f|--force)   FORCE=1 ;;
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
# ✓ Evaluate once before case
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac
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
  80|443) echo 'Standard web port' ;;
  22)     echo 'SSH port' ;;
esac
# For numeric comparison, use (()) instead

# Case in functions with return values
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
- **Compact format**: single-line actions, aligned `;;`
- **Expanded format**: multi-line actions, `;;` on separate line
- **Always quote test variable**: `case "$var" in`
- **Don't quote literal patterns**: `start)` not `"start")`
- **Include default case**: `*)` handles unexpected values
- **Use alternation**: `pattern1|pattern2)` for multiple matches
- **Enable extglob**: for `@()`, `!()`, `+()` patterns
- **Align consistently**: same column for actions
- **Terminate with `;;`**: every case branch needs it
