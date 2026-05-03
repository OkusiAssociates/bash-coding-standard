<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.1 Bash vs POSIX sh

The features bash adds beyond POSIX 1003.2 / SUSv4.

- Arrays (indexed and associative).
- `[[ ]]` conditional command.
- `(( ))` arithmetic command.
- `=~` regex.
- `$(< file)` (not POSIX; `cat <file` is).
- `let` builtin.
- `local` (POSIX has no scoping).
- `declare` / `typeset` and attributes.
- `mapfile` / `readarray`.
- Process substitution `<(…)`, `>(…)`.
- Brace expansion `{1..10}`.
- `**` globstar.
- `+=` operator.
- `${var//pat/repl}` and other expansions beyond POSIX.
- ANSI-C `$'...'` quoting.

#fin
