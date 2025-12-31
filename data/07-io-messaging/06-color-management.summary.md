## Color Management Library

For sophisticated color management beyond inline declarations (BCS0701), use a dedicated library providing two-tier system, automatic terminal detection, and BCS \_msg integration (BCS0703).

**Rationale:**
- Two-tier system (basic vs complete) prevents global namespace pollution
- Auto-detection, force-on, or force-off modes for deployment flexibility
- `flags` option sets BCS control variables (VERBOSE, DEBUG, DRY_RUN, PROMPT)
- Dual-purpose pattern (BCS010201) enables sourcing as library or executing for demo
- Centralized color definitions improve maintainability

**Two-Tier Color System:**

**Basic tier (5 variables)** - Default, minimal pollution:
```bash
NC          # No Color / Reset
RED         # Error messages
GREEN       # Success messages
YELLOW      # Warnings
CYAN        # Information
```

**Complete tier (12 variables)** - Opt-in, full ANSI:
```bash
# Basic tier plus:
BLUE        # Additional color option
MAGENTA     # Additional color option
BOLD        # Text emphasis
ITALIC      # Text styling
UNDERLINE   # Text emphasis
DIM         # De-emphasized text
REVERSE     # Inverted colors
```

**Function Signature:** `color_set [OPTIONS...]`

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (checks stdout AND stderr) (default) |
| `always` | Force colors on (even when piped/redirected) |
| `never`, `none` | Force colors off |
| `verbose`, `-v`, `--verbose` | Print all variable declarations |
| `flags` | Set BCS \_msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |

**BCS _msg Integration:**

```bash
source color-set
color_set complete flags

# Now these globals are set:
# VERBOSE=1 (or preserved if already set)
# DEBUG=0
# DRY_RUN=1
# PROMPT=1
```

**Dual-Purpose Pattern:**

```bash
# Usage 1: Source as library (traditional)
source color-set
color_set complete
echo "${RED}Error:${NC} Failed"

# Usage 2: Source as library (enhanced - auto-calls color_set)
source color-set complete
echo "${RED}Error:${NC} Failed"

# Usage 3: Execute for demonstration
./color-set complete verbose
./color-set --help
```

**Implementation Example:**

```bash
#!/bin/bash
#shellcheck disable=SC2015
# color-set - Color management library

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose|-v|--verbose)
                verbose=1 ;;
      always)   color=1 ;;
      never|none)
                color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "${FUNCNAME[0]}: ✗ Invalid argument ${1@Q}"
                return 2 ;;
    esac
    shift
  done

  # Auto-detect: both stdout AND stderr must be TTY
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; } ||:

  # Set BCS control flags if requested
  if ((flags)); then
    declare -igx VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -igx DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -gx NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'
    ((complete)) && declare -gx BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' ITALIC=$'\033[3m' UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m' || :
  else
    declare -gx NC='' RED='' GREEN='' YELLOW='' CYAN=''
    ((complete)) && declare -gx BLUE='' MAGENTA='' BOLD='' ITALIC='' UNDERLINE='' DIM='' REVERSE='' || :
  fi

  # Verbose output if requested
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE ||:
    declare -p NC RED GREEN YELLOW CYAN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT ||:
      declare -p BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
    } ||:
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: enhanced syntax support
[[ ${BASH_SOURCE[0]} == "$0" ]] || {
  (($#)) && color_set "$@" || :
  return 0
}

# Executable section (only runs when executed directly)
#!/bin/bash #semantic
set -euo pipefail

declare -r VERSION=1.0.1

# Help handling
if [[ ${1:-} =~ ^(-h|--help|help)$ ]]; then
  cat <<HELP
color-set $VERSION [OPTIONS...]

Dual-purpose bash library for terminal color management with ANSI escape codes.

MODES:
  Source as library:  source color-set; color_set [OPTIONS]
  Execute directly:   color-set [OPTIONS]

OPTIONS:
  complete          Enable complete color set (12 variables)
  basic             Enable basic color set (5 variables) [default]

  always            Force colors on
  never, none       Force colors off
  auto              Auto-detect TTY [default]

  verbose, -v       Print variable declarations
  --verbose

  flags             Set standard BCS globals for _msg system messaging constructs
                    • With 'basic': Sets VERBOSE only
                    • With 'complete': Sets VERBOSE, DEBUG, DRY_RUN, PROMPT

BASIC TIER (5 variables):
  NC, RED, GREEN, YELLOW, CYAN

COMPLETE TIER (+7 additional variables):
  BLUE, MAGENTA, BOLD, ITALIC, UNDERLINE, DIM, REVERSE

EXAMPLES:
  color-set complete verbose
  color-set always
  source color-set && color_set complete && echo "\${RED}Error\${NC}"

OPTIONS can be combined in any order.
HELP
  exit 0
fi

color_set "$@"

#fin
```

**Usage Examples:**

```bash
# Basic usage
source color-set
color_set basic
echo "${RED}Error:${NC} Operation failed"
echo "${GREEN}Success:${NC} Operation completed"

# Complete tier with attributes
source color-set
color_set complete
echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"

# Force colors for piped output
source color-set
color_set complete always
./script.sh | less -R

# Integrated with BCS _msg system
source color-set complete flags
info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"      # Uses GREEN, respects VERBOSE
error "Connection failed"      # Uses RED, always shown
```

**Anti-patterns:**

❌ **Scattered inline declarations:**
```bash
# DON'T: Duplicate declarations across scripts
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
```

❌ **Testing only stdout:**
```bash
# DON'T: Incomplete terminal detection
[[ -t 1 ]] && color=1  # Fails when stderr redirected
# DO: Test both streams
[[ -t 1 && -t 2 ]] && color=1 || color=0
```

❌ **Forcing colors without user control:**
```bash
# DON'T: Hardcode color mode
color_set always
# DO: Respect environment or provide flag
color_set ${COLOR_MODE:-auto}
```

**Reference:** `/usr/local/lib/color-set` or https://github.com/Open-Technology-Foundation/color-set

**Cross-References:** BCS0701 (Inline Colors), BCS0703 (Core Message Functions), BCS010201 (Dual-Purpose Scripts)

**Ref:** BCS0706
