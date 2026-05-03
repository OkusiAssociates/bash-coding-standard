<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix L — Exit Code Conventions

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error |
| 3 | File not found |
| 5 | I/O error |
| 13 | Permission denied |
| 18 | Missing dependency |
| 22 | Invalid argument |
| 24 | Timeout |
| 64–113 | sysexits.h |
| 126 | Found but not executable |
| 127 | Command not found |
| 128 + N | Killed by signal N |

`sysexits.h`: 64=USAGE, 65=DATAERR, 66=NOINPUT, 67=NOUSER, 68=NOHOST, 69=UNAVAILABLE, 70=SOFTWARE, 71=OSERR, 72=OSFILE, 73=CANTCREAT, 74=IOERR, 75=TEMPFAIL, 76=PROTOCOL, 77=NOPERM, 78=CONFIG.

#fin
