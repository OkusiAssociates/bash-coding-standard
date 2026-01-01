## Color Management Library

**Use dedicated color library for sophisticated color needs: two-tier system, auto-detection, `_msg` integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` ‚Äî default, minimal namespace
- **Complete (12):** Basic + `BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE`

**Options:** `basic|complete`, `auto|always|never`, `verbose`, `flags`

**Rationale:** Namespace control via tiers; centralized definitions; `flags` initializes `VERBOSE DEBUG DRY_RUN PROMPT`

**Core Pattern:**
```bash
source color-set complete flags
info 'Starting'  # Colors + _msg ready
echo "${RED}Error:${NC} Failed"

# Auto-detect checks BOTH streams
[[ -t 1 && -t 2 ]] && color=1 || color=0
```

**Anti-patterns:**
- ‚ùå Scattered inline `RED=$'\033[0;31m'` in every script ‚Ü' use library
- ‚ùå `[[ -t 1 ]]` only ‚Ü' test both stdout AND stderr
- ‚ùå `color_set always` hardcoded ‚Ü' use `${COLOR_MODE:-auto}`

**Ref:** BCS0706
