## Standardized Messaging and Color Support

**Color detection pattern** - Check terminal on both stdout and stderr before defining color variables:

```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Standard color definitions (terminal detection)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Rationale**: Terminal detection (`[[ -t 1 && -t 2 ]]`) prevents ANSI escape sequences in pipes/redirects. Testing both file descriptors ensures messages (stderr) and output (stdout) are both terminal-bound. Empty strings for non-terminals enable uniform code - `echo "${RED}Error${NC}"` works correctly whether colors are enabled or not.

**Standard color palette**: `RED` (errors), `GREEN` (success), `YELLOW` (warnings), `CYAN` (info), `NC` (reset). All declared readonly after initialization.

**Flags**: `VERBOSE` controls verbosity, `PROMPT` enables user prompts, `DEBUG` enables debug output. Declare as integers (`declare -i`) for boolean testing with `(( ))`.
