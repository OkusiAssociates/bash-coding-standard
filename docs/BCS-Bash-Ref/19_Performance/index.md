<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIX — Performance

*Bash is often blamed for being slow. Most "slow Bash" scripts are slow because they fork external commands in tight loops. This Part documents the cost model, the profiling tools, and the optimisations.*

---

## Chapters

1. [19.1 The Bash cost model](01_The-Bash-cost-model.md) — Rough relative costs for common operations.
2. [19.2 Profiling tools](02_Profiling-tools.md) — Measuring where time goes.
3. [19.3 `time` builtin vs `time` external](03_time-builtin-vs-time-external.md) — Bash has a `time` reserved word and a `/usr/bin/time` external.
4. [19.4 `BASH_XTRACEFD`](04_BASH_XTRACEFD.md) — Redirect `set -x` output to a specific fd.
5. [19.5 `PS4` instrumentation](05_PS4-instrumentation.md) — Customise `set -x` trace prefix.
6. [19.6 `EPOCHREALTIME` for sub-second timing](06_EPOCHREALTIME-for-sub-second-timing.md) — Bash 5.0+ exposes the system clock with microsecond precision.
7. [19.7 Common optimisations](07_Common-optimisations.md) — Patterns that reliably speed up scripts.
8. [19.8 Parameter expansion vs external commands](08_Parameter-expansion-vs-external-commands.md) — Replace `sed`/`awk`/`cut` with bash builtins where possible.
9. [19.9 Pipes vs redirection](09_Pipes-vs-redirection.md) — `cmd > out 2>&1` instead of `cmd 2>&1 | tee out` when no filtering needed.
10. [19.10 Builtins vs externals](10_Builtins-vs-externals.md) — A short list of frequent external→builtin replacements.
11. [19.11 Bash 5.3 no-fork command substitution](11_Bash-5.3-no-fork-command-substitution.md) — `${ command; }` runs command in the current shell, no fork.
12. [19.12 Memory considerations](12_Memory-considerations.md) — Bash uses memory for variables, arrays, and process state.
13. [19.13 When Bash is the wrong tool](13_When-Bash-is-the-wrong-tool.md) — Bash has limits.

---

← Previous: [Part XVIII — Readline, History, and Completion](../18_Readline-History-and-Completion/index.md)

Next: [Part XX — Security](../20_Security/index.md) →

#fin
