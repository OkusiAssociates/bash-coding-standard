<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVI — Concurrency and Parallelism

*Bash supports background jobs, wait-for-any, bounded fan-out, and external parallelism tools. This Part documents the patterns and the pitfalls.*

---

## Chapters

1. [16.1 Sequential vs background execution](01_Sequential-vs-background-execution.md) — - `cmd` — foreground, blocks until completion.
2. [16.2 `wait` and `wait -n`](02_wait-and-wait-n.md) — Wait for child processes.
3. [16.3 `wait $pid` for specific child](03_wait-pid-for-specific-child.md) — Capture per-child exit status.
4. [16.4 Capturing per-child exit status](04_Capturing-per-child-exit-status.md) — Patterns for collecting status from many children.
5. [16.5 Bounded-concurrency fan-out](05_Bounded-concurrency-fan-out.md) — Run N tasks in parallel with a cap on concurrent jobs.
6. [16.6 The job table under concurrency](06_The-job-table-under-concurrency.md) — When job control is on, jobs are tracked.
7. [16.7 `xargs -P`](07_xargs-P.md) — External tool for parallel one-shot work.
8. [16.8 GNU parallel](08_GNU-parallel.md) — Richer parallel execution tool.
9. [16.9 Race conditions in shell](09_Race-conditions-in-shell.md) — Common races and how to avoid them.
10. [16.10 Locking primitives](10_Locking-primitives.md) — Choosing the right lock.
11. [16.11 Signal handling under concurrency](11_Signal-handling-under-concurrency.md) — Signal delivery with multiple children is subtle.
12. [16.12 Queue patterns](12_Queue-patterns.md) — Producer-consumer in shell.

---

← Previous: [Part XV — Command-Line Processing](../15_Command-Line-Processing/index.md)

Next: [Part XVII — Coprocesses and IPC](../17_Coprocesses-and-IPC/index.md) →

#fin
