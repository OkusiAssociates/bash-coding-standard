## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests to prevent word splitting and glob expansion.**

**Rationale:** Unquoted variables break with spaces/special chars; `[[ ]]` more robust than `[ ]`; testing before use prevents runtime errors; failing fast with informative messages aids debugging.

**Core operators:**
- `-f` regular file, `-d` directory, `-e` any type, `-L` symlink
- `-r` readable, `-w` writable, `-x` executable, `-s` not empty
- `-nt` newer than, `-ot` older than, `-ef` same file

**Example:**
```bash
# Validate and source config
[[ -f "$config" ]] || die 3 "Config not found: $config"
[[ -r "$config" ]] || die 5 "Cannot read: $config"
source "$config"

# Update if source newer
[[ "$source" -nt "$dest" ]] && cp "$source" "$dest"

# Validate executable
validate_executable() {
  [[ -f "$1" ]] || die 2 "Not found: $1"
  [[ -x "$1" ]] || die 126 "Not executable: $1"
}
```

**Anti-patterns:**
- `[[ -f $file ]]` ’ `[[ -f "$file" ]]` (always quote)
- `[ -f "$file" ]` ’ `[[ -f "$file" ]]` (use `[[ ]]`)
- `source "$config"` ’ validate first with `-f` and `-r`

**Ref:** BCS1101
