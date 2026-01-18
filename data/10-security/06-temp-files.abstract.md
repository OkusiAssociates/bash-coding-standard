## Temporary File Handling

**Always use `mktemp` for temp files/dirs; never hard-code paths. Use EXIT trap for guaranteed cleanup.**

### Rationale
- **Security**: mktemp creates files with 0600 permissions atomically
- **Uniqueness**: Prevents collisions and race conditions
- **Cleanup**: EXIT trap ensures removal even on failure/interruption

### Pattern
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
readonly -- temp_file
echo 'data' > "$temp_file"
```

For directories: `mktemp -d` with `rm -rf` in trap.

For multiple files, use array + cleanup function:
```bash
declare -a TEMP_FILES=()
cleanup() { for f in "${TEMP_FILES[@]}"; do rm -rf "$f"; done; }
trap cleanup EXIT
```

### Anti-Patterns
- `temp=/tmp/myapp.txt` → Predictable, collisions, no cleanup
- `trap 'rm "$t1"' EXIT; trap 'rm "$t2"' EXIT` → Second trap overwrites first; combine: `trap 'rm -f "$t1" "$t2"' EXIT`

**Ref:** BCS1006
