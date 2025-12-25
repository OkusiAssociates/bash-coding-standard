## Case Statements

**Use `case` for multi-way branching on pattern matching. More readable and efficient than long `if/elif` chains when testing single value against multiple patterns. Use compact format for simple single-action cases, expanded for multi-line logic.**

**Rationale:**
- Clearer than if/elif for pattern-based branching; native wildcard, alternation, character class support
- Faster than multiple if/elif tests - single evaluation
- Easy to add/reorder cases; default `*)` ensures exhaustive matching
- Perfect for argument parsing; column alignment makes structure obvious

**When to use case vs if/elif:**

```bash
# ✓ Use case - testing single variable against multiple values
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✓ Use case - pattern matching needed
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
esac

# ✗ Use if/elif - testing different variables or complex conditions
if [[ ! -f "$file" ]]; then die 2 "Not found"; fi
if [[ "$count" -gt 100 && "$verbose" -eq 1 ]]; then info 'Large verbose batch'; fi

# ✗ Use if/elif - numeric ranges
if ((value < 0)); then error='negative'; elif ((value <= 10)); then category='small'; fi
```

**Case expression quoting:**

Case expression doesn't require quoting - word splitting doesn't apply:

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

**Compact format** - single action per case, all on same line:

```bash
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

**Expanded format** - multi-line actions with `;;` on separate line:

```bash
while (($#)); do
  case $1 in
    -b|--builtin)     INSTALL_BUILTIN=1
                      ((VERBOSE)) && info 'Builtin enabled'
                      ;;

    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX/bin"
                      ;;

    --)               shift
                      break
                      ;;

    -*)               error "Invalid option: $1"
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

# Wildcard patterns
case "$filename" in
  *.txt) echo 'Text file' ;;
  ??) echo 'Two-character' ;;
  /usr/*) echo 'System path' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  *.txt|*.md) echo 'Text document' ;;
esac

# Character classes (with extglob)
shopt -s extglob
case "$input" in
  test?(s)) echo 'test or tests' ;;           # zero or one
  log+([0-9]).txt) echo 'log + digits' ;;      # one or more
  @(start|stop)) echo 'Valid action' ;;        # exactly one
  !(*.tmp|*.bak)) echo 'Not temp/backup' ;;    # anything except
esac

# Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase' ;;
  [!a-zA-Z0-9]) echo 'Special character' ;;
esac
```

**File type routing:**

```bash
process_file_by_type() {
  local -- file="$1"
  local -- filename="${file##*/}"

  case "$filename" in
    *.txt|*.md|*.rst)   process_text "$file" ;;
    *.jpg|*.png|*.gif)  process_image "$file" ;;
    *.sh|*.bash)        validate_script "$file" ;;
    .*)                 warn "Skipping hidden: $file"; return 0 ;;
    *.tmp|*.bak|*~)     warn "Skipping temp: $file"; return 0 ;;
    *)                  error "Unknown type: $file"; return 1 ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Quoting literal patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;    # Don't quote
esac
# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Missing default case - silent failure!
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac
# ✓ Always include default
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid: $action" ;;
esac

# ✗ Inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT="$1"
      ;;                 # Mixed compact/expanded
esac
# ✓ Pick one format, be consistent

# ✗ Poor column alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force) FORCE=1 ;;
esac
# ✓ Align consistently
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -f|--force)   FORCE=1 ;;
esac

# ✗ Fall-through (not supported in Bash)
case "$code" in
  200|201) success='true'
  300|301) redirect='true' ;;    # Won't work!
esac
# ✓ Explicit pattern grouping
case "$code" in
  200|201) success='true' ;;
  300|301) redirect='true' ;;
esac

# ✗ Regex syntax (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;    # Matches single digit only!
esac
# ✓ Use extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac

# ✗ Side effects in patterns
case "$value" in
  $(func)) echo 'Match' ;;  # Function called every case!
esac
# ✓ Evaluate once before
result=$(func)
case "$value" in "$result") echo 'Match' ;; esac

# ✗ Nested case for multiple variables
case "$var1" in
  val1) case "$var2" in val2) action ;; esac ;;
esac
# ✓ Use if for multiple variable tests
if [[ "$var1" == val1 && "$var2" == val2 ]]; then action; fi
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '') echo 'Empty string' ;;
  ''|' '|$'\t') echo 'Blank or whitespace' ;;
  *) echo "Value: $value" ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt') echo 'Match parentheses' ;;
  'file$special.txt') echo 'Match dollar sign' ;;
esac

# Numeric patterns (as strings)
case "$port" in
  80|443) echo 'Web port' ;;
  [0-9][0-9][0-9][0-9]) echo 'Four-digit port' ;;
esac
# For numeric comparison, use (()) instead

# Return values in functions
validate_input() {
  local -- input="$1"
  case "$input" in
    [a-z]*) return 0 ;;
    [A-Z]*) return 1 ;;
    '') return 22 ;;
    *) return 1 ;;
  esac
}
```

**Summary:**
- **Use case for pattern matching** single variable against multiple patterns
- **Compact format** for single-line actions; **expanded** for multi-line
- **Quote test variable** `case "$var" in` - **don't quote literal patterns**
- **Always include `*)` default** to handle unexpected values
- **Use alternation** `pattern1|pattern2)` for multiple matches
- **Enable extglob** for `@()`, `!()`, `+()`, `?()`, `*()` patterns
- **Align consistently** - pick compact or expanded, maintain column alignment
- **Terminate with `;;`** - every case branch needs it
- **Use if for**: multiple variables, numeric ranges, complex conditions
