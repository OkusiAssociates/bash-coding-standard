## Safe File Testing

**Always quote variables and use `[[ ]]` for file tests:**

```bash
# Basic file testing
[[ -f "$file" ]] && source "$file"
[[ -d "$path" ]] || die 1 "Not a directory: $path"
[[ -r "$file" ]] || warn "Cannot read: $file"
[[ -x "$script" ]] || die 1 "Not executable: $script"

# Check multiple conditions
if [[ -f "$config" && -r "$config" ]]; then
  source "$config"
else
  die 3 "Config file not found or not readable: $config"
fi

# Check file emptiness
[[ -s "$logfile" ]] || warn 'Log file is empty'

# Compare file timestamps
if [[ "$source" -nt "$destination" ]]; then
  cp "$source" "$destination"
  info "Updated $destination"
fi
```

**File test operators:**

| Operator | Returns True If |
|----------|----------------|
| `-e file` | File exists (any type) |
| `-f file` | Regular file exists |
| `-d dir` | Directory exists |
| `-L link` | Symbolic link exists |
| `-p pipe` | Named pipe (FIFO) exists |
| `-S sock` | Socket exists |
| `-b file` | Block device exists |
| `-c file` | Character device exists |
| `-r file` | File is readable |
| `-w file` | File is writable |
| `-x file` | File is executable |
| `-s file` | File is not empty (size > 0) |
| `-u file` | File has SUID bit set |
| `-g file` | File has SGID bit set |
| `-k file` | File has sticky bit set |
| `-O file` | You own the file |
| `-G file` | File's group matches yours |
| `-N file` | File modified since last read |
| `f1 -nt f2` | f1 is newer than f2 (modification time) |
| `f1 -ot f2` | f1 is older than f2 |
| `f1 -ef f2` | f1 and f2 have same device/inode (same file) |

**Rationale:**

- Always quote `"$file"` to prevent word splitting and glob expansion
- `[[ ]]` more robust than `[ ]` or `test` command
- Test before use to prevent errors from missing/unreadable files
- Use `|| die` to fail fast when prerequisites not met
- Include filename in error messages for debugging

**Common patterns:**

```bash
# Validate required file exists and is readable
validate_file() {
  local file=$1
  [[ -f "$file" ]] || die 2 "File not found: $file"
  [[ -r "$file" ]] || die 5 "Cannot read file: $file"
}

# Check if directory is writable
ensure_writable_dir() {
  local dir=$1
  [[ -d "$dir" ]] || mkdir -p "$dir" || die 1 "Cannot create directory: $dir"
  [[ -w "$dir" ]] || die 5 "Directory not writable: $dir"
}

# Only process if file was modified
process_if_modified() {
  local source=$1
  local marker=$2

  if [[ ! -f "$marker" ]] || [[ "$source" -nt "$marker" ]]; then
    process_file "$source"
    touch "$marker"
  else
    info "File $source not modified, skipping"
  fi
}

# Check if file is executable script
is_executable_script() {
  local file=$1
  [[ -f "$file" && -x "$file" && -s "$file" ]]
}

# Safe file sourcing
safe_source() {
  local file=$1
  if [[ -f "$file" ]]; then
    if [[ -r "$file" ]]; then
      source "$file"
    else
      warn "Cannot read file: $file"
      return 1
    fi
  else
    debug "File not found: $file (optional)"
    return 0
  fi
}
```

**Anti-patterns to avoid:**

```bash
#  Wrong - unquoted variable
[[ -f $file ]]  # Breaks with spaces or special chars

#  Correct - always quote
[[ -f "$file" ]]

#  Wrong - using old [ ] syntax
if [ -f "$file" ]; then
  cat "$file"
fi

#  Correct - use [[ ]]
if [[ -f "$file" ]]; then
  cat "$file"
fi

#  Wrong - not checking before use
source "$config"  # Error if file doesn't exist

#  Correct - validate first
[[ -f "$config" ]] || die 3 "Config not found: $config"
[[ -r "$config" ]] || die 5 "Cannot read config: $config"
source "$config"

#  Wrong - silent failure
[[ -d "$dir" ]] || mkdir "$dir"  # mkdir failure not caught

#  Correct - check result
[[ -d "$dir" ]] || mkdir "$dir" || die 1 "Cannot create directory: $dir"
```

**Combining file tests:**

```bash
# Multiple conditions with AND
if [[ -f "$file" && -r "$file" && -s "$file" ]]; then
  info "Processing non-empty readable file: $file"
  process_file "$file"
fi

# Multiple conditions with OR
if [[ -f "$config1" ]]; then
  config_file=$config1
elif [[ -f "$config2" ]]; then
  config_file=$config2
else
  die 3 'No configuration file found'
fi

# Complex validation
validate_executable() {
  local script=$1

  [[ -e "$script" ]] || die 2 "File does not exist: $script"
  [[ -f "$script" ]] || die 22 "Not a regular file: $script"
  [[ -x "$script" ]] || die 126 "Not executable: $script"
  [[ -s "$script" ]] || die 22 "File is empty: $script"
}
```
