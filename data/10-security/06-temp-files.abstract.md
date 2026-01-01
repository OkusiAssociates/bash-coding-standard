## Temporary File Handling

**Always use `mktemp` for temp files/dirs with EXIT trap cleanup—never hard-code paths.**

**Rationale:** Secure permissions (0600/0700), unique names prevent collisions, atomic creation prevents races, EXIT trap guarantees cleanup on failure/interrupt.

**Core pattern:**

```bash
declare -a TEMP_FILES=()
cleanup() {
  local -- f; for f in "${TEMP_FILES[@]}"; do
    [[ -f "$f" ]] && rm -f "$f"
    [[ -d "$f" ]] && rm -rf "$f"
  done
}
trap cleanup EXIT

temp=$(mktemp) || die 1 'Failed to create temp file'
TEMP_FILES+=("$temp")
```

**Anti-patterns:**

```bash
# ✗ Hard-coded path (collisions, predictable, no cleanup)
temp=/tmp/myapp_temp.txt

# ✗ PID-based (still predictable, race conditions)
temp=/tmp/myapp_$$.txt

# ✗ Multiple traps overwrite (temp1 leaked!)
trap 'rm -f "$temp1"' EXIT
trap 'rm -f "$temp2"' EXIT

# ✗ No error check
temp=$(mktemp)  # May fail silently

# ✓ Correct
temp=$(mktemp) || die 1 'Failed'
trap 'rm -f "$temp"' EXIT
```

**Key rules:**
- `mktemp -d` for directories �' `rm -rf` in trap
- Check success: `|| die`
- Single cleanup function for multiple temps
- Template: `mktemp /tmp/name.XXXXXX` (min 3 X's)
- Trap signals too: `trap cleanup EXIT SIGINT SIGTERM`

**Ref:** BCS1006
