## shopt

**Recommended settings:**

```bash
shopt -s inherit_errexit  # Critical: makes set -e work in subshells
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE based on use case:
shopt -s nullglob   # For arrays/loops: unmatched globs â†' empty (no error)
shopt -s failglob   # For strict scripts: unmatched globs â†' error

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

### Rationale

**`inherit_errexit` (CRITICAL):** Without it, `set -e` does NOT apply inside command substitutions or subshells. Errors in `$(...)` and `(...)` won't propagate.

```bash
set -e  # Without inherit_errexit
result=$(false)  # This does NOT exit the script!
echo "Still running"  # This executes

# With inherit_errexit
shopt -s inherit_errexit
result=$(false)  # Script exits here as expected
```

**`shift_verbose`:** Without it, `shift` silently fails when no arguments remain.

```bash
shopt -s shift_verbose
shift  # If no arguments: "bash: shift: shift count must be <= $#"
```

**`extglob`:** Enables advanced patterns: `?(pattern)`, `*(pattern)`, `+(pattern)`, `@(pattern)`, `!(pattern)`

```bash
shopt -s extglob
rm !(*.txt)                       # Delete everything EXCEPT .txt files
cp *.@(jpg|png|gif) /destination/ # Match multiple extensions
[[ $input == +([0-9]) ]] && echo 'Number'
```

**`nullglob` vs `failglob`:**

`nullglob` - Best for loops/arrays where empty result is valid:
```bash
shopt -s nullglob
for file in *.txt; do  # If no .txt files, loop body never executes
  echo "$file"
done
files=(*.log)  # If no .log files: files=() (empty array)
```

`failglob` - Best for strict scripts where unmatched glob is an error:
```bash
shopt -s failglob
cat *.conf  # If no .conf files: "bash: no match: *.conf" (exits with set -e)
```

### Anti-Pattern: Default Bash Behavior

```bash
# âœ— Dangerous default behavior
for file in *.txt; do  # If no .txt files, $file = literal string "*.txt"
  rm "$file"  # Tries to delete file named "*.txt"!
done
```

**`globstar` (OPTIONAL):** Enables `**` for recursive matching. Warning: slow on deep trees.

```bash
shopt -s globstar
for script in **/*.sh; do
  shellcheck "$script"
done
```

**Typical configuration:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

### Edge Cases

- **Interactive scripts**: May want more lenient behavior
- **Legacy compatibility**: Older bash versions may not support all options
- **Performance-critical**: `globstar` can be slow on large directory trees
