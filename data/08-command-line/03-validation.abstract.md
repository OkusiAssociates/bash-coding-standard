## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Rationale
- Catches `--output --verbose` (missing filename) before silent failures
- Validates types at parse time → immediate clear errors vs. late arithmetic failures

### Three Validators

| Function | Purpose | Check |
|----------|---------|-------|
| `noarg()` | Existence | Has arg, not `-` prefixed |
| `arg2()` | String args | Same + `${1@Q}` quoting |
| `arg_num()` | Integers | Matches `^[0-9]+$` |

```bash
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric" ||:; }

while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; DEPTH=$1 ;;
esac; shift; done
```

### Anti-Patterns

```bash
# ✗ No validation → --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# ✓ Validate BEFORE shift
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
```

**Critical:** Call validator BEFORE `shift`—validator inspects `$2`.

**Ref:** BCS0803
