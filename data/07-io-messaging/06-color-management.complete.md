## Color Management Library

For scripts requiring more sophisticated color management than inline declarations (BCS0701), use a dedicated color management library that provides a two-tier system, automatic terminal detection, and integration with the BCS \_msg system (BCS0703).

**Rationale:**

- **Namespace Control**: Two-tier system (basic vs complete) prevents pollution of the global namespace
- **Flexibility**: Auto-detection, force-on, or force-off modes for different deployment scenarios
- **_msg Integration**: `flags` option sets standard BCS control variables (VERBOSE, DEBUG, DRY_RUN, PROMPT)
- **Reusability**: Dual-purpose pattern (BCS010201) allows sourcing as library or executing for demonstration
- **Maintainability**: Centralized color definitions rather than scattered inline declarations
- **Testing**: Built-in verbose mode for debugging color variable states

**Two-Tier Color System:**

**Basic tier (5 variables)** - Default, minimal namespace pollution:
```bash
NC          # No Color / Reset
RED         # Error messages
GREEN       # Success messages
YELLOW      # Warnings
CYAN        # Information
```

**Complete tier (12 variables)** - Opt-in, full ANSI capability:
```bash
# Basic tier (above) plus:
BLUE        # Additional color option
MAGENTA     # Additional color option
BOLD        # Text emphasis
ITALIC      # Text styling
UNDERLINE   # Text emphasis
DIM         # De-emphasized text
REVERSE     # Inverted colors
```

**Library Function Signature:**

```bash
color_set [OPTIONS...]
```

**Options (combinable in any order):**

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (checks stdout AND stderr) (default) |
| `always` | Force colors on (even when piped/redirected) |
| `never`, `none` | Force colors off |
| `verbose`, `-v`, `--verbose` | Print all variable declarations |
| `flags` | Set BCS \_msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |
| `--help`, `-h`, `help` | Display usage (executable mode only) |

**BCS _msg System Integration:**

The `flags` option initializes standard BCS control variables used by core message functions (BCS0703):

```bash
source color-set
color_set complete flags

# Now these globals are set:
# VERBOSE=1 (or preserved if already set)
# DEBUG=0
# DRY_RUN=1
# PROMPT=1
```

This integration enables one-line initialization of both colors and messaging control:
```bash
#!/bin/bash
source /usr/local/lib/color-set
color_set complete flags

# Colors and _msg system now ready
info 'Starting process'
success 'Operation completed'
```

**Dual-Purpose Pattern (BCS010201):**

The library implements the dual-purpose pattern, working both as a sourceable library and standalone utility:

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

The enhanced sourcing syntax passes arguments directly to `color_set`, eliminating the need for a separate function call.

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

**Basic usage:**
```bash
#!/bin/bash
source color-set
color_set basic

echo "${RED}Error:${NC} Operation failed"
echo "${GREEN}Success:${NC} Operation completed"
echo "${YELLOW}Warning:${NC} Deprecated feature"
```

**Complete tier with attributes:**
```bash
source color-set
color_set complete

echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"
echo "${UNDERLINE}Important${NC}"
```

**Force colors for piped output:**
```bash
#!/bin/bash
source color-set
color_set complete always

# Colors preserved even when piped
./script.sh | less -R
```

**Disable colors for logging:**
```bash
#!/bin/bash
source color-set
color_set never

# No ANSI codes in log files
exec > /var/log/script.log 2>&1
```

**Integrated with BCS _msg system:**
```bash
#!/bin/bash
# Enhanced syntax: source and configure in one line
source color-set complete flags

# Now have colors AND messaging functions
info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"      # Uses GREEN, respects VERBOSE
error "Connection failed"      # Uses RED, always shown
debug "State: x=$x"            # Uses YELLOW, respects DEBUG
```

**Testing color variables:**
```bash
# Show all variables in current shell
source color-set
color_set complete verbose

# Test as executable
./color-set complete verbose

# Test piped output (should disable colors)
./color-set auto verbose | cat
```

**Anti-patterns:**

❌ **Scattered inline color declarations:**
```bash
# DON'T: Duplicate declarations across scripts
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
# ... repeated in every script
```

❌ **Always loading complete tier:**
```bash
# DON'T: Pollute namespace when only need basic colors
source color-set
color_set complete  # Unnecessary if only using RED/GREEN/YELLOW/CYAN
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

**Reference Implementation:**

See `/usr/local/lib/color-set` or https://github.com/Open-Technology-Foundation/color-set

**Cross-References:**

- **BCS0701** (Standardized Messaging and Color Support) - Basic inline color pattern that this enhances
- **BCS0703** (Core Message Functions) - _msg system that uses these colors and control flags
- **BCS010201** (Dual-Purpose Scripts) - Pattern this library implements

**Ref:** BCS0706
