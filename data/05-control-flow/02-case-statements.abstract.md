## Case Statements

**Use `case` for multi-way branching on single value; compact format for simple actions, expanded for multi-line logic. Always include `*)` default case.**

**Rationale:** Single evaluation faster than if/elif chains; native pattern matching (wildcards, alternation); easy to add/remove cases.

**When to use:** Single variable vs multiple values, pattern matching, argument parsing. Use if/elif for: multiple variables, complex conditions, numeric ranges.

**Format:**
- **Compact:** Single-line actions, align `;;` at column 14-18
- **Expanded:** Action on next line indented, `;;` on separate line, blank line between cases

**Quoting:** Quote test variable `case "$var" in`; don't quote case expression `case $1 in`; don't quote literal patterns `start)` not `"start")`.

**Example:**
```bash
while (($#)); do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -v|--verbose) VERBOSE+=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
    -h|--help)    show_help; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Anti-patterns:**
- Missing `*)` default â†' silent failure on unexpected values
- Mixing compact/expanded format inconsistently â†' poor readability
- Using `[0-9]+` expecting regex â†' case uses glob patterns, not regex

**Ref:** BCS0502
