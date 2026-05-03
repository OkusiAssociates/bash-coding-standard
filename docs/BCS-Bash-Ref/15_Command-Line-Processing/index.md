<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XV — Command-Line Processing

*Parsing command-line arguments is the most-reused piece of code in Bash scripts. This Part documents the conventions and the canonical patterns: getopts, hand-rolled parsing, GNU getopt, and subcommand dispatch.*

---

## Chapters

1. [15.1 CLI conventions](01_CLI-conventions.md) — Conventions for command-line interfaces that bash scripts should follow.
2. [15.2 `getopts` builtin](02_getopts-builtin.md) — POSIX shell builtin for short-option parsing.
3. [15.3 GNU `getopt(1)` external](03_GNU-getopt1-external.md) — The external GNU `getopt` parses both short and long options.
4. [15.4 Hand-rolled `while case shift`](04_Hand-rolled-while-case-shift.md) — The BCS canonical pattern.
5. [15.5 Long options](05_Long-options.md) — Two equivalent forms.
6. [15.6 Bundled short options](06_Bundled-short-options.md) — Combining multiple short flags into one argument.
7. [15.7 `--` end-of-options](07_end-of-options.md) — Standard convention for ending option processing.
8. [15.8 Subcommand dispatch](08_Subcommand-dispatch.md) — Multi-command CLIs (like `git`) dispatch a subcommand to a handler function.
9. [15.9 Help text conventions](09_Help-text-conventions.md) — Conventions for `--help` output.
10. [15.10 Synopsis grammar](10_Synopsis-grammar.md) — Notation for documenting CLI syntax.
11. [15.11 Auto-generating usage](11_Auto-generating-usage.md) — Maintaining usage in sync with parser.

---

← Previous: [Part XIV — Input, Output, and Messaging](../14_Input-Output-and-Messaging/index.md)

Next: [Part XVI — Concurrency and Parallelism](../16_Concurrency-and-Parallelism/index.md) →

#fin
