### Wait Patterns

**Rule:** Proper synchronization when waiting for background processesâ€”capture exit codes, track failures, clean up resources.

**Core patterns:**
- `wait "$pid"` â†' capture `$?` for single job
- `wait` (no args) â†' wait for all
- `wait -n` (Bash 4.3+) â†' wait for first to complete

**Error tracking:**
```bash
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors+=1))
done
((errors)) && warn "$errors jobs failed"
```

**Wait-any pattern:**
```bash
while ((${#pids[@]} > 0)); do
  wait -n; code=$?
  # Update active list
  local -a active=()
  for pid in "${pids[@]}"; do
    kill -0 "$pid" 2>/dev/null && active+=("$pid")
  done
  pids=("${active[@]}")
done
```

**Anti-pattern:** `wait $!` without capturing â†' `wait $! || die 1 'Failed'`

**Ref:** BCS1408
