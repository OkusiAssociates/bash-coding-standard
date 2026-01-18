# File Operations

**Safe file handling: explicit paths, proper testing, process substitution.**

## File Tests
Quote variables: `[[ -f "$file" ]]`. Operators: `-e` exists, `-f` file, `-d` dir, `-r` readable, `-w` writable, `-x` executable.

## Safe Wildcards
Always explicit paths → `rm ./*` never `rm *`. Prevents accidental deletion in wrong directory.

## Process Substitution
Avoid subshell variable loss: `while read -r line; do ...; done < <(command)`

## Here Documents
```bash
cat <<'EOF'
Multi-line content (single-quoted EOF = no expansion)
EOF
```

**Anti-patterns:** `rm *` (unsafe) → `rm ./*` | Unquoted `[[ -f $file ]]` → `[[ -f "$file" ]]`

**Ref:** BCS0900
