<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.1 The Bash cost model

Rough relative costs for common operations.

- Builtin (e.g., `[[`, `printf`, parameter expansion): nanoseconds. Effectively free.
- Variable assignment, arithmetic, string operations: nanoseconds.
- Subshell `$(…)`, `(…)`, pipeline element: ~1 millisecond.
- Fork+exec of an external command: ~1 millisecond (depends on binary size and OS caching).
- Disk I/O: variable (microseconds to milliseconds).
- Network I/O: variable (milliseconds).
- A single fork is cheap; 10,000 forks in a loop is ~10 seconds.

These figures are order-of-magnitude estimates measured on Linux 6.x with
warm filesystem caches; the absolute numbers vary with hardware, but the
ratios — builtin ≪ subshell ≈ fork — hold consistently. Profile your own
hot path before optimising (§19.2).

```bash
# scenario: back-of-envelope demo — 10,000 builtin vs subshell calls
n=10000

start=$EPOCHREALTIME
for ((i = 0; i < n; i+=1)); do : ; done                     # builtin only
end=$EPOCHREALTIME
printf 'builtin loop:  %.3f s\n' "$(( ${end/./} - ${start/./} ))e-6"

start=$EPOCHREALTIME
for ((i = 0; i < n; i+=1)); do x=$(echo) ; done             # subshell each iter
end=$EPOCHREALTIME
printf 'subshell loop: %.3f s\n' "$(( ${end/./} - ${start/./} ))e-6"
# ⇒ builtin loop:
# ⇒ subshell loop:
# (absolute numbers vary by hardware; the load-bearing observation is the
#  ratio: the subshell loop is roughly two orders of magnitude slower)
```

The two-orders-of-magnitude gap is why §19.8 (parameter expansion vs
externals) matters in inner loops.

**See also**: §19.2 (profiling), §19.6 (`EPOCHREALTIME`), §19.8 (param vs external).

#fin
