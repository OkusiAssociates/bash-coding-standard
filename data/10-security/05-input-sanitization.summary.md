## Input Sanitization

**Always validate and sanitize user input to prevent security issues.**

**Rationale:**
- Prevent injection attacks (malicious code in input)
- Prevent directory traversal (`../../../etc/passwd`)
- Validate data types match expected format
- Fail early - reject invalid input before processing
- Defense in depth - never trust user input

**1. Filename validation:**

```bash
sanitize_filename() {
  local -- name=$1

  [[ -n "$name" ]] || die 22 'Filename cannot be empty'

  name="${name//\.\./}"  # Remove all ..
  name="${name//\//}"    # Remove all /

  [[ "$name" =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename ${name@Q}: contains unsafe characters"
  [[ "$name" =~ ^\\. ]] && die 22 "Filename cannot start with dot ${name@Q}"
  ((${#name} > 255)) && die 22 "Filename too long (max 255 chars) ${name@Q}"

  echo "$name"
}

user_filename=$(sanitize_filename "$user_input")
safe_path="$SAFE_DIR/$user_filename"
```

**2. Numeric input validation:**

```bash
validate_integer() {
  local -- input=$1
  [[ -n "$input" ]] || die 22 'Number cannot be empty'
  [[ "$input" =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: '$input'"
  echo "$input"
}

validate_positive_integer() {
  local -- input=$1
  [[ -n "$input" ]] || die 22 'Number cannot be empty'
  [[ "$input" =~ ^[0-9]+$ ]] || die 22 "Invalid positive integer: '$input'"
  [[ "$input" =~ ^0[0-9] ]] && die 22 "Number cannot have leading zeros: $input"
  echo "$input"
}

validate_port() {
  local -- port="$1"
  port=$(validate_positive_integer "$port")
  ((port >= 1 && port <= 65535)) || die 22 "Port must be 1-65535: $port"
  echo "$port"
}
```

**3. Path validation:**

```bash
validate_path() {
  local -- input_path=$1
  local -- allowed_dir=$2

  local -- real_path
  real_path=$(realpath -e -- "$input_path") || die 22 "Invalid path ${input_path@Q}"

  [[ "$real_path" != "$allowed_dir"* ]] && die 5 "Path outside allowed directory ${real_path@Q}"

  echo "$real_path"
}

safe_path=$(validate_path "$user_path" "/var/app/data")
```

**4. Email validation:**

```bash
validate_email() {
  local -- email=$1
  [[ -n "$email" ]] || die 22 'Email cannot be empty'

  local -- email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  [[ "$email" =~ $email_regex ]] || die 22 "Invalid email format: $email"
  ((${#email} <= 254)) || die 22 "Email too long (max 254 chars): $email"

  echo "$email"
}
```

**5. URL validation:**

```bash
validate_url() {
  local -- url=$1
  [[ -n "$url" ]] || die 22 'URL cannot be empty'
  [[ "$url" =~ ^https?:// ]] || die 22 "URL must start with http:// or https://: ${url@Q}"
  [[ "$url" =~ @ ]] && die 22 'URL cannot contain credentials'
  echo "$url"
}
```

**6. Whitelist validation:**

```bash
validate_choice() {
  local -- input=$1
  shift
  local -a valid_choices=("$@")

  local choice
  for choice in "${valid_choices[@]}"; do
    [[ "$input" == "$choice" ]] && return 0
  done

  die 22 "Invalid choice ${input@Q}. Valid: ${valid_choices[*]}"
}

declare -a valid_actions=('start' 'stop' 'restart' 'status')
validate_choice "$user_action" "${valid_actions[@]}"
```

**7. Username validation:**

```bash
validate_username() {
  local -- username="$1"
  [[ -n "$username" ]] || die 22 'Username cannot be empty'
  [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]] || die 22 "Invalid username ${username@Q}"
  ((${#username} >= 1 && ${#username} <= 32)) || die 22 "Username must be 1-32 characters ${username@Q}"
  echo "$username"
}
```

**8. Command injection prevention:**

```bash
# ✗ DANGEROUS - command injection vulnerability
user_file="$1"
cat "$user_file"  # If user_file="; rm -rf /", disaster!

# ✓ Safe - validate first
validate_filename "$user_file"
cat -- "$user_file"  # Use -- to prevent option injection

# ✗ DANGEROUS - using eval with user input
eval "$user_command"  # NEVER DO THIS!

# ✓ Safe - whitelist allowed commands
case "$user_command" in
  start|stop|restart) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac
```

**9. Option injection prevention:**

```bash
user_file=$1

# ✗ Dangerous - if user_file="--delete-all", disaster!
rm "$user_file"

# ✓ Safe - use -- separator
rm -- "$user_file"

# ✗ Dangerous - filename starting with -
ls "$user_file"  # If user_file="-la", becomes: ls -la

# ✓ Safe - use -- or prepend ./
ls -- "$user_file"
ls ./"$user_file"
```

**10. SQL injection prevention:**

```bash
# ✗ DANGEROUS - SQL injection vulnerability
user_id=$1
query="SELECT * FROM users WHERE id=$user_id"  # user_id="1 OR 1=1"

# ✓ Safe - validate input type first
user_id=$(validate_positive_integer "$user_id")
query="SELECT * FROM users WHERE id=$user_id"
```

**Anti-patterns:**

```bash
# ✗ WRONG - trusting user input
rm -rf "$user_dir"  # user_dir="/" = disaster!

# ✓ Correct - validate first
validate_path "$user_dir" "/safe/base/dir"
rm -rf "$user_dir"

# ✗ WRONG - weak validation
[[ -n "$filename" ]] && process "$filename"  # Not enough!

# ✓ Correct - thorough validation
filename=$(sanitize_filename "$filename")
process "$filename"

# ✗ WRONG - blacklist approach (always incomplete)
[[ "$input" != *'rm'* ]] || die 1 'Invalid input'  # Can be bypassed!

# ✓ Correct - whitelist approach
[[ "$input" =~ ^[a-zA-Z0-9]+$ ]] || die 1 'Invalid input'
```

**Security principles:**

1. **Whitelist over blacklist**: Define what IS allowed, not what isn't
2. **Validate early**: Check input before any processing
3. **Fail securely**: Reject invalid input with clear error
4. **Use `--` separator**: Prevent option injection in commands
5. **Never use `eval`**: Especially not with user input
6. **Absolute paths**: Use full paths to prevent PATH manipulation
7. **Principle of least privilege**: Run with minimum necessary permissions
