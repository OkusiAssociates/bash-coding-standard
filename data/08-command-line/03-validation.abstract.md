## Argument Validation

**Use validation helpers to ensure option arguments exist and have correct types before processing.**

### Core Validators

```bash
# Basic existence check
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }

# String validation with safe quoting
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

# Numeric validation
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

### Usage Pattern

```bash
while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
esac; shift; done
```

**Critical:** Call validator BEFORE `shift` — validator inspects `$2`.

### Validator Selection

| Validator | Use Case |
|-----------|----------|
| `noarg()` | Simple existence check |
| `arg2()` | String args, prevent `-` prefix |
| `arg_num()` | Numeric integers only |

### Anti-Patterns

```bash
# ✗ No validation �' --output --verbose sets OUTPUT='--verbose'
-o|--output) shift; OUTPUT="$1" ;;

# ✓ Validated
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
```

**`${1@Q}` pattern:** Safe shell quoting prevents expansion of special characters in error messages.

**Ref:** BCS0803
