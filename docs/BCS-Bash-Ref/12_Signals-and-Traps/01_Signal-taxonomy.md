<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.1 Signal taxonomy

Signals fall into broad functional categories that share a
default-action profile. The full numeric mapping and per-signal default
behaviour live in **Appendix K** (`Signal Numbers — Linux`); this section
groups them by *purpose* so a reader can find the right signal for a
given task.

| Category | Members | Typical default action |
|----------|---------|-----------------------|
| Termination request | `SIGTERM`, `SIGINT`, `SIGQUIT` | terminate (some with core) |
| Forced termination  | `SIGKILL`                       | terminate (uncatchable, §12.3) |
| Stop / continue     | `SIGSTOP`, `SIGTSTP`, `SIGCONT`, `SIGTTIN`, `SIGTTOU` | stop / continue |
| Hardware errors     | `SIGSEGV`, `SIGBUS`, `SIGILL`, `SIGFPE` | terminate + core |
| Pipe and I/O        | `SIGPIPE`, `SIGURG`, `SIGIO`             | terminate (PIPE), ignore (URG/IO) |
| Reload / hangup     | `SIGHUP`                                  | terminate (convention: reload) |
| User-defined        | `SIGUSR1`, `SIGUSR2`                      | terminate by default |
| Children            | `SIGCHLD`                                 | ignore |
| Resources           | `SIGXCPU`, `SIGXFSZ`                      | terminate + core |
| Alarms / timing     | `SIGALRM`, `SIGVTALRM`, `SIGPROF`         | terminate |
| Real-time           | `SIGRTMIN`..`SIGRTMAX` (queued, prioritised) | terminate by default |
| Window change       | `SIGWINCH`                                 | ignore |

### Choosing the right signal

| Goal | Signal | Why |
|------|--------|-----|
| polite shutdown | `SIGTERM`  | catchable; the standard "please exit cleanly" |
| unconditional kill | `SIGKILL` | uncatchable; last-resort only (§12.3) |
| reload config in a daemon | `SIGHUP` | convention; bash daemons should honour (§12.16) |
| user signalling between cooperating scripts | `SIGUSR1`, `SIGUSR2` | reserved for application use; not used by the kernel |
| terminal interrupt | `SIGINT` | the `Ctrl-C` signal; foreground-pgrp delivery |
| terminal stop | `SIGTSTP` | the `Ctrl-Z` signal; resume with SIGCONT |
| ignore broken pipes | `SIGPIPE` | set ignored if writes to closed readers must not abort the script |

```bash
# scenario: inspect the current shell's signal mask via /proc
grep -E '^Sig(Cgt|Ign|Blk):' /proc/self/status
# ⇒ SigBlk
# ⇒ SigIgn
# ⇒ SigCgt
# (the right-hand side of each line is a 16-hex-digit bitmask — set bits
#  identify which signals are blocked / ignored / caught in this shell)
#   SigIgn:  ...    (ignored signals)
#   SigBlk:  ...    (blocked signals)
```

The default-action column above is a summary; for the canonical mapping
to Linux kernel numbers, the queued-signal class (`SIGRTMIN`..`SIGRTMAX`),
and per-signal interruption semantics, refer to **Appendix K**. Signal
numbers are **not** portable across platforms: only `SIGHUP=1`,
`SIGINT=2`, `SIGQUIT=3`, `SIGILL=4`, `SIGTRAP=5`, `SIGABRT=6` are
mandated by POSIX. Always use names in scripts, never numbers — `kill
-15 $$` is a portability bug waiting to happen, `kill -TERM $$` is not.

**See also**: §12.2 (signal numbers and names), §12.3 (uncatchable
signals), §12.4 (signal disposition), §12.5 (the `trap` builtin),
Appendix K (signal numbers — Linux), BCS-bash `24_SIGNALS.md`, BCS0603
(trap handling).

#fin
