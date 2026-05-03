<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.8 Signals — overview

Signals are asynchronous notifications delivered to a process by the kernel or another process. Each has a default action (terminate, core-dump, ignore, stop, continue) and most can be caught with `trap` (BCS0110, BCS0603). This chapter introduces the model and enumerates the standard signals; the deep treatment of trapping, pseudo-signals, and signal-safe cleanup lives in Part XII.

Two delivery modes:

- Synchronous — provoked by the running thread itself (`SIGSEGV`, `SIGFPE`, `SIGILL`, `SIGBUS`).
- Asynchronous — sent from outside (`SIGINT` from `^C`, `SIGTERM` from `kill`, `SIGHUP` on terminal hangup).

Two signals cannot be caught, blocked, or ignored: `SIGKILL` (9) and `SIGSTOP` (19). Plan for them — never assume cleanup is guaranteed (see §12.3 and BCS1006 for the temp-file discipline that survives uncatchable death).

Common standard signals:

| Num | Name      | Default     | Typical cause                          |
|-----|-----------|-------------|----------------------------------------|
| 1   | SIGHUP    | terminate   | controlling terminal closed            |
| 2   | SIGINT    | terminate   | `^C` from terminal                     |
| 3   | SIGQUIT   | core-dump   | `^\` from terminal                     |
| 9   | SIGKILL   | terminate   | `kill -9` — uncatchable                |
| 13  | SIGPIPE   | terminate   | write to a pipe with no readers        |
| 15  | SIGTERM   | terminate   | polite shutdown request                |
| 17  | SIGCHLD   | ignore      | child changed state                    |
| 18  | SIGCONT   | continue    | resume a stopped process               |
| 19  | SIGSTOP   | stop        | uncatchable suspend                    |
| 20  | SIGTSTP   | stop        | `^Z` from terminal                     |
| 28  | SIGWINCH  | ignore      | terminal size changed                  |

Real-time signals occupy `SIGRTMIN`..`SIGRTMAX` (typically 34..64); they queue rather than coalesce and carry an integer payload. Bash exposes only the standard set to `trap`.

```bash
# scenario: list every signal name your kernel knows
kill -l                       # ⇒ HUP INT QUIT ILL TRAP ABRT BUS FPE KILL ...
# scenario: send a deliberate non-default signal
kill -USR1 "$$"               # default action for USR1 is "terminate" — don't try this without a trap
# scenario: encode signal exit status (128 + signo, see §1.7)
( trap '' TERM; kill -TERM "$BASHPID"; sleep 1 )
# the inner shell ignores TERM, so this is illustrative only
```

**See also**: §1.7 (exit status — signal-induced exits encode as 128+N), §11.1 (process groups and which signals propagate), §12.1–§12.6 (full signal reference, `trap` builtin, pseudo-signals EXIT/ERR/DEBUG/RETURN), Appendix K (signal default-action table).

#fin
