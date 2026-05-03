<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XII — Signals and Traps

*Signals are bash's primary mechanism for asynchronous communication and lifecycle hooks. This Part documents the signal catalogue, the trap builtin, the pseudo-signals, and the discipline required to write signal-safe code.*

---

## Chapters

1. [12.1 Signal taxonomy](01_Signal-taxonomy.md) — Signals fall into broad functional categories.
2. [12.2 Signal numbers and names](02_Signal-numbers-and-names.md) — The mapping is platform-specific but stable on Linux.
3. [12.3 Uncatchable signals](03_Uncatchable-signals.md) — Two signals cannot be caught, blocked, or ignored.
4. [12.4 Signal disposition](04_Signal-disposition.md) — Each signal has one of four dispositions per process.
5. [12.5 The `trap` builtin](05_The-trap-builtin.md) — Registers handler commands for signals and pseudo-signals.
6. [12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN](06_Pseudo-signals-EXIT-ERR-DEBUG-RETURN.md) — Bash extends signals with four pseudo-signals tied to script lifecycle events.
7. [12.7 `trap -p` and trap inspection](07_trap-p-and-trap-inspection.md) — Listing the current trap state.
8. [12.8 Trap inheritance](08_Trap-inheritance.md) — Subshells reset most traps; functions inherit unless `set -E`/`set -T`.
9. [12.9 Trap reset across `exec`](09_Trap-reset-across-exec.md) — On `exec`, signal handlers are reset (POSIX requirement).
10. [12.10 Synchronous vs asynchronous delivery](10_Synchronous-vs-asynchronous-delivery.md) — Bash delivers signals between commands, not mid-command.
11. [12.11 Signal-safe code](11_Signal-safe-code.md) — Within a trap handler, certain operations are unsafe.
12. [12.12 Idempotent cleanup patterns](12_Idempotent-cleanup-patterns.md) — Traps that must run at most once and produce the same effect on every invocation.
13. [12.13 Tempfile and tempdir lifecycle](13_Tempfile-and-tempdir-lifecycle.md) — The canonical pattern for safe temporary storage.
14. [12.14 Lockfile pattern](14_Lockfile-pattern.md) — Mutual exclusion across script invocations.
15. [12.15 Atomic file write](15_Atomic-file-write.md) — Write to a sibling tempfile, then rename.
16. [12.16 Reload-on-SIGHUP](16_Reload-on-SIGHUP.md) — Convention: SIGHUP requests "reload your config".

---

← Previous: [Part XI — Process Management](../11_Process-Management/index.md)

Next: [Part XIII — Error Handling and Exit Status](../13_Error-Handling-and-Exit-Status/index.md) →

#fin
