## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests:**

```bash
[[ -f "$file" ]] && source "$file"
[[ -d "$path" ]] || die 1 "Not a directory ${path@Q}"
[[ -r "$file" ]] || warn "Cannot read ${file@Q}"
[[ -x "$script" ]] || die 1 "Not executable ${script@Q}"

# Multiple conditions
if [[ -f "$config" && -r "$config" ]]; then
  source "$config"
else
  die 3 "Config file not found or not readable ${config@Q}"
fi

# File timestamps
[[ "$source" -nt "$destination" ]] && cp "$source" "$destination"
```

**File test operators:**

| Operator | True If | Operator | True If |
|----------|---------|----------|---------|
| `-e file` | Exists (any type) | `-r file` | Readable |
| `-f file` | Regular file | `-w file` | Writable |
| `-d dir` | Directory | `-x file` | Executable |
| `-L link` | Symbolic link | `-s file` | Non-empty (size > 0) |
| `-p pipe` | Named pipe | `-O file` | You own it |
| `-S sock` | Socket | `-G file` | Group matches yours |
| `-b/-c` | Block/char device | `-N file` | Modified since last read |
| `-u/-g/-k` | SUID/SGID/sticky | | |

**Comparison:** `-nt` (newer), `-ot` (older), `-ef` (same inode)

**Rationale:**
- Quote `"$file"` to prevent word splitting/glob expansion
- `[[ ]]` more robust than `[ ]`
- Test before use, fail fast with `|| die`
- Include filename in error messages

**Common patterns:**

```bash
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found ${file@Q}"
  [[ -r "$file" ]] || die 5 "Cannot read file ${file@Q}"
}

ensure_writable_dir() {
  local dir=$1
  [[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create directory ${dir@Q}"
  [[ -w "$dir" ]] || die 5 "Directory not writable ${dir@Q}"
}

is_executable_script() {
  local file=$1
  [[ -f "$file" && -x "$file" && -s "$file" ]]
}
```

**Anti-patterns:**

```bash
# ✗ Wrong - unquoted variable (breaks with spaces/special chars)
[[ -f $file ]]
# ✓ Correct
[[ -f "$file" ]]

# ✗ Wrong - old [ ] syntax
if [ -f "$file" ]; then
# ✓ Correct
if [[ -f "$file" ]]; then

# ✗ Wrong - not checking before use
source "$config"
# ✓ Correct - validate first
[[ -f "$config" ]] || die 3 "Config not found ${config@Q}"
source "$config"

# ✗ Wrong - mkdir failure not caught
[[ -d "$dir" ]] || mkdir "$dir"
# ✓ Correct
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: ${dir@Q}"
```
