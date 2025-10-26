## Color Management Library

**Use dedicated color library with two-tier system (basic/complete), auto terminal detection, and BCS _msg integration for sophisticated color management.**

**Rationale:** Two-tier prevents namespace pollution; auto-detection supports deployment flexibility; _msg integration initializes VERBOSE/DEBUG/DRY_RUN/PROMPT in one call.

**Tiers:**
- **Basic (default):** NC, RED, GREEN, YELLOW, CYAN
- **Complete (opt-in):** +BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE

**Function:** `color_set [OPTIONS...]`
**Options:** `basic|complete`, `auto|always|never`, `verbose`, `flags`

**Example:**
```bash
source color-set.sh
color_set complete flags  # Colors + _msg vars
info "Starting"           # CYAN, respects VERBOSE
echo "${BOLD}${RED}ERROR${NC}"
```

**Implementation:**
```bash
color_set() {
  local -i color=-1 complete=0 flags=0
  # Parse options
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }
  ((flags)) && declare -ig VERBOSE=${VERBOSE:-1}
  ((complete && flags)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  ((color)) && declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' || declare -g NC='' RED='' GREEN='' YELLOW='' CYAN=''
}
```

**Anti-patterns:** Scattered inline declarations → centralize; always complete tier → use basic when sufficient; `[[ -t 1 ]]` only → test both `[[ -t 1 && -t 2 ]]`; hardcode mode → use `${COLOR_MODE:-auto}`.

**Ref:** BCS0906
