### Terminal Capabilities

**Rule:** Detect terminal features with `[[ -t 1 ]]` before using colors/cursor control; provide graceful fallbacks.

**Why:** Prevents garbage output in pipes/redirects; ensures portability across environments.

#### Core Pattern

```bash
if [[ -t 1 ]]; then
  declare -r RED=$'\033[31m' NC=$'\033[0m'
  TERM_COLS=$(tput cols 2>/dev/null || echo 80)
else
  declare -r RED='' NC=''
  TERM_COLS=80
fi
```

#### Capabilities

- **Size:** `tput cols`/`tput lines` with 80/24 defaults; trap WINCH for resize
- **Colors:** `tput colors` → check `>=256` for extended palette
- **Unicode:** `[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]`

#### Anti-Patterns

`echo -e '\033[31mError\033[0m'` without TTY check → garbage in pipes
`printf '%-80s\n'` hardcoded → use `${TERM_COLS:-80}`

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708
