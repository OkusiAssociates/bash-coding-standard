## Trap Handling

**Use cleanup functions with `trap 'cleanup $?' SIGINT SIGTERM EXIT` to ensure resources are released on any exit.**

### Core Pattern

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -d "$temp_dir" ]] && rm -rf "$temp_dir"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Critical Rules

- **Set trap early** — before creating resources (prevents leaks if script fails between creation and trap)
- **Disable trap first in cleanup** — prevents infinite recursion if cleanup fails
- **Capture `$?` in trap command** — `trap 'cleanup $?' EXIT` preserves original exit code
- **Single quotes** — delays variable expansion until trap fires

### Signals

| Signal | Trigger |
|--------|---------|
| `EXIT` | Any script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |

### Anti-Patterns

```bash
# ✗ Exit code lost
trap 'rm "$f"; exit 0' EXIT
# ✓ Preserve exit code
trap 'ec=$?; rm "$f"; exit $ec' EXIT

# ✗ Double quotes expand NOW
trap "rm $temp" EXIT
# ✓ Single quotes expand on TRAP
trap 'rm "$temp"' EXIT

# ✗ Resource before trap (leak risk)
temp=$(mktemp); trap 'rm "$temp"' EXIT
# ✓ Trap before resource
trap 'rm "$temp"' EXIT; temp=$(mktemp)
```

**Ref:** BCS0603
