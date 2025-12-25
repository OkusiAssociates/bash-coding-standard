### Background Job Management

**Rule: BCS1406**

Managing background processes, job control, and process lifecycle.

---

#### Rationale

Background jobs enable non-blocking execution, parallel processing, responsive scripts, and proper resource cleanup on termination.

---

#### Starting Background Jobs

```bash
# Basic background execution
long_running_command &
declare -i pid=$!

# Track multiple jobs
declare -a pids=()
for file in "${files[@]}"; do
  process_file "$file" &
  pids+=($!)
done
```

#### Checking Process Status

```bash
# Check if process is running (signal 0 = existence check)
if kill -0 "$pid" 2>/dev/null; then
  info "Process $pid is still running"
fi

# Get process state from /proc
if [[ -d /proc/$pid ]]; then
  state=$(< /proc/$pid/stat)
fi
```

#### Waiting for Jobs

```bash
wait "$pid"           # Wait for specific PID
exit_code=$?
wait                  # Wait for all background jobs
wait -n               # Wait for any job to complete (Bash 4.3+)
```

#### Cleanup Pattern

```bash
declare -a PIDS=()

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion

  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

for task in "${tasks[@]}"; do
  run_task "$task" &
  PIDS+=($!)
done

for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no PID tracking (cannot manage or wait later)
command &

# ✓ Correct - always track PIDs
command &
pid=$!
```

```bash
# ✗ Wrong - $$ is parent PID, not child
command &
echo "Started $$"

# ✓ Correct - use $! for last background PID
command &
echo "Started $!"
```

---

**See Also:** BCS1407 (Parallel Execution), BCS1408 (Wait Patterns), BCS1409 (Timeout Handling)

#fin
