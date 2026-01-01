## Case Statements

**Use `case` for multi-way pattern matching on single variable; use compact format for simple actions, expanded for multi-line logic; always include `*)` default case.**

**Rationale:** Faster than if/elif chains (single evaluation), native pattern/wildcard support, visually organized with column alignment.

**Case vs if/elif:** Case for single-variable pattern matching; if/elif for multiple variables, numeric ranges, or complex boolean logic.

**Core patterns:**
```bash
# Compact (single actions, align ;;)
case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -o|--output)  shift; OUTPUT=$1 ;;
  -*)           die 22 "Invalid: ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac

# Pattern matching
case "$file" in
  *.txt|*.md) process_text ;;
  *.jpg|*.png) process_image ;;
  *)          die 1 'Unknown type' ;;
esac
```

**Expression quoting:** Don't quote case expression (`case $1 in` not `case "$1" in`)â€”word splitting doesn't apply there.

**Pattern syntax:** Literals (`start`), wildcards (`*.txt`, `?`), alternation (`a|b|c`), extglob (`@(x|y)`, `!(*.tmp)`), character classes (`[0-9]`).

**Anti-patterns:**
- `case "${1:-}" in` â†' `case ${1:-} in` (unnecessary quotes)
- Missing `*)` default â†' silent failures on unexpected input
- Mixing compact/expanded formats inconsistently
- `[0-9]+` in case â†' not regex; use `+([0-9])` with extglob
- Nested case for multiple variables â†' use if/elif instead

**Ref:** BCS0502
