<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XI — Process Management

*Bash sits at the intersection of the shell language and the Unix process model. This Part documents how Bash creates, tracks, signals, and manages processes — its own and its children.*

---

## Chapters

1. [11.1 The Bash process tree at runtime](01_The-Bash-process-tree-at-runtime.md) — A running Bash script has a process tree shape determined by its constructs.
2. [11.2 PIDs: `$$`, `$BASHPID`, `$PPID`](02_PIDs-BASHPID-PPID.md) — Three variables, three different meanings.
3. [11.3 Subshell origins](03_Subshell-origins.md) — Constructs that fork a subshell.
4. [11.4 `BASH_SUBSHELL` depth tracking](04_BASH_SUBSHELL-depth-tracking.md) — Bash maintains a counter of subshell depth.
5. [11.5 Foreground vs background](05_Foreground-vs-background.md) — Bash distinguishes foreground commands (the shell waits for them) from background (started with `&`).
6. [11.6 Process groups and sessions](06_Process-groups-and-sessions.md) — The kernel groups processes into process groups and sessions for signal delivery and terminal control.
7. [11.7 The job table](07_The-job-table.md) — When job control is on, bash maintains a table of jobs.
8. [11.8 Job specifications](08_Job-specifications.md) — Jobs can be referenced by several syntaxes.
9. [11.9 Job-control builtins](09_Job-control-builtins.md) — Manipulate the job table.
10. [11.10 `kill` and signal delivery](10_kill-and-signal-delivery.md) — The `kill` builtin sends signals.
11. [11.11 `nohup` and `setsid`](11_nohup-and-setsid.md) — Decoupling from the controlling terminal.
12. [11.12 Detaching from the terminal](12_Detaching-from-the-terminal.md) — Comprehensive detachment for daemons.
13. [11.13 Environment inheritance](13_Environment-inheritance.md) — Children inherit the environment at fork+exec.

---

← Previous: [Part X — Sourcing, Libraries, and Modules](../10_Sourcing-Libraries-and-Modules/index.md)

Next: [Part XII — Signals and Traps](../12_Signals-and-Traps/index.md) →

#fin
