## Case Statements

**Use `case` for multi-way pattern matching on single value. Compact format for simple actions; expanded for multi-line. Always include `*)` default.**

**Key rules:**
- Case expression unquoted: `case ${1:-} in` (no word splitting occurs)
- Quote test variable with content: `case "$filename" in`
- Unquoted literal patterns: `start)` not `"start")`
- Terminate every branch with `;;`

**When to use:** Single variable â†' multiple patterns, file extensions, arg parsing
**When NOT to use:** Multiple variables, numeric ranges, complex conditions â†' use if/elif

**Compact format** (single actions, aligned `;;`):
```bash
while (($#)); do
  case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -o|--output)  noarg "$@"; shift; OUTPUT="$1" ;;
    -h|--help)    usage; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option: $1" ;;
    *)            FILES+=("$1") ;;
  esac
  shift
done
```

**Pattern syntax:** `*` any chars, `?` single char, `|` alternation, `[a-z]` char class
**Extglob:** `?(pat)` 0-1, `*(pat)` 0+, `+(pat)` 1+, `@(a|b)` exactly one, `!(pat)` negation

**Anti-patterns:**
- `case $var in` â†' unquoted variable with content (quote it)
- Missing `*)` default â†' silent failure on unexpected input
- `[0-9]+)` â†' not regex, use `+([0-9])` with extglob or `[[ =~ ]]` for regex

**Ref:** BCS0502
