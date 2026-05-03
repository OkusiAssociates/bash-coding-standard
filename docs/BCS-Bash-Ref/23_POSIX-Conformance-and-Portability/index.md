<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXIII — POSIX Conformance and Portability

*When and how to write code that runs on more than just Bash. Most production code does not need to be portable; some does. This Part documents the trade-offs.*

---

## Chapters

1. [23.1 Bash vs POSIX sh](01_Bash-vs-POSIX-sh.md) — The features bash adds beyond POSIX 1003.2 / SUSv4.
2. [23.2 The bashisms list](02_The-bashisms-list.md) — Specific constructs that fail in `dash` / POSIX `sh`.
3. [23.3 Bash vs dash](03_Bash-vs-dash.md) — `dash` is Ubuntu/Debian's `/bin/sh` — POSIX-only, no bashisms.
4. [23.4 Bash vs ksh](04_Bash-vs-ksh.md) — Korn shell variants.
5. [23.5 Bash vs zsh](05_Bash-vs-zsh.md) — zsh is interactive-rich, scripting-divergent.
6. [23.6 Bash 3.2 on macOS](06_Bash-3.2-on-macOS.md) — Apple ships bash 3.2 (2007).
7. [23.7 BSD `sh`](07_BSD-sh.md) — FreeBSD, OpenBSD, NetBSD use various `sh` implementations.
8. [23.8 `--posix` mode](08_posix-mode.md) — Bash's POSIX-conformance mode.
9. [23.9 `shopt` compatibility levels](09_shopt-compatibility-levels.md) — Bash supports limited backward compatibility via `shopt -s compatNN`.
10. [23.10 When to write portable sh](10_When-to-write-portable-sh.md) — Cases where POSIX-only is the right choice.
11. [23.11 Forward-compatibility hygiene](11_Forward-compatibility-hygiene.md) — Writing bash that won't break in future versions.
12. [23.12 Targeting multiple Bash versions](12_Targeting-multiple-Bash-versions.md) — Supporting both old and new bash from one script.

---

← Previous: [Part XXII — Idioms, Patterns, and Anti-Patterns](../22_Idioms-Patterns-and-Anti-Patterns/index.md)

Next: [Part XXIV — Bash Internals](../24_Bash-Internals/index.md) →

#fin
