<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.12 `COMPREPLY` and `COMP_*` variables

The completion environment.

- `COMPREPLY` — array; each element is a candidate completion.
- `COMP_WORDS` — array of words on the current command line.
- `COMP_CWORD` — index into COMP_WORDS of the current word being completed.
- `COMP_LINE` — full current command line.
- `COMP_POINT` — cursor position within COMP_LINE.
- `COMP_TYPE` — completion-type indicator (TAB, ?, !, @, %).
- `COMP_KEY` — key that triggered completion.
- `COMP_WORDBREAKS` — characters that break words for completion (default `' \t\n"\''><=;|&(:'`).

#fin
