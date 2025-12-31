### TUI Basics

**Rule: BCS0907**

Creating text-based user interface elements in terminal scripts.

---

#### Rationale

TUI elements provide:
- Visual feedback for long-running operations
- Interactive prompts and menus
- Progress indication
- Better user experience

---

#### Progress Indicators

```bash
# Simple spinner
spinner() {
  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i i=0
  while :; do
    printf '\r%s %s' "${frames[i % ${#frames[@]}]}" "$*"
    i+=1
    sleep 0.1
  done
}

# Start spinner in background
spinner 'Processing...' &
spinner_pid=$!

# Do work...
long_operation

# Stop spinner
kill "$spinner_pid" 2>/dev/null
printf '\r\033[K'  # Clear line
```

#### Progress Bar

```bash
progress_bar() {
  local -i current=$1 total=$2 width=${3:-50}
  local -i filled=$((current * width / total))
  local -i empty=$((width - filled))
  local -- bar

  bar=$(printf '%*s' "$filled" '' | tr ' ' '█')
  bar+=$(printf '%*s' "$empty" '' | tr ' ' '░')

  printf '\r[%s] %3d%%' "$bar" $((current * 100 / total))
}

# Usage
declare -i i
for ((i=1; i<=100; i+=1)); do
  progress_bar "$i" 100
  sleep 0.05
done
echo
```

#### Cursor Control

```bash
# Hide/show cursor
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
trap 'show_cursor' EXIT

# Move cursor
move_up() { printf '\033[%dA' "${1:-1}"; }
move_down() { printf '\033[%dB' "${1:-1}"; }
move_to() { printf '\033[%d;%dH' "$1" "$2"; }

# Clear operations
clear_line() { printf '\033[2K\r'; }
clear_screen() { printf '\033[2J\033[H'; }
clear_to_end() { printf '\033[J'; }
```

#### Interactive Menu

```bash
select_option() {
  local -a options=("$@")
  local -i selected=0
  local -- key

  hide_cursor
  trap 'show_cursor' RETURN

  while ((1)); do
    # Display menu
    local -i i
    for ((i=0; i<${#options[@]}; i+=1)); do
      if ((i == selected)); then
        printf '  \033[7m %s \033[0m\n' "${options[i]}"
      else
        printf '   %s\n' "${options[i]}"
      fi
    done

    # Read keypress
    IFS= read -rsn1 key
    case $key in
      $'\x1b')  # Escape sequence
        read -rsn2 key
        case "$key" in
          '[A') ((selected > 0)) && ((selected-=1)) ;;  # Up
          '[B') ((selected < ${#options[@]}-1)) && ((selected+=1)) ;;  # Down
        esac
        ;;
      '') break ;;  # Enter
    esac

    # Move cursor back up
    printf '\033[%dA' "${#options[@]}"
  done

  show_cursor
  return "$selected"
}

# Usage
select_option 'Option 1' 'Option 2' 'Option 3'
selected=$?
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - TUI without terminal check
progress_bar 50 100  # Garbage if not a terminal

# ✓ Correct - check for terminal
if [[ -t 1 ]]; then
  progress_bar 50 100
else
  echo '50% complete'
fi
```

---

**See Also:** BCS0908 (Terminal Capabilities), BCS0701 (Color Support)

#fin
