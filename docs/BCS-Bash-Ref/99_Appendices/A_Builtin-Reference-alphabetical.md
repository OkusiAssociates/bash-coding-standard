<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix A — Builtin Reference (alphabetical)

Every builtin in alphabetical order, with one-line description and option summary. Cross-referenced to the relevant chapter.

- `:` — null command (§7.14).
- `.`, `source` — execute file in current shell (§10.1).
- `alias`, `unalias` — define/remove command aliases.
- `bg`, `fg`, `jobs` — job control (§11.9).
- `bind` — readline key binding (§18.3).
- `break`, `continue` — loop control (§7.11).
- `builtin` — invoke a builtin even if shadowed.
- `caller` — call-stack frame (§9.11).
- `cd` — change directory.
- `command` — invoke a command bypassing functions and aliases.
- `compgen`, `complete`, `compopt` — programmable completion (§18.8).
- `coproc` — start a coprocess (§17.1).
- `declare`, `typeset` — variable declaration with attributes (§4.5).
- `dirs`, `pushd`, `popd` — directory stack.
- `disown` — remove from job table (§11.9).
- `echo` — print arguments (avoid; use `printf`, §14.5).
- `enable` — enable/disable builtins.
- `eval` — re-evaluate as shell input (§20.4).
- `exec` — replace shell or modify fds (§6.12).
- `exit` — terminate shell (§7.13).
- `export` — mark variable for export (§4.8).
- `false` — return failure (§7.14).
- `getopts` — POSIX option parser (§15.2).
- `hash` — command path memoisation.
- `help` — built-in help.
- `history` — history operations (§18.6).
- `kill` — send signal (§11.10).
- `let` — arithmetic evaluation (§8.13).
- `local` — declare function-local variable (§4.6).
- `logout` — exit a login shell.
- `mapfile`, `readarray` — read into array (§14.3).
- `printf` — formatted output (§14.4).
- `pwd` — print working directory.
- `read` — read input (§14.2).
- `readonly` — mark variable readonly (§4.7).
- `return` — return from function or sourced script (§7.12).
- `select` — interactive menu (§7.7).
- `set` — set shell options (Appendix D).
- `shift` — shift positional parameters.
- `shopt` — shell option (Appendix E).
- `suspend` — suspend the shell.
- `test`, `[` — POSIX conditional (§8.14, deprecated).
- `times` — print accumulated CPU times.
- `trap` — register signal handler (§12.5).
- `true` — return success (§7.14).
- `type` — show command type.
- `ulimit` — resource limits.
- `umask` — file-creation mode mask.
- `unset` — remove variable or function (§4.14).
- `wait` — wait for child completion (§16.2).

#fin
