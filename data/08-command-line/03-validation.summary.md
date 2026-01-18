## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures, provides clear error messages, catches mistakes like `--output --verbose` (missing filename), validates data types before use.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

Checks: `(($# > 1))` ensures 2+ arguments remain; `[[ ${2:0:1} != '-' ]]` ensures next arg doesn't start with `-`.

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

Uses `${1@Q}` for safe parameter quoting in error messages (escapes special characters).

**3. `arg_num()` - Numeric Argument Validation**

```bash
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

Validates argument exists and matches integer pattern (`^[0-9]+$`). Rejects negative numbers, decimals, non-numeric text.

### Usage Pattern

```bash
while (($#)); do case $1 in
  -o|--output)
    arg2 "$@"       # Validate argument exists
    shift
    OUTPUT=$1       # Now safe to use $1
    ;;
  -d|--depth)
    arg_num "$@"    # Validate numeric
    shift
    MAX_DEPTH=$1    # Guaranteed integer
    ;;
esac; shift; done
```

**Critical:** Call validator BEFORE `shift` - validator needs to inspect `$2`.

### Complete Example

```bash
declare -i MAX_DEPTH=5 VERBOSE=0
declare -- OUTPUT_FILE=''
declare -a INPUT_FILES=()

arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }

main() {
  while (($#)); do case $1 in
    -o|--output)    arg2 "$@"; shift; OUTPUT_FILE=$1 ;;
    -d|--depth)     arg_num "$@"; shift; MAX_DEPTH=$1 ;;
    -v|--verbose)   VERBOSE=1 ;;
    -*)             die 22 "Invalid option ${1@Q}" ;;
    *)              INPUT_FILES+=("$1") ;;
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
# ✗ No validation - silent failure
-o|--output) shift; OUTPUT=$1 ;;
# Problem: --output --verbose → OUTPUT='--verbose'

# ✗ No validation - type error later
-d|--depth) shift; MAX_DEPTH=$1 ;;
# Problem: --depth abc → arithmetic errors: "abc: syntax error"

# ✗ Manual validation - verbose and inconsistent
-p|--prefix)
  if (($# < 2)); then die 2 "Option '-p' requires an argument"; fi
  shift; PREFIX=$1 ;;

# ✓ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Error Message Quality

The `${1@Q}` pattern ensures safe error output:
```bash
# Input: script '--weird$option' value
# With ${1@Q}: error: '--weird$option' requires argument
# Without:     crashes or expands $option
```

See BCS04XX for `${parameter@Q}` shell quoting operator details.
