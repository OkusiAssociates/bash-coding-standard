### Arrays

**Always quote array expansions `"${array[@]}"` to preserve element boundaries and prevent word splitting.**

#### Why Arrays
- Element boundaries preserved regardless of content (spaces, globs)
- Safe command construction with arbitrary arguments

#### Core Patterns

```bash
declare -a paths=()              # Empty indexed array
declare -A config=()             # Associative (Bash 4.0+)
paths+=("$file")                 # Append element
for p in "${paths[@]}"; do       # Iterate (MUST quote)
readarray -t lines < <(cmd)      # From command output
"${cmd[@]}"                      # Execute safely
```

#### Quick Reference
| `${#arr[@]}` | Length | `${arr[-1]}` | Last element |
|--------------|--------|--------------|--------------|
| `"${arr[@]}"` | All (separate) | `${arr[@]:1:3}` | Slice |

#### Anti-Patterns
- `${files[@]}` â†' `"${files[@]}"` (unquoted breaks on spaces)
- `array=($string)` â†' `readarray -t array <<< "$string"` (word splitting)
- `for x in "${arr[*]}"` â†' `"${arr[@]}"` (single vs separate words)

**Ref:** BCS0207
