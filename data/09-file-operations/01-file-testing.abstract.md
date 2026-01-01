## Safe File Testing

**Always quote variables and use `[[ ]]` for all file tests.**

**Key operators:** `-f` (file), `-d` (dir), `-r` (readable), `-w` (writable), `-x` (executable), `-s` (non-empty), `-e` (exists), `-L` (symlink), `-nt`/`-ot` (newer/older than), `-ef` (same inode).

**Core pattern:**
```bash
[[ -f "$file" && -r "$file" ]] || die 3 "Cannot read ${file@Q}"
[[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ "$src" -nt "$dst" ]] && cp "$src" "$dst"
```

**Rationale:** Quoting prevents word splitting/glob expansion; `[[ ]]` safer than `[ ]`; test-before-use prevents runtime errors.

**Anti-patterns:**
- `[[ -f $file ]]` â†' `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` â†' `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` without test â†' validate first with `|| die`

**Ref:** BCS0901
