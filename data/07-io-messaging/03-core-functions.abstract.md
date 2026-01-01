## Core Message Functions

**Use private `_msg()` with `FUNCNAME[1]` inspection for auto-formatted, DRY messaging.**

**Key points:**
- `FUNCNAME[1]` detects caller â†' determines color/symbol automatically
- Conditional: `info`/`warn`/`success` respect `VERBOSE`; `error` always shows
- Errors to stderr (`>&2`); separates data from messages
- `die()` takes exit code first: `die 1 'message'`

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
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

**Anti-patterns:**
- `echo "Error: ..."` â†' Use `error` function (no prefix, wrong stream)
- Duplicate logic per function â†' Use single `_msg()` with FUNCNAME
- `error()` to stdout â†' Must use `>&2`
- `info()` ignoring VERBOSE â†' Always check: `((VERBOSE)) || return 0`

**Ref:** BCS0703
