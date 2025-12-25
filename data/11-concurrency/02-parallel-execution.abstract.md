### Parallel Execution Patterns

**Run concurrent commands with PID tracking; use temp files to collect results (variables lost in subshells).**

#### Rationale
- I/O-bound tasks gain significant speedup
- Subshell isolation prevents direct variable sharing

#### Pattern: Basic Parallel with Output Capture

```bash
declare -- temp_dir
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
declare -a pids=()

for server in "${servers[@]}"; do
  { run_command "$server" 2>&1 > "$temp_dir/$server.out"; } &
  pids+=($!)
done

for pid in "${pids[@]}"; do wait "$pid" || true; done
for server in "${servers[@]}"; do
  [[ -f "$temp_dir/$server.out" ]] && cat "$temp_dir/$server.out"
done
```

#### Concurrency Limit Pattern

```bash
declare -i max_jobs=4
while ((${#pids[@]} >= max_jobs)); do
  wait -n 2>/dev/null || true
  # Prune completed PIDs with kill -0
done
```

#### Anti-Pattern

```bash
# ✗ Variable lost in subshell
count=0
{ process "$task"; ((count+=1)); } &  # count stays 0!

# ✓ Use temp files
{ process "$task" && echo 1 >> "$temp_dir/count"; } &
count=$(wc -l < "$temp_dir/count")
```

**See Also:** BCS1406 (Background Jobs), BCS1408 (Wait Patterns)

**Ref:** BCS1102
