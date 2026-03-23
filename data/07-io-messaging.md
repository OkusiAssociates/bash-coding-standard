# Section 7: I/O & Messaging

## BCS0700 Section Overview

All status messages go to stderr. Only data output goes to stdout. This separation enables script composition and piping.

## BCS0701 Message Control Flags

Declare message control flags as integers at script start.

```bash
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
```

## BCS0702 STDOUT vs STDERR Separation

```bash
# correct — status to stderr, data to stdout
info 'Processing files...'           # → stderr (via messaging function)
echo "$result"                       # → stdout (data output)
printf '%s\n' "$result"              # → stdout (data output)

# correct — place >&2 at the BEGINNING
>&2 echo 'error: something failed'
>&2 printf '%s\n' 'error: something failed'

# wrong — >&2 at end (works but harder to spot)
echo 'error: something failed' >&2
printf '%s\n' 'error: something failed' >&2
```

Stream separation enables: `data=$(./script.sh)` captures only data, `./script.sh 2>errors.log` separates errors, `./script.sh | process` pipes data while showing messages.

## BCS0703 Core Message Functions

Implement `_msg()` as the core function using `FUNCNAME[1]` dispatch.

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" DEBUG:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

vecho()   { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn()    { >&2 _msg "$@"; }
info()    { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error()   { >&2 _msg "$@"; }
debug()   { ((DEBUG)) || return 0; >&2 _msg "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

Rules:
- `error()` must be unconditional — always outputs to stderr
- `warn()` should be unconditional (warnings are important)
- `info()`, `success()`, `vecho()` respect VERBOSE flag
- `debug()` respects DEBUG flag
- `die()` takes exit code as first argument

## BCS0704 Usage Documentation

Structure help text with sections. Use heredoc with `cat`.

```bash
show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - a brief description of the script

Usage: $SCRIPT_NAME [OPTIONS] FILE [FILE ...]

A more detailed description of what the script does.

Options:
  -n, --dry-run           Dry run mode
  -v, --verbose           Verbose output (default)
  -q, --quiet             Quiet mode
  -V, --version           Show version
  -h, --help              Show this help

Examples:
  $SCRIPT_NAME file.txt
  $SCRIPT_NAME --dry-run *.csv
HELP
}
```

Never use messaging functions for help output. Help and version must always display regardless of VERBOSE setting.

## BCS0705 Echo vs Messaging Functions

```bash
# correct — messaging for status
info 'Validating environment...'
warn 'Deprecated option used'
error 'Connection failed'

# correct — echo for data and help
echo "$result"                       # data output
echo "$SCRIPT_NAME $VERSION"         # version output
# help text
cat <<HELP
...
HELP

# correct — functions returning data use echo
get_value() {
  echo "$result"                     # stdout for callers to capture
}

# wrong — mixing streams
info "$result"                       # data via messaging function
echo 'Processing...'                 # status via echo to stdout
```

Never mix data and status on the same stream.

## BCS0706 Color Definitions

Use a conditional block to define colors.

```bash
# correct — basic color set (5 variables)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

# extended set (add only when needed)
declare -r BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m'
declare -r BOLD=$'\033[1m' ITALIC=$'\033[3m'
declare -r UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m'
```

Never scatter inline color declarations across scripts. Centralize in a single declaration block.

## BCS0707 TUI Basics

Check for terminal before using TUI elements.

```bash
# correct
if [[ -t 1 ]]; then
  progress_bar 50 100
else
  echo '50% complete'
fi

# correct — hide cursor during TUI, restore on exit
printf '\033[?25l'                   # hide cursor
trap 'printf "\033[?25h"' EXIT       # restore on exit
```

## BCS0708 Terminal Capabilities

Get terminal dimensions dynamically.

```bash
# correct
trap 'get_terminal_size' WINCH
cols=$(tput cols 2>/dev/null || echo 80)

# correct — check Unicode support
[[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *UTF-8* ]]
```

Never hardcode terminal width. Provide graceful fallbacks for limited terminals.

## BCS0709 Yes/No Prompt

```bash
yn() {
  local -- REPLY
  read -r -n 1 -p "$(>&2 echo -n "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n ")"
  echo
  [[ ${REPLY,,} == y ]]
}

# usage
yn 'Deploy to production?' || die 0 'Cancelled'
```

## BCS0710 Standard Icons

| Icon | Purpose |
|------|---------|
| `◉` | Info |
| `⦿` | Debug |
| `▲` | Warning |
| `✓` | Success |
| `✗` | Error |
| `⚠` | Caution |

## BCS0711 Combined Redirection

Prefer `&>` and `&>>` over the verbose `>file 2>&1` and `>>file 2>&1` forms.

```bash
# correct — concise combined redirection
somecommand &>/dev/null
somecommand &>outfile
somecommand &>>logfile

# wrong — verbose combined redirection
somecommand >/dev/null 2>&1
somecommand >outfile 2>&1
somecommand >>logfile 2>&1
```

Use `2>/dev/null` or `2>file` when suppressing only stderr. The `&>` operator is for combined (stdout + stderr) redirection only.
