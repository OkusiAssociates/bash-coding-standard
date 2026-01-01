### Background Job Management

**Always track PIDs with `$!`; use trap-based cleanup for proper process lifecycle.**

#### Core Pattern

```bash
declare -a PIDS=()
cleanup() {
  trap - SIGINT SIGTERM EXIT
  for pid in "${PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
}
trap 'cleanup' SIGINT SIGTERM EXIT

command & PIDS+=($!)
wait "${PIDS[@]}"
```

#### Key Operations

- **Start:** `cmd &` then `pid=$!`
- **Check:** `kill -0 "$pid" 2>/dev/null`
- **Wait:** `wait "$pid"` (specific) or `wait -n` (any, Bash 4.3+)

#### Anti-Patterns

- `command &` without `pid=$!` â†' cannot manage job later
- Using `$$` for background PID â†' wrong; `$$` is parent, `$!` is child

**Ref:** BCS1101
