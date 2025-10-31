## Regular Expression Guidelines

**Use POSIX character classes and store complex patterns in readonly variables.**

**Rationale:** POSIX classes ensure locale-independent portability; predefined patterns reduce errors and improve maintainability.

**Example:**
```bash
# POSIX classes
[[ "$var" =~ ^[[:alnum:]]+$ ]]        # Alphanumeric
[[ "$var" =~ ^[[:digit:]]+$ ]]        # Digits

# Store patterns
readonly -- EMAIL_REGEX='^[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}$'
[[ "$email" =~ $EMAIL_REGEX ]] || die 1 'Invalid email'

# Capture groups
if [[ "$version" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  major="${BASH_REMATCH[1]}"
fi
```

**Anti-patterns:**
- `[a-zA-Z]` → Use `[[:alpha:]]` (locale-safe)
- Inline complex regex → Define as readonly variable

**Ref:** BCS1405
