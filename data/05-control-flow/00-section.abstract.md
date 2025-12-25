# Control Flow

**Always use `[[ ]]` for test expressions (not `[ ]`), `(())` for arithmetic conditionals, and prefer process substitution `< <(command)` over pipes to while loops (avoids subshell variable persistence issues).**

**Rationale:** `[[ ]]` prevents word splitting/globbing, supports pattern matching (`==`/`!=`), and has cleaner syntax; `(())` enables natural arithmetic; process substitution keeps variables in parent scope.

**Critical arithmetic pattern:** Use `i+=1` or `((i+=1))` never `((i++))` - postfix returns original value, fails with `set -e` when i=0.

**Example:**
```bash
# Conditionals
[[ -f "$file" && -r "$file" ]] && process_file "$file"
(( count > 0 )) && info "Processing $count items"

# Safe loop avoiding subshell
declare -i total=0
while IFS= read -r line; do
  ((total+=1))
done < <(command)
```

**Anti-patterns:**
- `[ "$var" = "value" ]` ’ use `[[ $var == value ]]`
- `command | while read line; do count+=1; done` ’ variables lost (subshell)
- `((i++))` in loops ’ fails when i=0 with `set -e`

**Ref:** BCS0700
