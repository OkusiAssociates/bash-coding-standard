### Arrays

**Always quote array expansions `"${array[@]}"` to preserve elements and prevent word splitting.**

#### Declaration & Operations

```bash
declare -a files=()              # Indexed array
declare -A config=()             # Associative (Bash 4.0+)
files+=("$path")                 # Append element
count=${#files[@]}               # Length
first=${files[0]}                # Access (0-indexed)
```

#### Safe Iteration

```bash
for f in "${files[@]}"; do process "$f"; done
```

#### Safe Population

```bash
readarray -t lines < <(command)  # From command
IFS=',' read -ra fields <<< "$csv"  # Split string
```

#### Command Construction

```bash
local -a cmd=(app '--config' "$cfg")
((verbose)) && cmd+=('--verbose') ||:
"${cmd[@]}"                      # Execute safely
```

#### Critical Anti-Patterns

`rm ${files[@]}` â†' `rm "${files[@]}"` (unquoted breaks on spaces)

`array=($string)` â†' `readarray -t array <<< "$string"` (word splitting unsafe)

`for x in "${arr[*]}"` â†' `for x in "${arr[@]}"` (single word vs separate)

| Op | Syntax |
|----|--------|
| All | `"${arr[@]}"` |
| Length | `${#arr[@]}` |
| Slice | `"${arr[@]:1:3}"` |
| Indices | `"${!arr[@]}"` |

**Ref:** BCS0207
