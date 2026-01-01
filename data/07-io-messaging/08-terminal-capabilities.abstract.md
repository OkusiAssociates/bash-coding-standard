### Terminal Capabilities

**Detect terminal features before using; provide graceful fallbacks for pipes/redirects.**

#### Why
- Prevents garbage output in non-TTY contexts
- Enables rich output when available
- Ensures cross-environment compatibility

#### Core Patterns

```bash
# TTY detection with color fallback
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with WINCH trap
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
trap 'TERM_COLS=$(tput cols 2>/dev/null || echo 80)' WINCH

# Unicode check
[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
```

#### ANSI Quick Reference

| Type | Codes |
|------|-------|
| Colors | `\033[31m` (red) `\033[32m` (green) `\033[0m` (reset) |
| Styles | `\033[1m` (bold) `\033[2m` (dim) `\033[4m` (underline) |
| Cursor | `\033[?25l` (hide) `\033[?25h` (show) |

#### Anti-Patterns

```bash
# ✗ Assumes terminal support
echo -e '\033[31mError\033[0m'

# ✓ Conditional on TTY
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# ✗ Hardcoded width �' ✓ Use ${TERM_COLS:-80}
```

**Ref:** BCS0708
