## shopt

**Apply these `shopt` settings immediately after `set -euo pipefail` in every script.**

**Critical settings:**
```bash
shopt -s inherit_errexit  # Makes set -e work in $(...) and (...)
shopt -s shift_verbose    # Errors when shift has no args
shopt -s extglob          # Enables !(pattern), +(pattern), *(pattern)
```

**Choose one glob behavior:**
```bash
shopt -s nullglob   # Unmatched globs ’ empty (safe for loops/arrays)
# OR
shopt -s failglob   # Unmatched globs ’ error (strict mode)
```

**Optional:**
```bash
shopt -s globstar   # Enables ** recursive matching (slow on deep trees)
```

**Rationale:**
- `inherit_errexit`: Without this, `result=$(false)` does NOT exit script despite `set -e` ’ errors in command substitutions silently ignored
- `shift_verbose`: Prevents silent failures when `shift` called with no args
- `extglob`: Enables `rm !(*.txt)`, `[[ $x == +([0-9]) ]]`, `*.@(jpg|png)`
- `nullglob`: `for f in *.txt` ’ loop skips if no matches (default behavior: `f="*.txt"` literal string causes bugs)
- `failglob`: Strict alternative where unmatched glob exits script

**Anti-patterns:**
- Omitting `inherit_errexit` ’ `set -e` ineffective in subshells
- No glob option ’ `for f in *.txt` executes with literal `"*.txt"` when no matches

**Ref:** BCS0105
