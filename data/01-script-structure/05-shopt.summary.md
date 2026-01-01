## shopt

**Recommended settings:**

```bash
shopt -s inherit_errexit  # Critical: makes set -e work in subshells
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE:
shopt -s nullglob   # For arrays/loops: unmatched globs â†' empty
shopt -s failglob   # For strict scripts: unmatched globs â†' error

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**Rationale:**

**`inherit_errexit` (CRITICAL):** Without it, `set -e` does NOT apply inside command substitutions:
```bash
set -e  # Without inherit_errexit
result=$(false)  # This does NOT exit the script!
echo "Still running"  # This executes

# With inherit_errexit
shopt -s inherit_errexit
result=$(false)  # Script exits here as expected
```

**`shift_verbose`:** Prints error when shift fails instead of silent continue:
```bash
shopt -s shift_verbose
shift  # If no arguments: "bash: shift: shift count must be <= $#"
```

**`extglob`:** Enables `?(pat)`, `*(pat)`, `+(pat)`, `@(pat)`, `!(pat)`:
```bash
shopt -s extglob
rm !(*.txt)                          # Delete everything EXCEPT .txt
cp *.@(jpg|png|gif) /destination/    # Multiple extensions
[[ $input == +([0-9]) ]] && echo 'Number'
```

**`nullglob` vs `failglob`:**

`nullglob` - unmatched glob expands to empty (for loops/arrays):
```bash
shopt -s nullglob
for file in *.txt; do  # No .txt files â†' loop never executes
  echo "$file"
done
files=(*.log)  # No .log files â†' files=() (empty array)
```

`failglob` - unmatched glob causes error (strict scripts):
```bash
shopt -s failglob
cat *.conf  # No .conf files: "bash: no match: *.conf" (exits with set -e)
```

**Anti-pattern - default behavior without nullglob/failglob:**
```bash
# âœ— Dangerous default behavior
for file in *.txt; do  # No .txt files â†' $file = literal "*.txt"
  rm "$file"  # Tries to delete file named "*.txt"!
done
```

**`globstar`:** Enables `**` for recursive matching:
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

**When NOT to use:**
- Interactive scripts (may want lenient behavior)
- Legacy compatibility (older bash versions)
- Performance-critical loops (`globstar` slow on large trees)
