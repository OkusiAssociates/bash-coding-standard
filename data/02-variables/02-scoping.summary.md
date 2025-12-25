## Variable Scoping

Always declare function-specific variables as `local` to prevent namespace pollution and unexpected side effects.

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path              # Local string
  local -- dir
  dir=$(dirname -- "$name")
  # ...
}
```

**Rationale:**
- Without `local`, variables become global and can overwrite same-named globals
- Variables persist after function returns, causing unexpected behavior
- Recursive function calls interfere with each other

**Anti-pattern:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file="$1"  # Overwrites any global $file variable!
}

# ✓ Correct - local declaration
process_file() {
  local -- file="$1"  # Scoped to this function only
}
```

**Edge case - recursive functions:**
```bash
# ✗ Wrong - global breaks recursion
count_files() {
  total=0  # Each recursive call resets it
  for file in "$1"/*; do total+=1; done
  echo "$total"
}

# ✓ Correct - each invocation gets its own total
count_files() {
  local -i total=0
  for file in "$1"/*; do total+=1; done
  echo "$total"
}
```
