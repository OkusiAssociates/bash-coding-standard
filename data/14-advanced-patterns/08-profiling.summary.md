## Performance Profiling

Simple performance measurement patterns using Bash builtin timers.

### Basic Timing Patterns

**SECONDS builtin** - Integer seconds elapsed:
```bash
profile_operation() {
  local -- operation="$1"
  SECONDS=0
  eval "$operation"
  info "Operation completed in ${SECONDS}s"
}
```

**EPOCHREALTIME** - High-precision microsecond timing (Bash 5.0+):
```bash
timer() {
  local -- start end runtime
  start=$EPOCHREALTIME
  "$@"
  end=$EPOCHREALTIME
  runtime=$(awk "BEGIN {print $end - $start}")
  info "Execution time: ${runtime}s"
}
```

### Rationale

- `SECONDS` provides simple integer-second timing without external commands
- `EPOCHREALTIME` offers microsecond precision for benchmarking
- Builtin timers have zero overhead compared to external `time` or `date` commands
- Use `awk` for floating-point arithmetic when subtracting `EPOCHREALTIME` values

### Key Patterns

- Reset `SECONDS=0` before operation for relative timing
- Store `EPOCHREALTIME` snapshots before/after for precise measurements
- Prefer `"$@"` over `eval` when possible for safety
- `EPOCHREALTIME` requires Bash 5.0+, fallback to `date +%s.%N` for older versions
