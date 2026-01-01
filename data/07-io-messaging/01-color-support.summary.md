## Standardized Messaging and Color Support

```bash
# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Rationale:** Terminal detection via `-t 1 && -t 2` ensures colors only appear when both stdout and stderr are terminals, preventing ANSI codes in logs/pipes.

**Anti-patterns:**
```bash
# ✗ Unconditional colors (breaks pipes/logs)
declare -r RED=$'\033[0;31m'

# ✗ Missing NC reset
echo "${RED}Error"  # Terminal stays red
```
