## Variable Scoping

Declare function-specific variables as `local` to prevent namespace pollution and side effects.

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
}
```

**Rationale:** Without `local`, function variables: overwrite globals with same name, persist after return, break recursive calls.

**Anti-patterns:**
```bash
# ✗ Wrong - no local declaration
process_file() {
  file=$1  # Overwrites any global $file variable!
}

# ✓ Correct - local declaration
process_file() {
  local -- file=$1  # Scoped to this function only
}
```

**Recursive function gotcha:**
```bash
# ✗ Wrong - global resets on each recursive call
count_files() {
  total=0
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
