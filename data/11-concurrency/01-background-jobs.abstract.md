### Background Job Management

**Always track PIDs with `$!` and implement cleanup traps for background processes.**

#### Rationale
- Enables parallel processing and non-blocking execution
- Proper cleanup prevents orphaned processes on termination

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
- `$!` — last background PID → `kill -0 "$pid"` — check if running → `wait "$pid"` — block until done

#### Anti-Patterns
- `command &` without `pid=$!` → cannot manage/wait later
- Using `$$` for background PID → wrong (parent PID, not child)

**Ref:** BCS1101
