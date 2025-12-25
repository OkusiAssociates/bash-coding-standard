### Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Declaration & Usage
```bash
declare -a paths=()                    # Empty indexed array
declare -A config=()                   # Associative (Bash 4.0+)
paths+=("$file")                       # Append element
count=${#paths[@]}                     # Length
first=${paths[0]}  last=${paths[-1]}   # Access ([-1] Bash 4.3+)
```

#### Iteration & Reading
```bash
for path in "${paths[@]}"; do process "$path"; done
readarray -t lines < <(grep pattern file)
IFS=',' read -ra fields <<< "$csv"
```

#### Safe Command Construction
```bash
local -a cmd=('app' '--config' "$cfg")
((verbose)) && cmd+=('--verbose')
"${cmd[@]}"
```

#### Anti-Patterns
- `${arr[@]}` â†' `"${arr[@]}"` (unquoted breaks on spaces)
- `array=($string)` â†' `readarray -t array <<< "$string"` (word splitting)
- `for x in "${arr[*]}"` â†' `"${arr[@]}"` (`[*]` joins into single word)

#### Quick Reference
| `declare -a arr=()` | Create | `"${arr[@]}"` | All elements |
| `arr+=("val")` | Append | `${#arr[@]}` | Length |
| `"${arr[i]}"` | Index i | `"${arr[@]:1:3}"` | Slice |

**Ref:** BCS0207
