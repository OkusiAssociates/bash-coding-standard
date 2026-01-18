### Arrays

**Always quote array expansions `"${array[@]}"` to preserve element boundaries and prevent word splitting.**

#### Core Operations

| Operation | Syntax |
|-----------|--------|
| Declare | `declare -a arr=()` |
| Append | `arr+=("value")` |
| Length | `${#arr[@]}` |
| All | `"${arr[@]}"` |
| Slice | `"${arr[@]:2:3}"` |
| Assoc | `declare -A map=()` |

#### Rationale

- Element boundaries preserved regardless of spaces/special chars
- `"${array[@]}"` prevents glob expansion and word splitting
- Safe command construction with arbitrary arguments

#### Example

```bash
declare -a cmd=(app --config "$cfg")
((verbose)) && cmd+=(--verbose) ||:
"${cmd[@]}"  # Execute safely

readarray -t lines < <(grep pat file)
for line in "${lines[@]}"; do process "$line"; done
```

#### Anti-Patterns

- `${arr[@]}` → `"${arr[@]}"` (unquoted breaks on spaces)
- `arr=($str)` → `readarray -t arr <<< "$str"` (word splitting)
- `"${arr[*]}"` in loops → `"${arr[@]}"` (single word vs multiple)

**Ref:** BCS0207
