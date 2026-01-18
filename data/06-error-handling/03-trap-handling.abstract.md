## Trap Handling

**Use cleanup function with trap to ensure resource cleanup on exit, signals, or errors.**

### Core Pattern

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

### Key Signals

| Signal | Trigger |
|--------|---------|
| `EXIT` | Any script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | kill command |

### Critical Rules

1. **Set trap BEFORE creating resources** - prevents leaks if script exits early
2. **Disable trap inside cleanup** - `trap - SIGINT SIGTERM EXIT` prevents recursion
3. **Preserve exit code** - capture `$?` in trap: `trap 'cleanup $?' EXIT`
4. **Single quotes** - `trap 'rm "$file"' EXIT` delays expansion until execution

### Anti-Patterns

```bash
trap 'rm "$f"; exit 0' EXIT      # → Always exits 0, loses real code
trap "rm $file" EXIT             # → Expands now, not at trap time
temp=$(mktemp); trap '...' EXIT  # → Set trap BEFORE mktemp
```

**Ref:** BCS0603
