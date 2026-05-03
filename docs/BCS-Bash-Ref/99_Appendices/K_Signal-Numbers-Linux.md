<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix K — Signal Numbers (Linux)

Standard signals on Linux x86-64. Use `kill -l` for the authoritative local list.

| # | Name | Default action |
|---|------|----------------|
| 1 | HUP | Terminate |
| 2 | INT | Terminate |
| 3 | QUIT | Core dump |
| 4 | ILL | Core dump |
| 5 | TRAP | Core dump |
| 6 | ABRT | Core dump |
| 7 | BUS | Core dump |
| 8 | FPE | Core dump |
| 9 | KILL | Terminate (uncatchable) |
| 10 | USR1 | Terminate |
| 11 | SEGV | Core dump |
| 12 | USR2 | Terminate |
| 13 | PIPE | Terminate |
| 14 | ALRM | Terminate |
| 15 | TERM | Terminate |
| 16 | STKFLT | Terminate |
| 17 | CHLD | Ignore |
| 18 | CONT | Continue |
| 19 | STOP | Stop (uncatchable) |
| 20 | TSTP | Stop |
| 21 | TTIN | Stop |
| 22 | TTOU | Stop |
| 23 | URG | Ignore |
| 24 | XCPU | Core dump |
| 25 | XFSZ | Core dump |
| 26 | VTALRM | Terminate |
| 27 | PROF | Terminate |
| 28 | WINCH | Ignore |
| 29 | IO/POLL | Terminate |
| 30 | PWR | Terminate |
| 31 | SYS | Core dump |
| 34–64 | RTMIN..RTMAX | Terminate |

#fin
