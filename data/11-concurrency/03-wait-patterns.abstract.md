### Wait Patterns

**Always capture exit codes from `wait` and track failures across parallel jobs.**

#### Rationale
- Exit codes lost without capture �' silent failures
- Orphan processes consume resources
- Scripts hang on failed processes without proper tracking

#### Pattern

```bash
# Track multiple jobs with error collection
declare -a pids=()
for task in "${tasks[@]}"; do
  process_task "$task" &
  pids+=($!)
done

declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors++))
done
((errors)) && die 1 "$errors jobs failed"
```

#### Anti-Patterns

```bash
# ✗ Exit code lost
command &
wait $!

# ✓ Capture exit code
command &
wait $! || die 1 'Command failed'
```

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103
