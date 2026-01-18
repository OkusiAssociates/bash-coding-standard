### TUI Basics

**Rule: BCS0707**

**TUI elements require terminal detection (`[[ -t 1 ]]`) before rendering visual output.**

#### Key Patterns

- **Spinner**: Background process with `kill` cleanup
- **Progress bar**: `\r` carriage return for in-place updates
- **Cursor control**: ANSI escapes (`\033[?25l` hide, `\033[?25h` show)
- **Always trap**: `trap 'show_cursor' EXIT` to restore cursor

#### Progress Bar

```bash
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' $((width - filled)) '' | tr ' ' '░')
  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}
```

#### Anti-Pattern

```bash
# ✗ TUI without terminal check → garbage output
progress_bar 50 100

# ✓ Check terminal first
[[ -t 1 ]] && progress_bar 50 100 || echo '50%'
```

**See Also:** BCS0708, BCS0701

**Ref:** BCS0707
