# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic; avoid pipes to while loops due to subshell variable loss.**

## Core Rules

- `[[ ]]` over `[ ]` — safer word splitting, supports `&&`/`||`/regex
- `(( ))` for arithmetic conditions — no `$` needed inside
- Process substitution `< <(cmd)` preserves variables vs pipe to while
- Safe increment: `i+=1` or `((++i))` — avoid `((i++))` (fails at 0 with `set -e`)

## Pattern

```bash
while IFS= read -r line; do
    ((count++)) || true  # Safe with set -e
done < <(find . -type f)
[[ -n $line && $line != "#"* ]] && process "$line"
```

## Anti-patterns

- `cmd | while read` → variables lost in subshell
- `((i++))` with `set -e` → exits when i=0

**Ref:** BCS0500
