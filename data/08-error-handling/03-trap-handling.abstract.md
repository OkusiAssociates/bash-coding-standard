## Trap Handling

**Standard cleanup pattern ensures resource cleanup on any exit (error, signal, normal).**

```bash
cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile"
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:**
- Guarantees cleanup of temp files/locks/processes even on Ctrl+C, kill, or errors with `set -e`
- Preserves original exit code via `$?` for proper error propagation
- Prevents recursion by disabling trap before cleanup operations

**Key signals:** `EXIT` (always runs), `SIGINT` (Ctrl+C), `SIGTERM` (kill command)

**Critical rules:**
1. **Set trap BEFORE creating resources** → `trap 'cleanup $?' EXIT` then `temp_file=$(mktemp)`
2. **Disable trap first in cleanup** → Prevents infinite recursion if cleanup fails
3. **Use single quotes** → `trap 'rm "$var"' EXIT` delays expansion until triggered
4. **Capture exit code immediately** → `trap 'cleanup $?' EXIT` not `trap 'cleanup' EXIT`

**Anti-patterns:**
- `trap 'rm "$file"; exit 0' EXIT` → Loses original exit code
- Creating resources before installing trap → Resource leaks if early exit
- `trap "rm $temp_file" EXIT` → Expands variable now, not on trap execution

**Ref:** BCS0803
