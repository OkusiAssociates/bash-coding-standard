<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVIII — Readline, History, and Completion

*Bash's interactive layer. This Part is irrelevant for batch scripts but central to writing tools your team will use day-to-day.*

---

## Chapters

1. [18.1 Readline overview](01_Readline-overview.md) — The GNU Readline library handles line editing in interactive bash.
2. [18.2 Editing modes](02_Editing-modes.md) — Two key-binding regimes.
3. [18.3 Key bindings](03_Key-bindings.md) — `bind` builtin and `~/.inputrc` configure key bindings.
4. [18.4 Bindable functions](04_Bindable-functions.md) — Readline's full function catalogue.
5. [18.5 History](05_History.md) — Bash maintains a history of commands.
6. [18.6 The `history` builtin](06_The-history-builtin.md) — Manipulate the history list.
7. [18.7 History expansion](07_History-expansion.md) — `!` introduces history references on the command line.
8. [18.8 Programmable completion](08_Programmable-completion.md) — Bash can complete arbitrary commands using user-defined functions.
9. [18.9 Compspec actions](09_Compspec-actions.md) — Built-in completion sources.
10. [18.10 `_init_completion`](10__init_completion.md) — Helper from `bash-completion` for the standard completion boilerplate.
11. [18.11 Dynamic completion functions](11_Dynamic-completion-functions.md) — Patterns for writing completion functions.
12. [18.12 `COMPREPLY` and `COMP_*` variables](12_COMPREPLY-and-COMP_-variables.md) — The completion environment.
13. [18.13 Prompts](13_Prompts.md) — Bash uses several prompt variables for different contexts.
14. [18.14 Prompt escapes](14_Prompt-escapes.md) — Special sequences expanded in prompts.
15. [18.15 Coloured and multi-line prompts](15_Coloured-and-multi-line-prompts.md) — Practical prompt customisation.
16. [18.16 Terminal capability detection](16_Terminal-capability-detection.md) — Determining what the terminal supports.

---

← Previous: [Part XVII — Coprocesses and IPC](../17_Coprocesses-and-IPC/index.md)

Next: [Part XIX — Performance](../19_Performance/index.md) →

#fin
