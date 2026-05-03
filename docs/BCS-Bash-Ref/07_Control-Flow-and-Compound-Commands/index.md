<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VII — Control Flow and Compound Commands

*The compositional layer of bash: how to assemble simple commands into conditional, iterative, and grouped structures. This Part documents every compound command form.*

---

## Chapters

1. [7.1 Compound command overview](01_Compound-command-overview.md) — A compound command is one of seven forms: brace group, subshell, `if`, `case`, `while`, `until`, `for`, `select`, `(( ))`, `[[ ]]`.
2. [7.2 `if`/`elif`/`else`/`fi`](02_ifelifelsefi.md) — The conditional.
3. [7.3 `case`/`esac`](03_caseesac.md) — Pattern-based dispatch.
4. [7.4 `for x in list`](04_for-x-in-list.md) — Iterate over an explicit list.
5. [7.5 C-style `for ((;;))`](05_C-style-for.md) — C-style numeric loop with arithmetic context.
6. [7.6 `while`/`until`](06_whileuntil.md) — Looping on a condition.
7. [7.7 `select`](07_select.md) — Generate a numbered menu and read a choice.
8. [7.8 Subshell grouping `( )`](08_Subshell-grouping.md) — Run a list in a subshell.
9. [7.9 Brace grouping `{ }`](09_Brace-grouping.md) — Run a list in the current shell.
10. [7.10 `&&` and `||` short-circuits](10_and-short-circuits.md) — AND-OR lists chain commands with conditional execution.
11. [7.11 `break` and `continue`](11_break-and-continue.md) — Loop control.
12. [7.12 `return`](12_return.md) — Return from a function with a status code.
13. [7.13 `exit`](13_exit.md) — Terminate the shell.
14. [7.14 `:`, `true`, `false`](14_true-false.md) — Three commands that exist primarily to satisfy syntax requirements.

---

← Previous: [Part VI — Redirection and Pipelines](../06_Redirection-and-Pipelines/index.md)

Next: [Part VIII — Conditional Expressions and Arithmetic](../08_Conditional-Expressions-and-Arithmetic/index.md) →

#fin
