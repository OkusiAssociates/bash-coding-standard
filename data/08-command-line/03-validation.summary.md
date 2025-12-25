## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures (e.g., `--output --verbose` where filename is missing), provides clear error messages, validates data types before use, catches user mistakes early.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}
```

Validates that option has argument and doesn't start with `-`.
- `(($# > 1))` - At least 2 arguments remain
- `[[ ${2:0:1} != '-' ]]` - Next argument doesn't start with `-`

**Usage:**
```bash
while (($#)); do case $1 in
  -o|--output)
    noarg "$@"      # Validate argument exists
    shift
    OUTPUT="$1"
    ;;
esac; shift; done
```

**2. `arg2()` - Enhanced Validation with Safe Quoting**

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

Enhanced version with better error messages using `${1@Q}` shell quoting.
- Uses `${#@}-1<1` for argument count (explicit remaining args)
- Uses `${1@Q}` to safely escape special characters in error output

**3. `arg2_num()` - Numeric Argument Validation**

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
  -d|--depth)
    arg2_num "$@"   # Validate numeric
    shift
    MAX_DEPTH="$1"  # Guaranteed to be integer
    ;;
esac; shift; done
```

Validates argument exists and matches `^[0-9]+$` pattern. Rejects negative numbers, decimals, non-numeric text.

### Complete Example

```bash
declare -i MAX_DEPTH=5 VERBOSE=0
declare -- OUTPUT_FILE=''
declare -a INPUT_FILES=()

main() {
  while (($#)); do case $1 in
    -o|--output)
      arg2 "$@"                 # String validation
      shift
      OUTPUT_FILE="$1"
      ;;

    -d|--depth)
      arg2_num "$@"             # Numeric validation
      shift
      MAX_DEPTH="$1"
      ;;

    -v|--verbose)
      VERBOSE=1                 # No argument needed
      ;;

    -*)
      die 22 "Invalid option ${1@Q}"
      ;;

    *)
      INPUT_FILES+=("$1")       # Positional argument
      ;;
  esac; shift; done

  readonly -- OUTPUT_FILE MAX_DEPTH VERBOSE
}

# Validation helpers
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}

arg2_num() {
  if ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]]; then
    die 2 "${1@Q} requires a numeric argument"
  fi
}

noarg() {
  (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"
}

main "$@"
```

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg2_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT`, `-C NUM` |

### Anti-Patterns

```bash
#  No validation - silent failure
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose ’ OUTPUT='--verbose'

#  No validation - type error later
-d|--depth) shift; MAX_DEPTH="$1" ;;
# Problem: --depth abc ’ arithmetic errors: "abc: syntax error"

#  Manual validation - verbose, repetitive, inconsistent
-p|--prefix)
  if (($# < 2)); then
    die 2 "Option '-p' requires an argument"
  fi
  shift
  PREFIX="$1"
  ;;

#  Use helpers - concise, consistent
-p|--prefix) arg2 "$@"; shift; PREFIX="$1" ;;
```

### Error Message Quality

**The `${1@Q}` pattern** safely quotes option names in error messages:

```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

See BCS04XX for detailed explanation of the `${parameter@Q}` shell quoting operator.

### Integration with Case Statements

Validators work with standard argument parsing pattern (BCS1001):

```bash
while (($#)); do case $1 in
  -d|--depth)     arg2_num "$@"; shift; MAX_DEPTH="$1" ;;
  -v|--verbose)   VERBOSE=1 ;;
  -h|--help)      show_help; exit 0 ;;
  -[dvh]*)        set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              FILES+=("$1") ;;
esac; shift; done
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.
