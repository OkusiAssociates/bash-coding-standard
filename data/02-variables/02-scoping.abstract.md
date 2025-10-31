## Variable Scoping

**Always declare function-specific variables as `local` to prevent namespace pollution.**

```bash
# Global variables - declare at top
declare -i VERBOSE=1 PROMPT=1

# Function variables - always use local
main() {
  local -a add_specs=()      # Local array
  local -i max_depth=3       # Local integer
  local -- path dir          # Local strings
  dir=$(dirname -- "$name")
}
```

**Rationale:** Without `local`, variables become global and: (1) overwrite globals with same name, (2) persist after return causing unexpected behavior, (3) break recursive functions.

**Anti-patterns:**
- `file="$1"` ’ Overwrites global `$file` | Use: `local -- file="$1"`
- `total=0` in recursive function ’ Each call resets it | Use: `local -i total=0`

**Ref:** BCS0202
