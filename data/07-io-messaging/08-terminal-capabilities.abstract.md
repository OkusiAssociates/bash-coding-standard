### Terminal Capabilities

**Detect terminal features before using colors/cursor control; provide fallbacks for pipes/redirects.**

#### Rationale
- Prevents garbage output in non-terminal contexts (pipes, cron, logs)
- Enables graceful degradation across environments

#### Core Pattern

```bash
# Check if stdout is terminal
if [[ -t 1 ]]; then
  declare -- RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -- RED='' NC=''
fi

# Terminal size with fallback
TERM_COLS=$(tput cols 2>/dev/null || echo 80)
```

#### Key Techniques
- `[[ -t 1 ]]` â†' stdout is terminal; `[[ -t 2 ]]` â†' stderr is terminal
- `tput cols/lines` â†' dimensions with 80x24 fallback
- `trap 'get_terminal_size' WINCH` â†' auto-update on resize
- Unicode check: `[[ "${LANG:-}" == *UTF-8* ]]`

#### Anti-Patterns

```bash
# âœ— Assumes terminal
echo -e '\033[31mError\033[0m'

# âœ“ Conditional
[[ -t 1 ]] && echo -e '\033[31mError\033[0m' || echo 'Error'
```

```bash
# âœ— Hardcoded width
printf '%-80s\n' "$text"

# âœ“ Dynamic width
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

**Ref:** BCS0908
