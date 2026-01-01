## Input Sanitization

**Always validate and sanitize user input before processing.**

**Rationale:** Prevents injection attacks, directory traversal (`../../../etc/passwd`), and type mismatches. Defense in depth—never trust user input.

**Core Pattern—Filename Validation:**

```bash
sanitize_filename() {
  local -- name=$1
  [[ -n "$name" ]] || die 22 'Filename cannot be empty'
  name="${name//\.\./}"; name="${name//\//}"  # Strip traversal
  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid: ${name@Q}"
  echo "$name"
}
```

**Injection Prevention:**

```bash
# Option injection - always use -- separator
rm -- "$user_file"    # ✓ Safe
rm "$user_file"       # ✗ Dangerous if file="-rf /"

# Command injection - whitelist, never eval
case "$cmd" in start|stop) systemctl "$cmd" app ;; esac  # ✓
eval "$user_cmd"      # ✗ NEVER with user input
```

**Validation Types:** Integer (`^-?[0-9]+$`), path (realpath + directory check), email (`^[a-zA-Z0-9._%+-]+@...`), whitelist (array membership).

**Anti-Patterns:**

- `rm -rf "$user_dir"` without validation �' validate_path first
- Blacklist approach (`!= *rm*`) �' whitelist regex instead
- Trusting "looks safe" input �' always validate type/format/range/length

**Security Principles:** Whitelist over blacklist; validate early; fail securely; use `--` separator; avoid `eval`; principle of least privilege.

**Ref:** BCS1005
