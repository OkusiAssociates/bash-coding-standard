### Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Rationale
- Element boundaries preserved regardless of content (spaces, globs)
- Safe command construction with arbitrary arguments

#### Declaration & Usage
```bash
declare -a files=()              # Empty indexed array
declare -A config=()             # Associative (Bash 4.0+)
files+=("$1")                    # Append element
for f in "${files[@]}"; do       # Iterate (quoted!)
  process "$f"
done
readarray -t lines < <(cmd)      # From command output
```

#### Key Operations
| Op | Syntax |
|----|--------|
| Length | `${#arr[@]}` |
| Last | `${arr[-1]}` |
| Slice | `${arr[@]:1:3}` |

#### Anti-Patterns
- `rm ${files[@]}` â†' `rm "${files[@]}"` (quote expansion)
- `arr=($string)` â†' `readarray -t arr <<< "$string"` (no word-split)
- `for x in "${arr[*]}"` â†' `"${arr[@]}"` (use @ not *)

**Ref:** BCS0207
