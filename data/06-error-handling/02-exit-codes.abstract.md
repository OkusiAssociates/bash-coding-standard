## Exit Codes

**Use consistent exit codes for predictable error handling across scripts.**

### die() Function
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
die 3 'File not found'
```

### Core Codes
| Code | Name | Use |
|------|------|-----|
| 0 | SUCCESS | OK |
| 1 | ERR_GENERAL | Catchall |
| 2 | ERR_USAGE | CLI error |
| 3-7 | File ops | NOENT/ISDIR/IO/NOTDIR/EMPTY |
| 8-10,22 | Validation | REQUIRED/RANGE/TYPE/INVAL |
| 11-13 | Permissions | PERM/READONLY/ACCESS |
| 14-17 | Resources | NOMEM/NOSPC/BUSY/EXIST |
| 18-21 | Environment | NODEP/CONFIG/ENV/STATE |
| 23-25 | Network | NETWORK/TIMEOUT/HOST |

### Reserved: 64-78 (sysexits), 126-127 (Bash), 128+n (signals)

### Usage
```bash
[[ -f "$cfg" ]] || die 3 "Not found ${cfg@Q}"
command -v jq &>/dev/null || die 18 'Missing: jq'
```

### Anti-Patterns
- `exit 1` for all errors â†' Use specific codes
- Codes 64+ â†' Reserved for system use

**Ref:** BCS0602
