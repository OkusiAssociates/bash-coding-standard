## Color Management Library

For scripts requiring sophisticated color management beyond inline declarations (BCS0901), use a dedicated color management library providing two-tier system, automatic terminal detection, and _msg system integration (BCS0903).

**Rationale:**

- **Namespace Control**: Two-tier system (basic 5 vars vs complete 12 vars) prevents global namespace pollution
- **Flexibility**: Auto-detection, force-on, or force-off modes for different deployment scenarios
- **_msg Integration**: `flags` option sets BCS control variables (VERBOSE, DEBUG, DRY_RUN, PROMPT)
- **Reusability**: Dual-purpose pattern (BCS010201) - sourceable library or standalone executable
- **Maintainability**: Centralized color definitions vs scattered inline declarations
- **Testing**: Built-in verbose mode for debugging color variable states

**Two-Tier Color System:**

**Basic tier (5 variables)** - Default:
```bash
NC RED GREEN YELLOW CYAN
```

**Complete tier (12 variables)** - Opt-in:
```bash
# Basic tier plus:
BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
```

**Library Function Signature:**

```bash
color_set [OPTIONS...]
```

**Options (combinable):**

| Option | Description |
|--------|-------------|
| `basic` | Enable basic 5-variable set (default) |
| `complete` | Enable complete 12-variable set |
| `auto` | Auto-detect terminal (checks stdout AND stderr) (default) |
| `always` | Force colors on (even when piped/redirected) |
| `never`, `none` | Force colors off |
| `verbose`, `-v`, `--verbose` | Print all variable declarations |
| `flags` | Set BCS _msg globals: VERBOSE, DEBUG, DRY_RUN, PROMPT |
| `--help`, `-h`, `help` | Display usage (executable mode only) |

**BCS _msg System Integration:**

The `flags` option initializes BCS control variables for core message functions (BCS0903):

```bash
source color-set.sh
color_set complete flags

# Sets: VERBOSE=1 (or preserved), DEBUG=0, DRY_RUN=1, PROMPT=1
```

One-line initialization of colors and messaging:
```bash
#!/bin/bash
source /usr/local/lib/color-set.sh
color_set complete flags

info "Starting process"
success "Operation completed"
```

**Implementation Example:**

```bash
#!/bin/bash
# color-set.sh - Color management library

color_set() {
  local -i color=-1 complete=0 verbose=0 flags=0
  while (($#)); do
    case ${1:-auto} in
      complete) complete=1 ;;
      basic)    complete=0 ;;
      flags)    flags=1 ;;
      verbose|-v|--verbose) verbose=1 ;;
      always)   color=1 ;;
      never|none) color=0 ;;
      auto)     color=-1 ;;
      *)        >&2 echo "$FUNCNAME: error: Invalid option ${1@Q}"
                return 1 ;;
    esac
    shift
  done

  # Auto-detect: both stdout AND stderr must be TTY
  ((color == -1)) && { [[ -t 1 && -t 2 ]] && color=1 || color=0; }

  # Set BCS control flags if requested
  if ((flags)); then
    declare -ig VERBOSE=${VERBOSE:-1}
    ((complete)) && declare -ig DEBUG=0 DRY_RUN=1 PROMPT=1 || :
  fi

  # Declare color variables
  if ((color)); then
    declare -g NC=$'\033[0m' RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m'
    ((complete)) && declare -g BLUE=$'\033[0;34m' MAGENTA=$'\033[0;35m' BOLD=$'\033[1m' ITALIC=$'\033[3m' UNDERLINE=$'\033[4m' DIM=$'\033[2m' REVERSE=$'\033[7m' || :
  else
    declare -g NC='' RED='' GREEN='' YELLOW='' CYAN=''
    ((complete)) && declare -g BLUE='' MAGENTA='' BOLD='' ITALIC='' UNDERLINE='' DIM='' REVERSE='' || :
  fi

  # Verbose output if requested
  if ((verbose)); then
    ((flags)) && declare -p VERBOSE || :
    declare -p NC RED GREEN YELLOW CYAN
    ((complete)) && {
      ((flags)) && declare -p DEBUG DRY_RUN PROMPT || :
      declare -p BLUE MAGENTA BOLD ITALIC UNDERLINE DIM REVERSE
    } || :
  fi

  return 0
}
declare -fx color_set

# Dual-purpose pattern: early return when sourced
[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# Executable section (only runs when executed directly)
#!/bin/bash #semantic
set -euo pipefail

# Help handling
if [[ ${1:-} =~ ^(-h|--help|help)$ ]]; then
  cat <<'HELP'
Usage: color-set.sh [OPTIONS...]

Dual-purpose bash library for terminal color management.

OPTIONS:
  complete          Enable complete color set (12 variables)
  basic             Enable basic color set (5 variables) [default]
  always            Force colors on
  never, none       Force colors off
  auto              Auto-detect TTY [default]
  verbose, -v       Print variable declarations
  flags             Set BCS globals (VERBOSE, DEBUG, DRY_RUN, PROMPT)
  --help, -h        Display this help

EXAMPLES:
  ./color-set.sh complete verbose
  source color-set.sh && color_set complete flags
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
source color-set.sh
color_set basic

echo "${RED}Error:${NC} Operation failed"
echo "${GREEN}Success:${NC} Operation completed"
```

**Complete tier with attributes:**
```bash
source color-set.sh
color_set complete

echo "${BOLD}${RED}CRITICAL ERROR${NC}"
echo "${ITALIC}${CYAN}Note:${NC} ${DIM}Additional details${NC}"
```

**Force colors for piped output:**
```bash
source color-set.sh
color_set complete always

./script.sh | less -R  # Colors preserved
```

**Disable colors for logging:**
```bash
source color-set.sh
color_set never

exec > /var/log/script.log 2>&1  # No ANSI codes
```

**Integrated with BCS _msg system:**
```bash
source color-set.sh
color_set complete flags

info "Starting process"        # Uses CYAN, respects VERBOSE
success "Build completed"       # Uses GREEN
error "Connection failed"       # Uses RED
debug "State: x=$x"            # Uses YELLOW, respects DEBUG
```

**Testing color variables:**
```bash
# Show all variables
source color-set.sh
color_set complete verbose

# Test piped output (should disable colors)
./color-set.sh auto verbose | cat
```

**Anti-patterns:**

L **Scattered inline color declarations:**
```bash
# DON'T: Duplicate declarations across scripts
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
```

L **Always loading complete tier:**
```bash
# DON'T: Pollute namespace unnecessarily
color_set complete  # When only using basic colors
```

L **Testing only stdout:**
```bash
# DON'T: Incomplete terminal detection
[[ -t 1 ]] && color=1  # Fails when stderr redirected
# DO: Test both streams
[[ -t 1 && -t 2 ]] && color=1
```

**Reference Implementation:**

`/usr/local/lib/color-set.sh` or https://github.com/Open-Technology-Foundation/bash-libs/color-set

**Cross-References:**

- **BCS0901** - Basic inline color pattern
- **BCS0903** - Core message functions using colors and control flags
- **BCS010201** - Dual-purpose pattern

**Ref:** BCS0906
