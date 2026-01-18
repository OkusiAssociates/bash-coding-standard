### Parallel Execution Patterns

**Execute multiple commands concurrently using PID arrays and wait loops.**

**Why:** I/O-bound speedup; better resource utilization; efficient batch processing.

#### Pattern

```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || true; done
```

**Output capture:** Use temp files (`mktemp -d`) per job, display in order after all complete.

**Concurrency limit:** Track active PIDs with `kill -0`, use `wait -n` to reap completed jobs.

#### Anti-Pattern

```bash
# ✗ Variable lost in subshell
count=0; for t in "${tasks[@]}"; do { process "$t"; ((count++)); } & done
echo "$count"  # Always 0!
# ✓ Use temp files: echo 1 >> "$temp"/count; count=$(wc -l < "$temp"/count)
```

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102
