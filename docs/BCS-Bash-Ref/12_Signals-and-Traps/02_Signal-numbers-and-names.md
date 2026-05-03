<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.2 Signal numbers and names

The mapping is platform-specific but stable on Linux. Full table in Appendix K.

- `kill -l` lists all signals known to bash.
- Names: with or without `SIG` prefix (`SIGTERM` and `TERM` both work).
- Numbers: stable on Linux.
- Real-time signals: `SIGRTMIN+N` and `SIGRTMAX-N` syntax.
- POSIX requires SIGHUP=1, SIGINT=2, SIGQUIT=3, SIGILL=4, SIGTRAP=5, SIGABRT=6.

#fin
