<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.2 The bashisms list

Specific constructs that fail in `dash` / POSIX `sh`.

- `[[ ]]` — sh has only `[ ]`.
- `local` — sh has no scoping.
- Arrays — sh has none.
- `function` keyword — sh requires `name()`.
- `$'...'` — sh has only `'…'`.
- `<<<` — sh has only `<<`.
- `read -r ARRAY` — sh has no array.
- `==` in `[[`/`[` — sh prefers `=`.
- `&>` — sh requires `>file 2>&1`.
- `pipefail` — sh has none (POSIX 2024 adds it).
- `checkbashisms` tool from `devscripts` — Debian's auditor.

#fin
