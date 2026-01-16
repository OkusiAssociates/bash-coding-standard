## Case Statements

**Use `case` for multi-way pattern matching; prefer over if/elif chains for single-variable tests. Always include `*)` default case.**

**Rationale:** Pattern matching with wildcards/alternation â†' single evaluation (faster than if/elif) â†' clearer visual structure with column alignment.

**Formats:**
- **Compact:** Single actions on same line, align `;;` at consistent column
- **Expanded:** Multi-line logic, `;;` on separate line with blank line after

**Core example:**

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

**Pattern syntax:** Literal `start)` â†' Wildcard `*.txt)` â†' Alternation `-v|--verbose)` â†' Extglob `@(a|b)` (requires `shopt -s extglob`)

**Anti-patterns:**

```bash
# âœ— Missing default case
case "$action" in start) ;; stop) ;; esac  # Silent failure on unknown

# âœ— Use if/elif when testing multiple variables or numeric ranges
if [[ "$a" && "$b" ]]; then ...  # Not: nested case statements
```

**Key rules:** Quote test variable `case "$var"` â†' Don't quote patterns `start)` not `"start")` â†' Always `;;` terminator â†' Use if for complex/multi-var logic.

**Ref:** BCS0502
