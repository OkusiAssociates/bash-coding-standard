## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

### Rationale
- Catches `--output --verbose` (missing filename) â†' prevents next option becoming value
- Type validation prevents late arithmetic errors (`--depth abc`)
- `${1@Q}` provides safe quoting in error messages

### Three Validators

```bash
# Existence check - arg doesn't start with '-'
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }

# Enhanced string validation
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

# Numeric validation (integers only)
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

### Usage Pattern

```bash
while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
  -d|--depth)  arg_num "$@"; shift; MAX_DEPTH=$1 ;;
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done
```

### Anti-Patterns

```bash
# âœ— No validation â†' OUTPUT='--verbose'
-o|--output) shift; OUTPUT=$1 ;;

# âœ“ Validated
-o|--output) arg2 "$@"; shift; OUTPUT=$1 ;;
```

**Critical:** Call validator BEFORE `shift` - validator inspects `$2`.

**Ref:** BCS0803
