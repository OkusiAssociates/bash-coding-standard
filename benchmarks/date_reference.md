# Date Formatting: `date` vs `printf '%()T'` Reference

Bash 5.0+ provides `printf '%()T'` as a builtin `strftime` — no fork, no exec.
Benchmarks show **34-77× faster** than `$(date ...)` (gap widens with
iteration count and is largest in capture-to-variable mode). See BCS1213.

## Benchmark Results

Measured on Intel i9-13900HX, Bash 5.2.21, 10 runs per series, mean
times in seconds. See `date_results_*.txt` for raw data.

| Test                              | `printf '%()T'` | `date(1)`  | Speedup |
|-----------------------------------|----------------:|-----------:|--------:|
| Format only, 100 iter             | 0.003           | 0.086      | 33.6×   |
| Format only, 1K iter              | 0.016           | 0.842      | 51.1×   |
| Format only, 5K iter              | 0.081           | 4.167      | 51.5×   |
| Capture-to-variable, 100 iter     | 0.002           | 0.102      | 48.3×   |
| Capture-to-variable, 1K iter      | 0.014           | 1.010      | 71.0×   |
| Capture-to-variable, 5K iter      | 0.066           | 5.065      | 76.7×   |

**Reading the numbers:** the per-call cost of `printf '%()T'` is
microseconds; `date(1)` pays ~0.85 ms per call (fork + execve + pipe).
Capture-to-variable widens the gap because `var=$(date ...)` adds a
subshell on top of the fork — `printf -v var '%()T'` does neither.

## Equivalent Commands

| Use case | `date` command | `printf` equivalent |
|----------|---------------|-------------------|
| **Date** | `date +%F` | `printf '%(%F)T'` |
| **Time** | `date +%T` | `printf '%(%T)T'` |
| **Date+Time** | `date +'%F %T'` | `printf '%(%F %T)T'` |
| **ISO 8601 (seconds)** | `date -Is` | `printf -v ts '%(%FT%T%z)T'`; `printf '%s' "${ts:0:-2}:${ts: -2}"` |
| **Epoch seconds** | `date +%s` | `printf '%s' "$EPOCHSECONDS"` |
| **Epoch microseconds** | `date +%s.%N` | `printf '%s' "$EPOCHREALTIME"` (microseconds, not nano) |
| **UTC date+time** | `date -u +'%F %T'` | `TZ=UTC printf '%(%F %T)T'` |
| **Day of week** | `date +%A` | `printf '%(%A)T'` |
| **Short month** | `date +%b` | `printf '%(%b)T'` |
| **Log timestamp** | `date +'%b %d %T'` | `printf '%(%b %d %T)T'` |
| **Filename-safe stamp** | `date +%F_%T` | `printf '%(%F_%T)T'` |
| **Capture to variable** | `ts=$(date +%F)` | `printf -v ts '%(%F)T'` |
| **Format an epoch value** | `date -d @1712345678 +%F` | `printf '%(%F)T' 1712345678` |
| **RFC 5322 (email)** | `date -R` | `printf '%(%a, %d %b %Y %T %z)T'` |

## Still Needs `date`

| Use case | `date` command | Why no `printf` equivalent |
|----------|---------------|---------------------------|
| **Relative dates** | `date -d 'next Monday'` | No date arithmetic in `strftime` |
| **Date math** | `date -d '3 days ago'` | No relative offsets |
| **Nanoseconds** | `date +%N` | `$EPOCHREALTIME` is microseconds only |
| **Parse date string** | `date -d '2026-01-15' +%s` | `printf '%()T'` only takes epoch integers |
| **Set system clock** | `date -s '...'` | Completely different function |

## Notes

- `%F` = `%Y-%m-%d`, `%T` = `%H:%M:%S` — both POSIX `strftime(3)`.
- With no argument, `printf '%()T'` defaults to current time (Bash 4.4+).
  An explicit argument is only needed when formatting a specific epoch value.
- `printf -v var` captures to a variable without a subshell — doubly efficient
  compared to `var=$(date ...)` which forks *and* spawns a subshell.
- `$EPOCHSECONDS` and `$EPOCHREALTIME` are Bash builtins — no fork required.
- Add `\n` to printf commands if LF is actually required.

