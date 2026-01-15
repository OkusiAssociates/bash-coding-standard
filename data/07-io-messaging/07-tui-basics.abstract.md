### TUI Basics

**Use terminal check `[[ -t 1 ]]` before TUI output; restore cursor on exit.**

#### Key Patterns

- **Spinner**: Background process with `kill`/cleanup
- **Progress bar**: `printf '\r[...]'` with `%*s | tr ' ' '█'`
- **Cursor**: Hide `\033[?25l`, show `\033[?25h`, trap EXIT
- **Clear**: Line `\033[2K\r`, screen `\033[2J\033[H`

#### Rationale

- Visual feedback for long operations
- Interactive menus improve UX

#### Example

```bash
# Progress bar with terminal check
progress_bar() {
  local -i cur=$1 tot=$2 w=50 f=$((cur*w/tot))
  printf '\r[%s%s] %3d%%' \
    "$(printf '%*s' "$f" ''|tr ' ' '█')" \
    "$(printf '%*s' $((w-f)) ''|tr ' ' '░')" \
    $((cur*100/tot))
}
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

#### Anti-Pattern

`progress_bar 50 100` without `[[ -t 1 ]]` �' garbage output to non-terminal

**Ref:** BCS0707
