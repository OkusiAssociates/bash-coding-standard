## Color Management Library

**Use a dedicated color library with two-tier system (basic/complete), auto-detection, and BCS `_msg` integration for sophisticated color needs.**

### Two-Tier System

**Basic (5 vars):** `NC`, `RED`, `GREEN`, `YELLOW`, `CYAN`
**Complete (+7):** `BLUE`, `MAGENTA`, `BOLD`, `ITALIC`, `UNDERLINE`, `DIM`, `REVERSE`

### Key Options

`basic`|`complete` — tier selection; `auto`|`always`|`never` — color mode; `flags` — set `VERBOSE`, `DEBUG`, `DRY_RUN`, `PROMPT`; `verbose` — show declarations

### Core Pattern

```bash
source color-set complete flags
info 'Starting'  # Colors + _msg ready
echo "${RED}Error:${NC} Failed"
```

### Auto-Detection

Test **both** streams: `[[ -t 1 && -t 2 ]] && color=1 || color=0`

### Anti-Patterns

- ❌ Scattered inline declarations → use library
- ❌ `complete` when only need basic → namespace pollution
- ❌ `[[ -t 1 ]]` only → fails when stderr redirected
- ❌ Hardcoded `always` → respect `${COLOR_MODE:-auto}`

**Ref:** BCS0706
