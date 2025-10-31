## Performance Profiling

**Use `SECONDS` or `EPOCHREALTIME` builtins for timing operations.**

**Rationale:** Built-in timing variables avoid external `date` calls; `EPOCHREALTIME` provides microsecond precision (Bash 5.0+).

**Pattern:**
```bash
# Basic timing with SECONDS
SECONDS=0
operation
info "Completed in ${SECONDS}s"

# High-precision with EPOCHREALTIME
start=$EPOCHREALTIME
operation
end=$EPOCHREALTIME
runtime=$(awk "BEGIN {print $end - $start}")
```

**Anti-patterns:**
- `date +%s` ’ Use `SECONDS` builtin instead
- External `time` command ’ Use builtins for programmatic timing

**Ref:** BCS1408
