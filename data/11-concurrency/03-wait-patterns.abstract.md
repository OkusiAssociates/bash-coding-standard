### Wait Patterns

**Synchronize background processes: capture exit codes, track failures, avoid hangs.**

---

#### Why

- Exit codes lost without `wait` capture â†' silent failures
- Unwaited processes â†' zombie/resource leaks
- `wait -n` enables first-completion processing (Bash 4.3+)

---

#### Core Patterns

```bash
# Basic: capture exit code
cmd &
wait "$!" || die 1 'Command failed'

# Multiple jobs: track failures
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || ((errors+=1))
done
((errors)) && warn "$errors jobs failed"

# Wait-any (4.3+): process as completed
while ((${#pids[@]})); do
  wait -n; code=$?
  # Update active list via kill -0
done
```

---

#### Anti-Pattern

`wait $!` without checking `$?` â†' exit code silently discarded â†' `wait "$pid" || handle_error`

---

**See Also:** BCS1406, BCS1407

**Ref:** BCS1103
