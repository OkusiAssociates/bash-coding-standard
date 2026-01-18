### Wait Patterns

**Always capture wait exit codes; use `wait -n` for first-completion processing.**

**Rationale:** Ensures exit codes captured correctly, prevents hangs on failed processes.

#### Patterns

```bash
# Basic: capture exit code
cmd &; wait "$!" || die 1 'failed'

# Multiple jobs with error tracking
for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done

# First-completion (Bash 4.3+): wait -n
```

#### Anti-Pattern

`wait $!` without checking return → `wait $! || die 1 'msg'`

**See Also:** BCS1101, BCS1102

**Ref:** BCS1103
