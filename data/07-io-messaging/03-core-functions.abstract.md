## Core Message Functions

**Use private `_msg()` with `FUNCNAME[1]` inspection to auto-format messages; wrapper functions control verbosity and stream routing.**

### Rationale
- `FUNCNAME` auto-detects caller â†' single DRY implementation
- Conditional output via `VERBOSE`/`DEBUG` flags
- Proper streams: errorsâ†'stderr, dataâ†'stdout (enables `data=$(./script)`)

### Core Pattern
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}âœ“${NC}" ;;
    warn)    prefix+=" ${YELLOW}â–²${NC}" ;;
    info)    prefix+=" ${CYAN}â—‰${NC}" ;;
    error)   prefix+=" ${RED}âœ—${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Wrappers
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### File Logging
```bash
# Use printf builtin (10-50x faster than $(date))
log_msg() { printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG_FILE"; }
```

### Anti-Patterns
- `echo "Error: ..."` â†' no stderr, no prefix, no color
- `$(date ...)` in log â†' subshell per call; use `printf '%()T'`
- `die() { error "$@"; exit 1; }` â†' no exit code param

**Ref:** BCS0703
