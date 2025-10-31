## Case Statements

**Use `case` for multi-way branching on single variable pattern matching; more readable than `if/elif` chains.**

**Rationale:** Pattern matching support, faster single evaluation, easier maintenance.

**Format options:**

**Compact** (single-line actions):
```bash
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    usage; exit 0 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT="$1" ;;
  --)           shift; break ;;
  -*)           die 22 "Invalid: $1" ;;
esac
```

**Expanded** (multi-line actions):
```bash
case $1 in
  -p|--prefix)  noarg "$@"
                shift
                PREFIX="$1"
                ;;
  *)            die 22 "Invalid: $1"
                ;;
esac
```

**Patterns:**
- Literal: `start)` (unquoted)
- Wildcards: `*.txt)` `*.md|*.rst)`
- Alternation: `-h|--help)`
- Extglob: `+([0-9]))` `@(start|stop)` `!(*.tmp)`
- Brackets: `[0-9])` `[a-z])` `[!a-zA-Z0-9])`

**Anti-patterns:**
```bash
# ✗ Unquoted test variable
case $file in

# ✗ Quoted literal patterns
case "$val" in "start")

# ✗ Missing default case
case "$act" in start) ;; stop) ;; esac

# ✗ Inconsistent alignment
-v) VERBOSE=1 ;;
-o) shift; OUT="$1" ;;
-h) usage; exit 0 ;;

# ✓ Correct
case "$file" in
  *.txt) process ;;
  *) die 22 "Unknown: $file" ;;
esac
```

**Use case for:** Single variable patterns, file routing, CLI args
**Use if/elif for:** Multiple variables, numeric ranges, complex conditions

**Ref:** BCS0702
