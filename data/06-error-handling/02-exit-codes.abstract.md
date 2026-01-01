## Exit Codes

**Use standard exit codes 0-125; define constants for readability.**

```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
die 1 'General error'
die 22 "Invalid option ${1@Q}"
```

| Code | Meaning | Use |
|------|---------|-----|
| 0 | Success | Completed OK |
| 1 | General error | Catchall |
| 2 | Usage error | Missing arg |
| 22 | Invalid arg | EINVAL |
| 126 | Cannot execute | Permission |
| 127 | Not found | PATH/typo |
| 128+n | Signal n | 130=Ctrl+C |

**Constants pattern:**
```bash
readonly -i ERR_GENERAL=1 ERR_USAGE=2 ERR_CONFIG=3
die "$ERR_CONFIG" 'Config load failed'
```

**Rationale:**
- 0=success universal Unix convention
- 22=EINVAL standard errno
- Avoid 126-255 (reserved for signals)

**Anti-patterns:** Exit codes >125 conflict with signals â†' use 1-125 for custom codes.

**Ref:** BCS0602
