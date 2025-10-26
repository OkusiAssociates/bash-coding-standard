## Case Statements

**Use `case` for pattern-based multi-way branching. More readable/efficient than if/elif chains for testing single variable against multiple patterns.**

**Rationale:**
- **Performance:** Single evaluation vs multiple if/elif tests
- **Pattern Matching:** Native wildcards, alternation, extglob support

**Use case when:** Single variable testing, pattern matching, argument parsing
**Use if/elif when:** Different variables, complex conditionals, numeric ranges

**Format styles:**

```bash
# Compact: single-line with aligned ;;
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -h|--help)    usage; exit 0 ;;
  --)           shift; break ;;
  -*)           die 22 "Invalid: $1" ;;
  *)            FILES+=("$1") ;;
esac

# Expanded: multi-line, ;; on separate line
case $1 in
  -p|--prefix)  noarg "$@"
                shift
                PREFIX="$1"
                ;;
esac
```

**Pattern types:**
- Literal: `start)` (unquoted)
- Wildcards: `*.txt)` `*.@(md|rst))`
- Alternation: `-h|--help)`
- Extglob: `+([0-9]))` (needs `shopt -s extglob`)

**Critical rules:**
- Quote test variable: `case "$var" in`
- Don't quote patterns: `start)` not `"start")`
- Always include default: `*) die 22 "Invalid" ;;`
- Terminate with `;;`
- Align consistently

**Anti-patterns:**
- `case $var in` → unquoted test variable
- Missing `*)` default case → silent failures
- Mixing compact/expanded formats → inconsistent style

**Ref:** BCS0702
