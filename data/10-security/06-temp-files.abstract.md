## Temporary File Handling

**Always use `mktemp` for temp files/dirs; use EXIT trap for cleanup; never hard-code paths.**

**Rationale:** mktemp creates files atomically with secure permissions (0600/0700); EXIT trap guarantees cleanup on failure/interruption; prevents race conditions and file collisions.

**Pattern:**

```bash
declare -a TEMP_FILES=()
cleanup() {
  local -- f; for f in "${TEMP_FILES[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"; [[ -d "$f" ]] && rm -rf "$f"
  done
}
trap cleanup EXIT

temp=$(mktemp) || die 1 'Failed to create temp file'
TEMP_FILES+=("$temp")
```

**Anti-patterns:**

```bash
# ✗ Hard-coded path �' predictable, no cleanup
temp=/tmp/myapp.txt

# ✗ Multiple traps overwrite each other
trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT  # t1 never cleaned!

# ✓ Single cleanup function for all resources
```

**Ref:** BCS1006
