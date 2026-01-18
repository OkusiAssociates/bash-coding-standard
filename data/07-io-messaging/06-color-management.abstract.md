## Color Management Library

**Use dedicated color library with two-tier system, terminal auto-detection, and BCS _msg integration.**

**Two Tiers:**
- **Basic (5):** `NC RED GREEN YELLOW CYAN` — minimal namespace
- **Complete (12):** Basic + `BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE`

**Key Options:** `basic|complete`, `auto|always|never`, `flags` (sets VERBOSE/DEBUG/DRY_RUN/PROMPT), `verbose`

**Rationale:** Namespace control via tiered loading; centralized definitions; dual-purpose pattern (BCS010201).

**Usage:**
```bash
source color-set complete flags
echo "${RED}Error:${NC} Failed"
info "Starting"  # _msg integration ready
```

**Anti-patterns:**
- `color_set complete` when only basic needed → namespace pollution
- `[[ -t 1 ]]` only → must test both: `[[ -t 1 && -t 2 ]]`
- `color_set always` hardcoded → use `${COLOR_MODE:-auto}`

**Ref:** BCS0706
