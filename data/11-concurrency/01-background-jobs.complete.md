### Background Job Management

**Rule: BCS1101**

Managing background processes, job control, and process lifecycle in Bash scripts.

---

#### Rationale

Background jobs enable:
- Non-blocking execution of long-running commands
- Parallel processing for improved performance
- Responsive scripts that can handle multiple tasks
- Proper resource cleanup on script termination

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
if [[ -d /proc/"$pid" ]]; then
  state=$(< /proc/"$pid"/stat)
fi
```

#### Waiting for Jobs

```bash
# Wait for specific PID
wait "$pid"
exit_code=$?

# Wait for all background jobs
wait

# Wait for any job to complete (Bash 4.3+)
wait -n
```

#### Cleanup Pattern

```bash
declare -a PIDS=()

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT  # Prevent recursion

  # Kill any remaining background jobs
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done

  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# Start jobs
for task in "${tasks[@]}"; do
  run_task "$task" &
  PIDS+=($!)
done

# Wait for completion
for pid in "${PIDS[@]}"; do
  wait "$pid" || true
done
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no PID tracking
command &
# Later cannot manage or wait for it

# ✓ Correct - always track PIDs
command &
pid=$!
```

```bash
# ✗ Wrong - using $$ in background job
command &
echo "Started $$"  # This is parent PID, not child

# ✓ Correct - use $! for last background PID
command &
echo "Started $!"
```

---

**See Also:** BCS1102 (Parallel Execution), BCS1103 (Wait Patterns), BCS1104 (Timeout Handling)

**Full implementation:** See `examples/exemplar-code/oknav/oknav` lines 475-510
