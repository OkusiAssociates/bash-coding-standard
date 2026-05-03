<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.4 Function storage

Functions are stored similarly to variables, in their own table.

- One global function table; no scoped tables.
- A function defined inside a function is still global.
- `unset -f` removes by name.
- `declare -f` lists with bodies.
- Source location tracked when `extdebug` is enabled.

#fin
