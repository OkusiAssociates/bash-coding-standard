<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.4 Bash vs ksh

Korn shell variants.

- `ksh88` — POSIX baseline, widely deployed historically.
- `ksh93` — feature-rich, ahead of bash on some features (associative arrays since 1993).
- `mksh` (MirBSD ksh) — pdksh successor; on Android, OpenBSD.
- ksh has discipline functions, type system, floating point — bash does not.
- Some idioms differ: `print` vs `printf`, `read -A` vs `read -a`.

#fin
