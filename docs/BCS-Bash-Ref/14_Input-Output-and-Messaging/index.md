<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIV — Input, Output, and Messaging

*Bash's I/O builtins (`read`, `printf`, `mapfile`) and the disciplines around them. The cardinal rule: stdout is data, stderr is diagnostics; never mix them.*

---

## Chapters

1. [14.1 Standard streams discipline](01_Standard-streams-discipline.md) — The convention that distinguishes a composable script from a broken one.
2. [14.2 The `read` builtin](02_The-read-builtin.md) — Read input from stdin (or a specified fd) into one or more variables.
3. [14.3 `mapfile` / `readarray`](03_mapfile-readarray.md) — Read all of stdin (or fd) into an array, one line per element.
4. [14.4 The `printf` builtin](04_The-printf-builtin.md) — Formatted output.
5. [14.5 `printf` vs `echo`](05_printf-vs-echo.md) — `echo` is unsafe in scripts.
6. [14.6 Format specifiers](06_Format-specifiers.md) — Detailed reference.
7. [14.7 Logging discipline](07_Logging-discipline.md) — Conventions for diagnostic output.
8. [14.8 Log levels](08_Log-levels.md) — Standard severity hierarchy.
9. [14.9 Coloured output and TERM detection](09_Coloured-output-and-TERM-detection.md) — Coloured terminals improve readability; piped or non-TTY targets should not see escape codes.
10. [14.10 Progress indicators](10_Progress-indicators.md) — Long-running tasks benefit from progress feedback.
11. [14.11 Reading binary data](11_Reading-binary-data.md) — Bash is byte-oriented but treats NUL specially.
12. [14.12 File locking for concurrent writes](12_File-locking-for-concurrent-writes.md) — Multiple processes writing to the same file: lock or interleave.

---

← Previous: [Part XIII — Error Handling and Exit Status](../13_Error-Handling-and-Exit-Status/index.md)

Next: [Part XV — Command-Line Processing](../15_Command-Line-Processing/index.md) →

#fin
