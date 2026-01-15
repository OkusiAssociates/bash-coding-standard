### Terminal Capabilities

**Detect terminal features with `[[ -t 1 ]]` before using colors/cursor control; provide fallbacks for pipes/redirects.**

#### Key Points
- Prevents garbage output in non-terminal contexts
- Enables graceful degradation for limited terminals
- Use `tput` for portable capability queries

#### Terminal Detection

```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -r RED='' NC=''
fi

# Terminal size with fallback
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
trap 'TERM_COLS=$(tput cols 2>/dev/null || echo 80)' WINCH
```

#### Anti-Patterns

```bash
# âœ— Assuming terminal support
echo -e '\033[31mError\033[0m'  # â†' garbage in pipes

# âœ“ Conditional output
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'

# âœ— Hardcoded width â†' use ${TERM_COLS:-80}
```

**See Also:** BCS0907, BCS0906

**Ref:** BCS0708
