## Exit Codes

**Use consistent exit codes; 0=success, 1=general, 2=usage, 3-25=BCS categories.**

### die() Function
```bash
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

### BCS Exit Codes (Key)

| Code | Name | Use |
|------|------|-----|
| 0 | SUCCESS | OK |
| 1 | ERR_GENERAL | Catchall |
| 2 | ERR_USAGE | CLI usage |
| 3 | ERR_NOENT | File not found |
| 8 | ERR_REQUIRED | Missing arg |
| 13 | ERR_ACCESS | Permission denied |
| 18 | ERR_NODEP | Missing dep |
| 22 | ERR_INVAL | Invalid arg |
| 24 | ERR_TIMEOUT | Timeout |

### Reserved: 64-78 (sysexits), 126-127 (Bash), 128+n (signals)

### Usage
```bash
[[ -f "$cfg" ]] || die 3 "Not found ${cfg@Q}"
command -v jq &>/dev/null || die 18 'Missing: jq'
```

### Anti-patterns
- `exit 1` for all errors → loses diagnostic info
- Codes 64+ → reserved ranges

**Ref:** BCS0602
