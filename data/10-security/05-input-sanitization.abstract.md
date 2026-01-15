## Input Sanitization

**Validate/sanitize all user input to prevent injection and traversal attacks.**

### Rationale
- Prevents command injection, directory traversal (`../../../etc/passwd`)
- Enforces expected data types; rejects invalid input early

### Core Patterns

**Filename sanitization:**
```bash
sanitize_filename() {
  local -- name=$1
  name="${name//\.\./}"; name="${name//\//}"
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}
```

**Path containment:** Use `realpath -e` â†' verify path starts with allowed dir.

**Numeric:** `[[ "$input" =~ ^[0-9]+$ ]]` â†' reject leading zeros for integers.

**Whitelist choices:** Loop array, match exact â†' `die` if no match.

### Critical Rules
- **Always use `--`** separator: `rm -- "$file"` prevents option injection
- **Never use `eval`** with user input
- **Whitelist > blacklist**: Define allowed chars, not forbidden ones

### Anti-patterns
```bash
# âœ— Trusting input
rm -rf "$user_dir"  # user_dir="/" = disaster

# âœ“ Validate first
validate_path "$user_dir" "/safe/base"; rm -rf -- "$user_dir"
```

**Ref:** BCS1005
