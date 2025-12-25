### Terminal Capabilities

**Rule: BCS0908**

Detecting and utilizing terminal features safely to ensure scripts work across all environments with graceful fallbacks.

---

#### Rationale

Terminal capability detection ensures scripts work in all environments (terminals, pipes, redirects) by providing graceful fallbacks for limited terminals while enabling rich output when available.

---

#### Terminal Detection

```bash
# Check if stdout is a terminal
if [[ -t 1 ]]; then
  # Terminal - can use colors, cursor control
  USE_COLORS=1
else
  # Pipe or redirect - plain output only
  USE_COLORS=0
fi

# Check both stdout and stderr
if [[ -t 1 && -t 2 ]]; then
  declare -- RED=$'\033[0;31m' NC=$'\033[0m'
else
  declare -- RED='' NC=''
fi
```

#### Terminal Size

```bash
# Get terminal dimensions
get_terminal_size() {
  if [[ -t 1 ]]; then
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
  else
    TERM_COLS=80
    TERM_ROWS=24
  fi
}

# Auto-update on resize
trap 'get_terminal_size' WINCH
get_terminal_size
```

#### Capability Checking

```bash
# Check for specific capability
has_capability() {
  local -- cap=$1
  tput "$cap" &>/dev/null
}

# Use with fallback
if has_capability colors; then
  num_colors=$(tput colors)
  ((num_colors >= 256)) && USE_256_COLORS=1
fi

# Check for Unicode support
has_unicode() {
  [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
}
```

#### Safe Output Functions

```bash
# Width-aware output
print_line() {
  local -i width=${TERM_COLS:-80}
  printf '%*s\n' "$width" '' | tr ' ' '─'
}

# Truncate to terminal width
truncate_string() {
  local -- str=$1
  local -i max=${2:-$TERM_COLS}

  if ((${#str} > max)); then
    echo "${str:0:$((max-3))}..."
  else
    echo "$str"
  fi
}

# Center text
center_text() {
  local -- text=$1
  local -i width=${TERM_COLS:-80}
  local -i padding=$(((width - ${#text}) / 2))

  printf '%*s%s\n' "$padding" '' "$text"
}
```

#### ANSI Code Reference

```bash
# Common ANSI escape codes
declare -r ESC=$'\033'

# Colors (foreground)
declare -r BLACK="${ESC}[30m"  RED="${ESC}[31m"
declare -r GREEN="${ESC}[32m"  YELLOW="${ESC}[33m"
declare -r BLUE="${ESC}[34m"   MAGENTA="${ESC}[35m"
declare -r CYAN="${ESC}[36m"   WHITE="${ESC}[37m"

# Styles
declare -r BOLD="${ESC}[1m"    DIM="${ESC}[2m"
declare -r ITALIC="${ESC}[3m"  UNDERLINE="${ESC}[4m"
declare -r BLINK="${ESC}[5m"   REVERSE="${ESC}[7m"

# Reset
declare -r NC="${ESC}[0m"

# Cursor
declare -r HIDE_CURSOR="${ESC}[?25l"
declare -r SHOW_CURSOR="${ESC}[?25h"
declare -r SAVE_CURSOR="${ESC}7"
declare -r RESTORE_CURSOR="${ESC}8"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - assuming terminal support
echo -e '\033[31mError\033[0m'  # May output garbage in pipes

# ✓ Correct - conditional output
if [[ -t 1 ]]; then
  echo -e '\033[31mError\033[0m'
else
  echo 'Error'
fi

# ✗ Wrong - hardcoded width
printf '%-80s\n' "$text"  # May wrap or truncate wrong

# ✓ Correct - use terminal width
printf '%-*s\n' "${TERM_COLS:-80}" "$text"
```

---

**See Also:** BCS0907 (TUI Basics), BCS0906 (Color Management)

#fin
