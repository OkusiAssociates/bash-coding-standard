## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures, catches user mistakes (like `--output --verbose` where filename is missing), validates data types before use with clear error messages.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

Checks: at least 2 args remain, next arg doesn't start with `-`.

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
```

Uses `${1@Q}` for safe parameter quoting in error messages.

**3. `arg_num()` - Numeric Argument Validation**

```bash
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

Validates integer pattern (`^[0-9]+$`). Rejects: negative numbers, decimals, non-numeric text.

### Complete Example

```bash
declare -i MAX_DEPTH=5 VERBOSE=0
declare -- OUTPUT_FILE=''
declare -a INPUT_FILES=()

arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }

main() {
  while (($#)); do case $1 in
    -o|--output)  arg2 "$@"; shift; OUTPUT_FILE=$1 ;;
    -d|--depth)   arg_num "$@"; shift; MAX_DEPTH=$1 ;;
    -v|--verbose) VERBOSE=1 ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            INPUT_FILES+=("$1") ;;
  esac; shift; done
  readonly -- OUTPUT_FILE MAX_DEPTH VERBOSE
}
main "$@"
```

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT` |

### Anti-Patterns

```bash
# âœ— No validation - silent failure
-o|--output) shift; OUTPUT=$1 ;;
# Problem: --output --verbose â†' OUTPUT='--verbose'

# âœ— No validation - type error later
-d|--depth) shift; MAX_DEPTH=$1 ;;
# Problem: --depth abc â†' arithmetic error: "abc: syntax error"

# âœ“ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Edge Cases

**`${1@Q}` quoting** prevents crashes with special characters:
```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error crashes or expands $option
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.

See BCS04XX for `${parameter@Q}` shell quoting operator details.
