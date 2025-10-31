## Case Statements

**Use `case` statements for multi-way branching on pattern matching. Case statements are clearer and faster than long `if/elif` chains when testing a single value against multiple patterns. Choose compact format for simple single-action cases, expanded format for multi-line logic.**

**Rationale:**

- **Clarity & Maintenance**: Clearer than if/elif chains for pattern-based branching; easy to add/remove/reorder cases
- **Pattern Matching**: Native wildcards, alternation, character classes support
- **Performance**: Single evaluation of test value vs. multiple if/elif tests
- **Exhaustive Handling**: Default `*)` case ensures all possibilities handled
- **Visual Structure**: Column alignment makes organization immediately obvious

**When to use case vs if/elif:**

```bash
# ✓ Case for - single variable, multiple values
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  restart) restart_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✓ Case for - pattern matching
case "$filename" in
  *.txt) process_text_file ;;
  *.pdf) process_pdf_file ;;
  *.md) process_markdown_file ;;
  *) die 22 "Unsupported file type" ;;
esac

# ✗ Use if/elif for - different variables or complex logic
if [[ ! -f "$file" ]]; then
  die 2 "File not found: $file"
elif [[ ! -r "$file" ]]; then
  die 1 "File not readable: $file"
fi

# ✗ Use if/elif for - numeric ranges
if ((value < 0)); then
  error='negative'
elif ((value <= 10)); then
  category='small'
fi
```

**Compact format:**

Use when each case performs single action or simple command.

**Guidelines:**
- Actions on same line as pattern, terminate with `;;` on same line
- Align `;;` at consistent column (typically 14-18)
- No blank lines between cases
- Perfect for argument parsing with simple flag setting

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
    -*)           die 22 "Invalid option: $1" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format:**

Use when cases have multi-line actions or complex operations.

**Guidelines:**
- Action starts next line, indented
- Terminate with `;;` on separate line, left-aligned
- Blank line after `;;` separates cases visually
- Comments within branches acceptable

```bash
# Expanded case for complex argument parsing
while (($#)); do
  case $1 in
    -p|--prefix)      noarg "$@"
                      shift
                      PREFIX="$1"
                      BIN_DIR="$PREFIX/bin"
                      ((VERBOSE)) && info "Prefix set to: $PREFIX"
                      ;;

    -v|--verbose)     VERBOSE=1
                      info 'Verbose mode enabled'
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

**1. Literal patterns:**

```bash
# Exact string match
case "$value" in
  start) echo 'Starting...' ;;
  stop) echo 'Stopping...' ;;
esac

# Quote if special characters
case "$email" in
  'admin@example.com') echo 'Admin user' ;;
esac
```

**2. Wildcard patterns:**

```bash
# Star wildcard - matches any characters
case "$filename" in
  *.txt) echo 'Text file' ;;
  *.pdf) echo 'PDF file' ;;
  *) echo 'Unknown file type' ;;
esac

# Question mark - single character
case "$code" in
  ??) echo 'Two-character code' ;;
  ???) echo 'Three-character code' ;;
esac

# Prefix/suffix matching
case "$path" in
  /usr/*) echo 'System path' ;;
  /home/*) echo 'Home directory' ;;
esac
```

**3. Alternation (OR patterns):**

```bash
# Multiple patterns with |
case "$option" in
  -h|--help|help) usage; exit 0 ;;
  -v|--verbose|verbose) VERBOSE=1 ;;
esac

# Combining alternation with wildcards
case "$filename" in
  *.txt|*.md|*.rst) echo 'Text document' ;;
  *.jpg|*.png|*.gif) echo 'Image file' ;;
esac
```

**4. Character classes with extglob:**

```bash
shopt -s extglob

case "$input" in
  # ?(pattern) - zero or one occurrence
  test?(s)) echo 'test or tests' ;;

  # *(pattern) - zero or more occurrences
  file*(s).txt) echo 'file.txt, files.txt, etc.' ;;

  # +(pattern) - one or more occurrences
  log+([0-9]).txt) echo 'log followed by digits' ;;

  # @(pattern) - exactly one occurrence
  @(start|stop|restart)) echo 'Valid action' ;;

  # !(pattern) - anything except pattern
  !(*.tmp|*.bak)) echo 'Not temp or backup' ;;
esac

# Bracket expressions
case "$char" in
  [0-9]) echo 'Digit' ;;
  [a-z]) echo 'Lowercase letter' ;;
  [!a-zA-Z0-9]) echo 'Special character' ;;
esac
```

**File type routing example:**

```bash
process_file_by_type() {
  local -- file="$1"
  local -- filename="${file##*/}"

  case "$filename" in
    *.txt|*.md|*.rst)
      info "Processing text document: $file"
      process_text "$file"
      ;;

    *.jpg|*.jpeg|*.png|*.gif)
      info "Processing image: $file"
      process_image "$file"
      ;;

    *.sh|*.bash)
      info "Processing shell script: $file"
      validate_script "$file"
      ;;

    .*)
      warn "Skipping hidden file: $file"
      return 0
      ;;

    *.tmp|*.bak|*~)
      warn "Skipping temporary file: $file"
      return 0
      ;;

    *)
      error "Unknown file type: $file"
      return 1
      ;;
  esac
}
```

**Action routing example:**

```bash
# Service control script
main() {
  local -- action="${1:-}"

  [[ -z "$action" ]] && die 22 'No action specified'

  case "$action" in
    start)
      start_service
      ;;

    stop)
      stop_service
      ;;

    restart)
      restart_service
      ;;

    status)
      status_service
      ;;

    reload)
      reload_service
      ;;

    # Common variations
    st|stat)
      status_service
      ;;

    *)
      die 22 "Invalid action: $action"
      ;;
  esac
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - quoting patterns unnecessarily
case "$value" in
  "start") echo 'Starting...' ;;    # Don't quote literals
