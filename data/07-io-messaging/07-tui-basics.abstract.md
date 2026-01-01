### TUI Basics

**Build terminal UI elements: spinners, progress bars, menus—always with terminal detection.**

#### Core Patterns

**Spinner:** Background process with `kill "$pid"` cleanup:
```bash
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while :; do printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"; i+=1; sleep 0.1; done
}
spinner 'Working...' & spinner_pid=$!
```

**Progress bar:** `printf '\r[%s] %3d%%' "$bar" $((cur*100/total))`

**Cursor:** `hide_cursor() { printf '\033[?25l'; }` �' trap restore on EXIT

**Menu:** Arrow keys via escape sequences `$'\x1b'[A/B`, return selection as `$?`

#### Critical Rule

**Always check `[[ -t 1 ]]`** before TUI output �' fall back to plain text for non-terminals.

```bash
# ✗ progress_bar 50 100  # Garbage if piped
# ✓ [[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

**Ref:** BCS0707
