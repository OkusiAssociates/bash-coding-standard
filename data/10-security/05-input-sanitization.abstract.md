## Input Sanitization

**Always validate user input to prevent injection attacks and directory traversal.**

**Rationale:** Never trust user input—validate type, format, range before processing.

**Patterns:**

```bash
# Filename validation
sanitize_filename() {
  [[ -n "$1" ]] || die 22 'Empty'
  local n="${1//\.\./}"; n="${n//\//}"
  [[ "$n" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Unsafe: $n"
}

# Integer range
validate_port() {
  [[ "$1" =~ ^[0-9]+$ ]] || die 22 "Invalid: $1"
  ((1 <= $1 && $1 <= 65535)) || die 22 "Range: $1"
}

# Path containment
validate_path() {
  local p=$(realpath -e -- "$1") || die 22 "Invalid: $1"
  [[ "$p" == "$2"* ]] || die 5 "Outside: $p"
}

# Whitelist
validate_choice() {
  local in="$1"; shift
  for c in "$@"; do [[ "$in" == "$c" ]] && return 0; done
  die 22 "Invalid: $in"
}
```

**Injection prevention:**

```bash
# ✗ Command injection
eval "$user_cmd"          # NEVER!
cat "$file"               # file="; rm -rf /"

# ✓ Safe
case "$cmd" in start|stop) systemctl "$cmd" app ;; esac
cat -- "$file"            # Use -- separator

# ✗ Option injection  
rm "$file"                # file="--delete-all"
# ✓ Safe
rm -- "$file"
ls ./"$file"
```

**Anti-pattern:**

```bash
# ✗ Blacklist (incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid'
# ✓ Whitelist
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die 1 'Invalid'
```

**Ref:** BCS1205
