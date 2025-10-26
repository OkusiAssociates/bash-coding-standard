## Array Declaration and Usage

**Always declare arrays explicitly with `declare -a` (or `local -a` in functions) for clarity and type safety.**

**Rationale:** Signals array type to readers, prevents scalar assignment, enables scope control with `local -a`.

**Core patterns:**
```bash
declare -a files=()              # Empty array
files+=("$item")                 # Append element
readarray -t lines < <(command)  # Read output (use -t, process subst)

# Iteration - always quote "${array[@]}"
for item in "${array[@]}"; do
  process "$item"
done

${#array[@]}                     # Length
```

**Anti-patterns:**
- `${array[@]}` ’ unquoted breaks with spaces
- `for x in "$array"` ’ only first element
- `array=($string)` ’ dangerous word splitting/glob expansion
- `"${array[*]}"` ’ all elements as one string

**Ref:** BCS0501
