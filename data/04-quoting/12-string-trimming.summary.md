## String Trimming

**Rationale**: Use parameter expansion for efficient whitespace removal without spawning external processes like `sed` or `awk`. The `trim()` function removes leading and trailing whitespace (spaces and tabs) using nested parameter expansions.

**Implementation**:
```bash
trim() {
  local v="$*"
  v="${v#"${v%%[![:blank:]]*}"}"
  echo -n "${v%"${v##*[![:blank:]]}"}"
}
```

**How it works**:
1. `${v%%[![:blank:]]*}` - Finds leading whitespace
2. `${v#...}` - Removes that leading whitespace
3. `${v##*[![:blank:]]}` - Finds trailing whitespace
4. `${v%...}` - Removes that trailing whitespace

**Usage**:
```bash
result=$(trim "  hello world  ")  # Returns "hello world"
```
