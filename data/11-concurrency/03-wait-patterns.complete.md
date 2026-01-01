### Wait Patterns

**Rule: BCS1408** (New)

Proper synchronization when waiting for background processes.

---

#### Rationale

Proper wait handling ensures:
- All resources are cleaned up
- Exit codes are captured correctly
- Scripts don't hang on failed processes
- Graceful handling of interrupted waits

---

#### Basic Wait

```bash
# Wait for specific PID and capture exit code
command &
pid=$!
wait "$pid"
exit_code=$?
```

#### Wait for All Jobs

```bash
# Wait for all background jobs
wait

# With error tracking
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors+=1))
done
((errors)) && warn "$errors jobs failed"
```

#### Wait for Any (Bash 4.3+)

```bash
# Wait for first job to complete
declare -a pids=()
for task in "${tasks[@]}"; do
  process_task "$task" &
  pids+=($!)
done

# Process as they complete
while ((${#pids[@]} > 0)); do
  wait -n
  exit_code=$?
  # Handle completion...

  # Update active PIDs list
  local -a active=()
  for pid in "${pids[@]}"; do
    kill -0 "$pid" 2>/dev/null && active+=("$pid")
  done
  pids=("${active[@]}")
done
```

#### Wait with Error Collection

```bash
declare -A exit_codes=()

for server in "${servers[@]}"; do
  run_command "$server" &
  exit_codes[$server]=$!
done

declare -i failures=0
for server in "${!exit_codes[@]}"; do
  pid=${exit_codes[$server]}
  if ! wait "$pid"; then
    exit_codes[$server]=$?
    ((failures+=1))
  else
    exit_codes[$server]=0
  fi
done

((failures)) && error "$failures servers failed"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - ignoring wait return value
command &
wait $!  # Exit code lost

# ✓ Correct - capture and use exit code
command &
wait $! || die 1 'Command failed'
```

---

**See Also:** BCS1406 (Background Jobs), BCS1407 (Parallel Execution)