esac

# ✓ Correct
case "$value" in
  start) echo 'Starting...' ;;
esac

# ✗ Wrong - unquoted test variable
case $filename in    # Unquoted!
  *.txt) process_text ;;
esac

# ✓ Correct - quote test variable
case "$filename" in
  *.txt) process_text ;;
esac

# ✗ Wrong - missing default case
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
esac
# Silent failure if $action is 'restart'!

# ✓ Correct - always include default
case "$action" in
  start) start_service ;;
  stop) stop_service ;;
  *) die 22 "Invalid action: $action" ;;
esac

# ✗ Wrong - inconsistent format mixing
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift
      OUTPUT="$1"
      ;;                 # Mixing compact and expanded
  -h) usage; exit 0 ;;
esac

# ✓ Correct - consistent compact
case "$opt" in
  -v) VERBOSE=1 ;;
  -o) shift; OUTPUT="$1" ;;
  -h) usage; exit 0 ;;
esac

# ✗ Wrong - poor alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -f|--force) FORCE=1 ;;        # Inconsistent
esac

# ✓ Correct - consistent alignment
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -f|--force)   FORCE=1 ;;
esac

# ✗ Wrong - regex patterns (not supported)
case "$input" in
  [0-9]+) echo 'Number' ;;    # Matches single digit only!
esac

# ✓ Correct - use extglob or if with regex
case "$input" in
  +([0-9])) echo 'Number' ;;  # Requires extglob
esac
# Or:
if [[ "$input" =~ ^[0-9]+$ ]]; then
  echo 'Number'
fi

# ✗ Wrong - side effects in patterns
case "$value" in
  $(complex_function)) echo 'Match' ;;  # Function called every case!
esac

# ✓ Correct - evaluate once before case
result=$(complex_function)
case "$value" in
  "$result") echo 'Match' ;;
esac
```

**Edge cases:**

**1. Empty string handling:**

```bash
case "$value" in
  '') echo 'Empty string' ;;
  *) echo "Value: $value" ;;
esac

# Multiple empty possibilities
case "$input" in
  ''|' '|$'\t') echo 'Blank or whitespace' ;;
  *) echo 'Has content' ;;
esac
```

**2. Special characters:**

```bash
# Quote patterns with special characters
case "$filename" in
  'file (1).txt') echo 'Match parentheses' ;;
  'file [backup].txt') echo 'Match brackets' ;;
  'file$special.txt') echo 'Match dollar sign' ;;
esac
```

**3. Multi-level routing:**

```bash
# First level: action
main() {
  local -- action="$1"
  shift

  case "$action" in
    user)   handle_user_commands "$@" ;;
    group)  handle_group_commands "$@" ;;
    system) handle_system_commands "$@" ;;
    *)      die 22 "Invalid action: $action" ;;
  esac
}

# Second level: subcommand
handle_user_commands() {
  local -- subcommand="$1"
  shift

  case "$subcommand" in
    add) add_user "$@" ;;
    delete) delete_user "$@" ;;
    list) list_users ;;
    *) die 22 "Invalid user subcommand: $subcommand" ;;
  esac
}
```

**Summary:**

- **Use case for pattern matching** - single variable against multiple patterns
- **Compact format** - single-line actions with aligned `;;`
- **Expanded format** - multi-line actions with `;;` on separate line
- **Always quote test variable** - `case "$var" in` not `case $var in`
- **Don't quote literal patterns** - `start)` not `"start")`
- **Include default case** - always have `*)` to handle unexpected values
- **Use alternation** - `pattern1|pattern2)` for multiple matches
- **Leverage wildcards** - `*.txt)` for glob patterns
- **Enable extglob** - for advanced patterns `@()`, `!()`
- **Align consistently** - choose compact or expanded, align at same column
- **Prefer case over if/elif** - for single-variable multi-value tests
- **Terminate with ;;** - every case branch needs it
