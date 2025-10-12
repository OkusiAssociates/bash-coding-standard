### Readonly After Group

When declaring multiple readonly variables, declare them first, then make them all readonly in a single statement:

```bash
# Script metadata
VERSION='1.0.0'
SCRIPT_PATH=$(readlink -en -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Message function flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0
# Standard color definitions (if terminal output)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Rationale:** This pattern improves readability by clearly separating the initialization phase from the protection phase. It makes the group of related constants visually distinct and easier to maintain.

**Anti-pattern:**
```bash
# ✗ Don't make each variable readonly individually
readonly VERSION='1.0.0'
readonly SCRIPT_PATH=$(readlink -en -- "$0")
readonly SCRIPT_DIR=${SCRIPT_PATH%/*}
readonly SCRIPT_NAME=${SCRIPT_PATH##*/}
```
