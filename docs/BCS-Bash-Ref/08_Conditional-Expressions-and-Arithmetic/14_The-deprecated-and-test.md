<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.14 The deprecated `[ ]` and `test`

POSIX `test` builtin and its `[ ]` synonym. Used by sh and by historical bash code; not used in modern Bash scripts.

- `[` is a builtin command requiring matching `]` as last argument.
- Field-splits its operands — must quote: `[ -f "$file" ]`.
- No regex, no `&&`/`||` (only `-a`, `-o` which are dangerous).
- No `=~`.
- Always use `[[ ]]` instead.
- Documented here only because the reader will encounter it in legacy code.

#fin
