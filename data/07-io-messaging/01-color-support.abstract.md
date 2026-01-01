## Color Support

**Detect terminal capability and define colors conditionally; disable when piped.**

### Pattern

```bash
declare -i VERBOSE=1 DEBUG=0
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' NC=''
fi
```

### Key Points

- Test both stdout (`-t 1`) and stderr (`-t 2`) for TTY
- Use `$'\033[...]'` ANSI escape syntax
- Empty strings when piped â†' safe for log files
- `declare -r` prevents accidental modification

### Anti-Patterns

`echo -e "\e[31m"` â†' non-portable; `[[ -t 1 ]]` alone â†' misses stderr redirection

**Ref:** BCS0701
