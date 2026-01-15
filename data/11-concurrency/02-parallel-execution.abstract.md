### Parallel Execution Patterns

**Execute multiple commands concurrently while tracking PIDs and collecting results.**

#### Rationale
- Significant speedup for I/O-bound tasks
- Better resource utilization

#### Basic Pattern (PID Tracking)

```bash
declare -a pids=()
for server in "${servers[@]}"; do
  run_command "$server" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
```

#### Output Capture Pattern

Use temp files per job, cleanup via trap:
```bash
temp_dir=$(mktemp -d); trap 'rm -rf "$temp_dir"' EXIT
```

#### Concurrency Limit

Use `wait -n` with PID array, check `kill -0 "$pid"` to prune completed jobs.

#### Anti-Patterns

`count=0; { process; ((count++)); } &` â†' subshell loses variable changes. Use temp files: `echo 1 >> "$temp"/count`, then `wc -l < "$temp"/count`.

**See Also:** BCS1101 (Background Jobs), BCS1103 (Wait Patterns)

**Ref:** BCS1102
