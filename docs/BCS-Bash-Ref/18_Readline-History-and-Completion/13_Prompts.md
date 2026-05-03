<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.13 Prompts

Bash uses several prompt variables for different contexts.

- `PS0` — printed after reading a command, before executing (Bash 4.4+).
- `PS1` — primary prompt (interactive).
- `PS2` — continuation prompt (multi-line input).
- `PS3` — `select` menu prompt.
- `PS4` — `set -x` trace prefix.
- Default `PS1`: `\u@\h:\w\$`.
- Default `PS4`: `+ `.

#fin
