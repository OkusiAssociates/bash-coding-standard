## shopt

**Recommended settings:**

```bash
# RECOMMENDED - apply to all scripts
shopt -s inherit_errexit  # Critical: makes set -e work in subshells
shopt -s shift_verbose    # Catches shift errors when no arguments remain
shopt -s extglob          # Enables extended glob patterns like !(*.txt)

# CHOOSE ONE based on use case:
shopt -s nullglob   # For arrays/loops: unmatched globs → empty
shopt -s failglob   # For strict scripts: unmatched globs → error

# OPTIONAL:
shopt -s globstar   # Enable ** for recursive matching (slow on deep trees)
```

**`inherit_errexit` (CRITICAL):** Without it, `set -e` does NOT apply inside `$(...)` or `(...)`:
```bash
set -e  # Without inherit_errexit
result=$(false)  # Does NOT exit!
echo "Still running"  # Executes

shopt -s inherit_errexit
result=$(false)  # Script exits as expected
```

**`shift_verbose`:** Prints error when shift fails with no arguments: `"bash: shift: shift count must be <= $#"`

**`extglob`:** Enables `?(pat)`, `*(pat)`, `+(pat)`, `@(pat)`, `!(pat)`:
```bash
shopt -s extglob
rm !(*.txt)                        # Delete everything EXCEPT .txt
cp *.@(jpg|png|gif) /destination/  # Multiple extensions
[[ $input == +([0-9]) ]]           # Match digits
```

**`nullglob` vs `failglob`:**

| Setting | Behavior | Best for |
|---------|----------|----------|
| `nullglob` | Unmatched glob → empty | Loops/arrays |
| `failglob` | Unmatched glob → error | Strict scripts |

```bash
# nullglob: empty array if no matches
files=(*.log)  # files=() if no .log files

# failglob: error if no matches
cat *.conf  # Exits with set -e if no .conf files
```

**Without either (dangerous default):**
```bash
# ✗ If no .txt files, $file = literal "*.txt"
for file in *.txt; do
  rm "$file"  # Tries to delete file named "*.txt"!
done
```

**`globstar`:** Enables `**` for recursive matching (can be slow):
```bash
shopt -s globstar
for script in **/*.sh; do shellcheck "$script"; done
```

**Typical configuration:**
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

**When NOT to use:** Interactive scripts (lenient behavior), legacy bash compatibility, performance-critical loops with globstar.
