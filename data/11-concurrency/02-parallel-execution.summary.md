### Parallel Execution Patterns

**Rule: BCS1407**

Executing multiple commands concurrently while maintaining control and collecting results.

---

#### Rationale

Parallel execution provides significant speedup for I/O-bound tasks, better resource utilization, and efficient batch processing.

---

#### Basic Parallel Pattern

```bash
declare -a pids=()

# Start jobs in parallel
for server in "${servers[@]}"; do
  run_command "$server" "$@" &
  pids+=($!)
done

# Wait for all to complete
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
```

#### Parallel with Output Capture

```bash
declare -- temp_dir
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

declare -a pids=()

for server in "${servers[@]}"; do
  {
    result=$(run_command "$server" 2>&1)
    echo "$result" > "$temp_dir/$server.out"
  } &
  pids+=($!)
done

# Wait then display in order
for pid in "${pids[@]}"; do
  wait "$pid" || true
done

for server in "${servers[@]}"; do
  [[ -f "$temp_dir/$server.out" ]] && cat "$temp_dir/$server.out"
done
```

#### Parallel with Concurrency Limit

```bash
declare -i max_jobs=4
declare -a pids=()

for task in "${tasks[@]}"; do
  while ((${#pids[@]} >= max_jobs)); do
    wait -n 2>/dev/null || true
    local -a active=()
    for pid in "${pids[@]}"; do
      kill -0 "$pid" 2>/dev/null && active+=("$pid")
    done
    pids=("${active[@]}")
  done

  process_task "$task" &
  pids+=($!)
done

wait
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - variable lost in subshell
count=0
for task in "${tasks[@]}"; do
  { process "$task"; ((count+=1)); } &
done
wait
echo "$count"  # Always 0!

# ✓ Correct - use temp files for results
for task in "${tasks[@]}"; do
  { process "$task" && echo 1 >> "$temp_dir/count"; } &
done
wait
count=$(wc -l < "$temp_dir/count")
```

---

**See Also:** BCS1406 (Background Jobs), BCS1408 (Wait Patterns)

#fin
