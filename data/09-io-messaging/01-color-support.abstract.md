## Standardized Messaging and Color Support

**Detect terminal output before enabling colors; use ANSI escape codes via `$'...'` syntax; make color variables readonly.**

**Rationale:** Terminal detection (`[[ -t 1 && -t 2 ]]`) prevents ANSI codes in logs/pipes. Empty string fallback ensures clean non-terminal output. `readonly` prevents accidental modification.

**Pattern:**
```bash
# Message control flags
declare -i VERBOSE=1 PROMPT=1 DEBUG=0

# Color support (terminal detection)
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' \
              YELLOW=$'\033[0;33m' CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  readonly -- RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi
```

**Anti-patterns:**
- `RED="\033[0;31m"` ’ Wrong: double quotes don't interpret escapes, use `$'...'`
- No terminal check ’ ANSI codes appear in logs
- Mutable colors ’ Can be accidentally changed mid-script

**Ref:** BCS0901
