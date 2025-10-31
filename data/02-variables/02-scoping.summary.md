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

**Rationale:** Without `local`, function variables become global, overwriting same-named globals, persisting after return, and breaking recursive calls.

**Anti-patterns:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file="$1"  # Overwrites any global $file variable!
  # ...
}

# ✓ Correct - local declaration
process_file() {
  local -- file="$1"  # Scoped to this function only
  # ...
}

# ✗ Wrong - recursive function breaks without local
count_files() {
  total=0  # Global! Each recursive call resets it
  for file in "$1"/*; do
    ((total++))
  done
  echo "$total"
}

# ✓ Correct - local scope for recursion
count_files() {
  local -i total=0  # Each invocation gets its own total
  for file in "$1"/*; do
    ((total++))
  done
  echo "$total"
}
```
