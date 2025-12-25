### Background Job Management

**Always track PIDs with `$!` and implement trap-based cleanup for background processes.**

#### Key Patterns

```bash
# Track PIDs in array
declare -a PIDS=()
command & PIDS+=($!)

# Check if running (signal 0)
kill -0 "$pid" 2>/dev/null

# Wait patterns
wait "$pid"    # Specific PID
wait -n        # Any job (Bash 4.3+)
```

#### Cleanup Pattern

```bash
cleanup() {
  trap - SIGINT SIGTERM EXIT  # Prevent recursion
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

#### Anti-Patterns

- `command &` without `pid=$!` â†' cannot manage process later
- Using `$$` for background PID â†' wrong; `$$` is parent, `$!` is child

**Ref:** BCS1101
