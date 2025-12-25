### TUI Basics

**Rule:** Create TUI elements (spinners, progress bars, menus) with terminal detection and proper cursor cleanup.

**Rationale:** Visual feedback improves UX; terminal check prevents garbage output in pipes/redirects.

**Progress Spinner:**
```bash
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while :; do
    printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"
    i+=1; sleep 0.1
  done
}
spinner 'Working...' &; pid=$!
# work...; kill "$pid" 2>/dev/null; printf '\r\033[K'
```

**Cursor Control:**
```bash
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
trap 'show_cursor' EXIT  # Always restore
```

**Anti-Pattern:**
```bash
# ✗ TUI without terminal check �' garbage in pipes
progress_bar 50 100
# ✓ Check terminal first
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

**Ref:** BCS0707
