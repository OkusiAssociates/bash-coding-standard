## Case Statements

**Use `case` for multi-way branching on pattern matching; more readable/efficient than if/elif chains. Always include default `*)` case.**

**Rationale:** Single evaluation (faster than if/elif), native pattern matching with wildcards/alternation, exhaustive matching via `*)`

**When to use:** Single variable against multiple values, pattern matching, argument parsing
**When NOT to use:** Different variables, complex conditionals, numeric ranges → use if/elif

**Case expression:** No quotes needed (`case $1 in` not `case "$1" in`)

**Compact format** (single actions):
```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Expanded format** (multi-line actions): Action on next line indented, `;;` on separate line, blank lines between cases.

**Pattern syntax:**
- Literals: `start)` → don't quote
- Wildcards: `*.txt)`, `???)`
- Alternation: `-h|--help)`
- Extglob: `@(start|stop)`, `!(*.tmp)`, `+([0-9])`

**Anti-patterns:**
- Missing `*)` default → silent failures
- Quoting patterns: `"start")` → use `start)`
- Inconsistent alignment
- Nested case for multi-var → use if/elif
- Missing `;;` terminator

**Ref:** BCS0502
