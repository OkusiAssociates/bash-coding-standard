<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.8 Job specifications

Jobs can be referenced by several syntaxes.

- `%N` — job number N.
- `%+` or `%%` — current job (most recent).
- `%-` — previous job.
- `%cmd` — job whose command starts with `cmd`.
- `%?str` — job whose command contains `str`.
- Used with `fg`, `bg`, `kill`, `wait`, `disown`.

#fin
