<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VI — Redirection and Pipelines

*Redirection is fd manipulation by another name. Every operator resolves to a small sequence of `dup2()` and `open()` syscalls. This Part documents the operators, the ordering rules, and the pipeline mechanism that composes them.*

---

## Chapters

1. [6.1 The fd table from Bash's perspective](01_The-fd-table-from-Bashs-perspective.md) — Recap from §1.2 framed as Bash sees it.
2. [6.2 Input redirection](02_Input-redirection.md) — Reading from a file or fd.
3. [6.3 Output redirection](03_Output-redirection.md) — Writing to a file or fd.
4. [6.4 Stderr redirection and merging](04_Stderr-redirection-and-merging.md) — Bash's two shorthands and the underlying explicit forms for combining stdout and stderr.
5. [6.5 Reading-and-writing](05_Reading-and-writing.md) — `<>` opens a file for both reading and writing on the same fd.
6. [6.6 Duplicating fds](06_Duplicating-fds.md) — `>&` and `<&` duplicate fds, sharing the underlying open file description.
7. [6.7 Moving and closing fds](07_Moving-and-closing-fds.md) — The `>&-`/`<&-` close form, and the dup-and-close form `n>&m-`.
8. [6.8 Here-documents](08_Here-documents.md) — `<<DELIM` … `DELIM` — synthesise stdin from inline text.
9. [6.9 Here-strings](09_Here-strings.md) — `<<<` — single-line variant of here-document; supplies a string as stdin.
10. [6.10 Process substitution as redirection](10_Process-substitution-as-redirection.md) — Process substitution (§5.7) is a redirection mechanism in disguise — `<(cmd)` produces a `/dev/fd/N` path that bash can pass as a filename.
11. [6.11 Order of evaluation](11_Order-of-evaluation.md) — Redirections are processed left-to-right.
12. [6.12 `exec` for fd manipulation](12_exec-for-fd-manipulation.md) — `exec` without a command applies redirections to the current shell, persisting beyond a single command.
13. [6.13 Pipelines](13_Pipelines.md) — `a | b` connects a's stdout to b's stdin via a kernel pipe.
14. [6.14 Stderr pipelines (`|&`)](14_Stderr-pipelines.md) — `a |& b` is shorthand for `a 2>&1 | b` — pipe both stdout and stderr.
15. [6.15 `pipefail` semantics](15_pipefail-semantics.md) — `set -o pipefail` makes a pipeline's exit status the rightmost non-zero status, or zero if all succeeded.
16. [6.16 `lastpipe` semantics](16_lastpipe-semantics.md) — `shopt -s lastpipe` runs the last command of a pipeline in the current shell rather than a subshell — making variables set in it visible afterwards.

---

← Previous: [Part V — Expansions](../05_Expansions/index.md)

Next: [Part VII — Control Flow and Compound Commands](../07_Control-Flow-and-Compound-Commands/index.md) →

#fin
