## shopt

**Recommended settings:**

```bash
# STRONGLY RECOMMENDED - apply to all scripts
shopt -s inherit_errexit  # Makes set -e work in subshells/command substitutions
shopt -s shift_verbose    # Error on shift with no arguments
shopt -s extglob          # Extended glob patterns like !(*.txt)

# CHOOSE ONE:
shopt -s nullglob   # Unmatched globs ’ empty (for loops/arrays)
    # OR
shopt -s failglob   # Unmatched globs ’ error (for strict scripts)

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**Rationale:**

**`inherit_errexit` (CRITICAL)** - Without it, `set -e` does NOT apply inside `$(...)` or `(...)`. Errors in command substitutions will not exit the script:
```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit the script!

# With inherit_errexit
shopt -s inherit_errexit
result=$(false)  # Script exits here as expected
```

**`shift_verbose`** - Without it, `shift` silently fails when no arguments remain. With it, prints error and respects `set -e`.

**`extglob`** - Enables advanced patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`:
```bash
rm !(*.txt)                        # Delete everything EXCEPT .txt files
cp *.@(jpg|png|gif) /dest/         # Multiple extensions
[[ $input == +([0-9]) ]] && ...    # Match one or more digits
```

**`nullglob` vs `failglob`:**

**`nullglob`** (for loops/arrays) - Unmatched glob expands to empty:
```bash
for file in *.txt; do  # If no .txt files, loop body never executes
  echo "$file"
done
files=(*.log)  # If no .log files: files=() (empty array)
```

**`failglob`** (strict scripts) - Unmatched glob causes error:
```bash
cat *.conf  # If no .conf files: error and exits with set -e
```

**Without either (dangerous default):**
```bash
for file in *.txt; do  # If no .txt files, $file = literal "*.txt"
  rm "$file"           # Tries to delete file named "*.txt"!
done
```

**`globstar` (OPTIONAL)** - Enables `**` for recursive matching (can be slow):
```bash
for script in **/*.sh; do  # Recursively find all .sh files
  shellcheck "$script"
done
```

**Typical configuration:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**When NOT to use:**
- Interactive scripts (need lenient behavior)
- Legacy compatibility (older bash versions)
- Performance-critical loops (`globstar` slow on large trees)
