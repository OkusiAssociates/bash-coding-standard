### Parallel Execution Patterns

**Track PIDs with `pids+=($!)`, wait with `wait "$pid"`, limit concurrency with `wait -n` and `kill -0`.**

**Rationale:** 10-100x speedup for I/O-bound tasks; better resource utilization; ordered output via temp files.

---

#### Core Patterns

**Basic parallel with PID tracking:**
```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid" || true; done
```

**Concurrency limit (pool pattern):**
```bash
while ((${#pids[@]} >= max_jobs)); do
  wait -n 2>/dev/null || true
  # Prune completed PIDs with kill -0
done
```

---

#### Anti-Pattern

```bash
# ✗ Variables lost in subshell
count=0; for t in "${tasks[@]}"; do { process "$t"; count+=1; } & done
echo "$count"  # Always 0!

# ✓ Use temp files: echo 1 >> "$temp"/count; count=$(wc -l < "$temp"/count)
```

---

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102
