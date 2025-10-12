### Core Message Functions
\`\`\`bash
# Core message function using FUNCNAME for context
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case "${FUNCNAME[1]}" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${YELLOW}DEBUG${NC}:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
# Conditional output based on verbosity
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
# Unconditional output
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
# yes/no
yn() {
  ((PROMPT)) || return 0
  local -- reply
  >&2 read -r -n 1 -p "$SCRIPT_NAME: ${YELLOW}$1${NC} y/n " reply
  >&2 echo
  [[ ${reply,,} == y ]]
}
\`\`\`
