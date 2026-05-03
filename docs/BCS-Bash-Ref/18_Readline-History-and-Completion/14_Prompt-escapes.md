<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.14 Prompt escapes

Special sequences expanded in prompts.

- `\u` — username.
- `\h` — hostname (short).
- `\H` — hostname (FQDN).
- `\w` — current working directory.
- `\W` — basename of CWD.
- `\$` — `#` if root, `$` otherwise.
- `\!` — history number.
- `\#` — command number.
- `\d` — date.
- `\t`, `\T`, `\@`, `\A` — time formats.
- `\e` — escape (for ANSI colours).
- `\[…\]` — non-printing sequence (essential for colour to avoid line-wrap miscalculation).
- `\j` — number of jobs.
- `\l` — basename of terminal device.

#fin
