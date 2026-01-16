## Case Statements

**Use `case` for multi-way branching on pattern matching. More readable and efficient than long `if/elif` chains. Compact format for simple single-action cases; expanded format for multi-line logic. Always align actions consistently.**

**Rationale:**
- Clearer than if/elif for pattern-based branching; native wildcards, alternation, character classes
- Faster than multiple if/elif tests (single evaluation); easy to add/remove/reorder cases
- Default `*)` ensures exhaustive matching; column alignment makes structure obvious

**When to use case vs if/elif:**

```bash
# ✓ Use case - single variable against multiple values
case "$action" in
  start)   start_service ;;
  stop)    stop_service ;;
  restart) restart_service ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Use case - pattern matching or argument parsing
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
esac

# ✗ Use if/elif - different variables, complex conditions, numeric ranges
if [[ ! -f "$file" ]]; then die 2 "File not found"; fi
if ((value < 0)); then error='negative'; fi
```

**Case expression quoting:**

```bash
# ✓ No quotes needed on case expression (not subject to word splitting)
case ${1:-} in
  --help) show_help ;;
esac

# ✗ UNNECESSARY - quotes don't add value
case "${1:-}" in ...
```

**Compact format** - single action per case, `;;` on same line, align at column 14-18:

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

**Expanded format** - multi-line actions, `;;` on separate line, blank line between cases:

```bash
while (($#)); do
  case $1 in
    -p|--prefix)   noarg "$@"
                   shift
                   PREFIX=$1
                   BIN_DIR="$PREFIX"/bin
                   ;;

    -[bpvqVh]?*)  # Bundled short options
                   set -- "${1:0:2}" "-${1:2}" "${@:2}"
                   continue
                   ;;

    -*)            error "Invalid option ${1@Q}"
                   show_help
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
esac

# Wildcard patterns
case "$filename" in
  *.txt)   echo 'Text file' ;;
  ??)      echo 'Two-character' ;;    # ? = single char
  /usr/*)  echo 'System path' ;;
esac

# Alternation (OR patterns)
case "$option" in
  -h|--help|help)     show_help ;;
  *.txt|*.md|*.rst)   echo 'Text document' ;;
esac

# Character classes and extglob (requires: shopt -s extglob)
case "$input" in
  [0-9])         echo 'Digit' ;;
  [a-z])         echo 'Lowercase' ;;
  [!a-zA-Z0-9])  echo 'Special character' ;;
  test?(s))      echo 'test or tests' ;;           # ?(pat) = 0 or 1
  log+([0-9]))   echo 'log followed by digits' ;;  # +(pat) = 1 or more
  @(start|stop)) echo 'Valid action' ;;            # @(pat) = exactly one
  !(*.tmp))      echo 'Not temp file' ;;           # !(pat) = except
esac
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting patterns / not quoting test variable
case "$value" in "start") ... esac    # Don't quote literal patterns
case $filename in *.txt) ... esac     # DO quote test variable

# ✗ Wrong - using if/elif for simple pattern matching
if [[ "$ext" == 'txt' ]]; then process_text
elif [[ "$ext" == 'pdf' ]]; then process_pdf
fi
# ✓ Use case instead

# ✗ Wrong - missing default case (silent failure)
case "$action" in start) ... ;; stop) ... ;; esac
# ✓ Always include: *) die 22 "Invalid" ;;

# ✗ Wrong - inconsistent format / poor alignment
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT=$1 ;;        # Don't mix formats
esac

# ✗ Wrong - missing ;; terminator
case "$value" in start) start_service stop) ... esac

# ✗ Wrong - expecting regex (case uses glob patterns)
case "$input" in [0-9]+) ... esac  # Matches single digit only!
# ✓ Use extglob: +([0-9])) or use if with =~

# ✗ Wrong - side effects in patterns
case "$value" in $(complex_function)) ... esac  # Called every case!
# ✓ Evaluate once before case: result=$(func); case "$value" in "$result") ...

# ✗ Wrong - nested case for multiple variables
case "$var1" in value1) case "$var2" in ... esac ;; esac
# ✓ Use if for multiple variable tests
```

**Edge cases:**

```bash
# Empty string handling
case "$value" in
  '')              echo 'Empty string' ;;
  ''|' '|$'\t')    echo 'Blank or whitespace' ;;
esac

# Special characters - quote patterns
case "$filename" in
  'file (1).txt')      echo 'Match parentheses' ;;
  'file [backup].txt') echo 'Match brackets' ;;
esac

# Numeric patterns (treated as strings)
case "$port" in
  80|443)                    echo 'Web port' ;;
  [0-9][0-9][0-9][0-9])      echo 'Four-digit port' ;;
esac
# For numeric comparison, use (()) instead
```

**Summary:**
- Quote test variable `case "$var" in`, don't quote literal patterns
- Always include default `*)` case
- Use alternation `pat1|pat2)` and wildcards `*.txt)`
- Enable extglob for advanced patterns `@()`, `!()`, `+()`, `?()`
- Compact format for simple flags; expanded for complex logic
- Prefer case over if/elif for single-variable multi-value tests
- Use if for multiple variables, ranges, complex conditions
