## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Rationale
- Catches `--output --verbose` where filename is missing â†' prevents using next option as value
- Provides immediate clear errors vs silent failures or late arithmetic crashes

### Validation Helpers

```bash
# String arg validation (prevents -prefix as value)
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

# Numeric arg validation (integer only)
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires numeric argument" ||:; }

# Usage in case statement
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
-d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
```

### Validator Selection

| Validator | Use Case |
|-----------|----------|
| `arg2()` | String args, prevent `-` prefix |
| `arg_num()` | Integer args only |

### Anti-Patterns

```bash
# âœ— No validation â†' --output --verbose makes OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# âœ— No type check â†' --depth abc causes late arithmetic error
-d|--depth) shift; MAX_DEPTH=$1 ;;
```

**Critical:** Call validator BEFORE `shift` â€” validator inspects `$2`.

**Ref:** BCS0803
