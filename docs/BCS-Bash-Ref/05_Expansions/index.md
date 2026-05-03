<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part V — Expansions

*Bash performs eight expansions in a fixed order on every command line. Most "Stack Overflow Bash bugs" trace to a misunderstanding of which expansion runs when, on what, and producing what. This Part documents each expansion, the order, and the rules.*

---

## Chapters

1. [5.1 Order of expansions](01_Order-of-expansions.md) — The canonical sequence of operations bash performs between reading a command and executing it.
2. [5.2 Brace expansion](02_Brace-expansion.md) — Generates arbitrary strings from a brace pattern.
3. [5.3 Tilde expansion](03_Tilde-expansion.md) — Expands `~` and `~user` to home directories.
4. [5.4 Parameter and variable expansion](04_Parameter-and-variable-expansion.md) — The richest expansion in bash.
5. [5.5 Arithmetic expansion](05_Arithmetic-expansion.md) — `$(( expr ))` evaluates `expr` as an arithmetic expression and substitutes the result.
6. [5.6 Command substitution](06_Command-substitution.md) — Replaces the construct with the standard output of the executed command, stripped of trailing newlines.
7. [5.7 Process substitution](07_Process-substitution.md) — Replaces the construct with a `/dev/fd/N` path connected to the stdin or stdout of the substituted command.
8. [5.8 Word splitting and IFS](08_Word-splitting-and-IFS.md) — After parameter, command, and arithmetic expansion, the unquoted results are split into words on the characters in `IFS`.
9. [5.9 Pathname expansion (globbing)](09_Pathname-expansion-globbing.md) — After word splitting, each word containing unquoted glob metacharacters is treated as a pattern and matched against filenames.
10. [5.10 Quote removal](10_Quote-removal.md) — The implicit final step.
11. [5.11 Glob options](11_Glob-options.md) — Behavioural toggles via `shopt`.
12. [5.12 Extended globs (extglob)](12_Extended-globs-extglob.md) — When `shopt -s extglob` is set, additional pattern operators are available.
13. [5.13 Locale and pattern matching](13_Locale-and-pattern-matching.md) — Locale settings affect glob matching, regex matching, and `[[ ]]` comparisons.

---

← Previous: [Part IV — Parameters, Variables, and Arrays](../04_Parameters-Variables-and-Arrays/index.md)

Next: [Part VI — Redirection and Pipelines](../06_Redirection-and-Pipelines/index.md) →

#fin
