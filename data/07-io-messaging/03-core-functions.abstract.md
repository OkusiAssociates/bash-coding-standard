## Core Message Functions

**Use `_msg()` core with `FUNCNAME[1]` inspection for DRY, auto-formatted messaging.**

### Rationale
- `FUNCNAME[1]` auto-detects caller → no format params, consistent output
- Single implementation, impossible to pass wrong level
- Proper streams: errors→stderr, data→stdout (enables `data=$(./script)`)

### Core Pattern

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}▲${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}

# Conditional (VERBOSE), unconditional (error), exit (die)
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### Anti-Patterns

```bash
# ✗ echo direct (no stderr, no prefix, no VERBOSE)
echo "Error: failed"
# ✓ error 'Failed'

# ✗ $(date) in log (subshell overhead)
echo "[$(date)] $*" >> "$LOG"
# ✓ printf '[%(%Y-%m-%d %H:%M:%S)T] %s\n' -1 "$*" >> "$LOG"
```

**Ref:** BCS0703
