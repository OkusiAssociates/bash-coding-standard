## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures like `--output --verbose` (missing filename), catches type errors early, provides clear error messages.

### Three Validators

**1. `noarg()` - Basic check:**
```bash
noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}
```

**2. `arg2()` - Enhanced with safe quoting:**
```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

**3. `arg2_num()` - Numeric validation:**
```bash
arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}
```

**Usage:**
```bash
while (($#)); do case $1 in
  -o|--output) arg2 "$@"; shift; OUTPUT="$1" ;;
  -d|--depth)  arg2_num "$@"; shift; MAX_DEPTH="$1" ;;
  -v|--verbose) VERBOSE=1 ;;
esac; shift; done
```

**Validator selection:**
- `noarg()`: Simple existence (`-o FILE`)
- `arg2()`: Strings, prevent `-` prefix (`--prefix PATH`)
- `arg2_num()`: Integer args (`--depth NUM`)

**Critical:** Call validator BEFORE `shift` (needs `$2`). Use `${1@Q}` for safe error messages.

**Anti-pattern:**
```bash
#  No validation
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose ’ OUTPUT='--verbose'

#  Validated
-o|--output) arg2 "$@"; shift; OUTPUT="$1" ;;
```

**Ref:** BCS1003
