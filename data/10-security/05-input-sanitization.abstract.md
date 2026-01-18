## Input Sanitization

**Validate and sanitize all user input to prevent injection attacks and directory traversal.**

**Rationale:** Prevent injection/traversal attacks; fail early on invalid input; whitelist > blacklist.

**Core Pattern:**
```bash
sanitize_filename() {
  local -- name=$1
  [[ -n "$name" ]] || die 22 'Empty filename'
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}

validate_path() {
  local -- real_path
  real_path=$(realpath -e -- "$1") || die 22 "Invalid path"
  [[ "$real_path" == "$2"* ]] || die 5 "Path outside allowed dir"
  echo "$real_path"
}
```

**Critical Rules:**
- Use `--` separator → prevents option injection (`rm -- "$file"`)
- Whitelist validation → `[[ "$x" =~ ^[a-zA-Z0-9]+$ ]]`
- Never `eval` user input
- Validate type/format/range/length before use

**Anti-patterns:**
```bash
# ✗ Direct use without validation
rm -rf "$user_dir"        # user_dir="/" = disaster

# ✗ Blacklist (bypassable)
[[ "$input" != *'rm'* ]]  # Use whitelist instead

# ✓ Validate then use
user_dir=$(validate_path "$user_dir" "/safe/base")
rm -rf -- "$user_dir"
```

**Ref:** BCS1005
