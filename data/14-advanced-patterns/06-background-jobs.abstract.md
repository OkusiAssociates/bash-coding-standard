## Background Job Management

**Manage background processes using `&`, `$!`, and `wait` with proper error handling.**

**Pattern:**
```bash
# Track and monitor
long_running_command &
PID=$!
kill -0 "$PID" 2>/dev/null  # Check running

# Wait with timeout
timeout 10 wait "$PID" || kill "$PID" 2>/dev/null

# Multiple jobs
declare -a PIDS=()
for file in *.txt; do
  process_file "$file" &
  PIDS+=($!)
done
for pid in "${PIDS[@]}"; do wait "$pid"; done
```

**Critical**: Use `kill -0` to test process existence, `timeout` for bounded waits, array for multiple PIDs. Exit code 124 indicates timeout.

**Ref:** BCS1406
