<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.16 Terminal capability detection

Determining what the terminal supports.

- `tput colors` — number of colours.
- `tput cols`, `tput lines` — dimensions.
- `tput setaf N`, `tput setab N` — set foreground/background colour.
- `tput bold`, `tput sgr0` — bold, reset.
- `infocmp` — full terminfo entry.
- `$TERM` — terminal type (xterm, screen, tmux, dumb).
- `$COLORTERM` — modern: `truecolor` or `24bit` for 24-bit colour support.
- Always test before emitting colour: avoid breaking dumb terminals or pipes (BCS0708).

```bash
# scenario: colour only when stdout is a TTY with ≥8 colours
if [[ -t 1 && "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  declare -r RED=$'\033[31m' GREEN=$'\033[32m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' NC=''
fi
printf '%sok%s\n' "$GREEN" "$NC"
```

The `[[ -t 1 ]]` guard rejects pipes and redirections; the `tput colors`
check rejects `TERM=dumb`; the `2>/dev/null || echo 0` defends against
missing terminfo entries. This is the canonical BCS0706/BCS0708 pattern —
all messaging in this reference assumes the same gate.

**See also**: §18.13 (prompts), §18.15 (coloured prompts), §14 (messaging).

#fin
