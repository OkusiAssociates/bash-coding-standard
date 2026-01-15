## Trap Handling

**Use cleanup functions with trap to ensure resource cleanup on all exit paths (normal, error, signals).**

### Standard Pattern

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

1. **Set trap BEFORE creating resources** â†' prevents leaks if early exit
2. **Disable trap inside cleanup** â†' prevents recursion
3. **Use `$?` in trap** â†' preserves original exit code
4. **Single quotes in trap** â†' delays variable expansion

### Anti-Patterns

```bash
# âœ— Overwrites exit code
trap 'rm -f "$f"; exit 0' EXIT
# âœ“ Preserve exit code
trap 'ec=$?; rm -f "$f"; exit $ec' EXIT

# âœ— Variables expand immediately
trap "rm -f $file" EXIT
# âœ“ Expand at runtime
trap 'rm -f "$file"' EXIT
```

**Ref:** BCS0603
