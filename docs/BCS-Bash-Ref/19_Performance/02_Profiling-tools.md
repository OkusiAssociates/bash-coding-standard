<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.2 Profiling tools

Measuring where time goes.

- `time cmd` — wall, user, sys time.
- `time { cmd1; cmd2; …; }` — time a sequence.
- `BASH_XTRACEFD=N` and `set -x` — trace each command (§19.4).
- `EPOCHREALTIME` for fine-grained timing (§19.6).
- `strace -c -f cmd` — syscall counts and times.
- `perf stat cmd` — CPU performance counters; per-shell sampling rarely useful (bash dispatches via switch on opcode).
- For hot loops, sample-based profilers don't work well on bash; instrument manually.

```bash
# scenario: per-section instrumentation with EPOCHREALTIME
profile() {
  local -- label="$1"
  local -- start="$2"
  local -- end="$EPOCHREALTIME"
  printf >&2 'PROFILE %-20s %.6f s\n' "$label" \
    "$(awk -v a="$end" -v b="$start" 'BEGIN { print a - b }')"
}

t0=$EPOCHREALTIME
build_index
profile 'build_index' "$t0"

t0=$EPOCHREALTIME
process_data
profile 'process_data' "$t0"
```

`EPOCHREALTIME` is fork-free; the single `awk` per checkpoint is cheaper
than `bc` (§19.6 shows a fork-free integer-microsecond pattern). For
finer-grained traces, redirect `set -x` output via `BASH_XTRACEFD` (§19.4)
combined with a `PS4` carrying `$EPOCHREALTIME` (§19.5).

**See also**: §19.3 (`time` builtin), §19.4 (`BASH_XTRACEFD`), §19.5 (PS4), §19.6 (`EPOCHREALTIME`).

#fin
