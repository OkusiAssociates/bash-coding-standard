# Control Flow

**Use `[[ ]]` for tests, `(( ))` for arithmetic; avoid pipes to while loops.**

## Core Rules

- `[[ ]]` over `[ ]` â€” safer word splitting, supports `&&`/`||`/regex
- `(( ))` for arithmetic conditionals â€” cleaner than `[[ $x -gt 5 ]]`
- Process substitution `< <(cmd)` over pipes â€” avoids subshell variable loss

## Safe Arithmetic

```bash
i+=1              # Safe increment (string append works for integers)
((i++)) || true   # Guard: ((i++)) fails with set -e when i=0
```

`((i+=1))` â†' fails when result is 0; `((i++))` â†' returns original value (fails at i=0)

## Anti-Patterns

- `cmd | while read` â†' variables lost in subshell; use `while read < <(cmd)`
- `[ $var = "x" ]` â†' word splitting/glob issues; use `[[ $var == "x" ]]`

**Ref:** BCS0500
