## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures, provides clear error messages, catches user mistakes (like `--output --verbose` where filename is missing), validates data types before use.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

Validates that an option has an argument following it.

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

**Usage:**
```bash
while (($#)); do case $1 in
  -o|--output)
    noarg "$@"      # Validate argument exists
    shift
    OUTPUT=$1       # Now safe to use $1
    ;;
esac; shift; done
```

**What it checks:**
- `(($# > 1))` - At least 2 arguments remain (option + value)
- `[[ ${2:0:1} != '-' ]]` - Next argument doesn't start with `-`

**2. `arg2()` - Enhanced Validation with Safe Quoting**

Enhanced version with better error messages using shell quoting (`${1@Q}`).

```bash
arg2() {
  if ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]]; then
    die 2 "${1@Q} requires argument"
  fi
}
```

**Usage:**
```bash
while (($#)); do case $1 in
  -p|--prefix)
    arg2 "$@"       # Enhanced validation
    shift
    PREFIX=$1
    ;;
esac; shift; done
```

**Differences from `noarg()`:**
- Uses `${#@}-1<1` for argument count (explicit remaining args)
- Uses `${1@Q}` for safe parameter quoting in error message
- More concise error message format

**Benefits:**
- **Catches:** `script --output --verbose` (no filename provided)
- **Prevents:** Using next option as value
- **Safe quoting:** `${1@Q}` escapes special characters in error output

**3. `arg_num()` - Numeric Argument Validation**

Validates that an option's argument is a valid integer.

```bash
arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }
```

**Usage:**
```bash
while (($#)); do case $1 in
  -d|--depth)
    arg_num "$@"   # Validate numeric
    shift
    MAX_DEPTH="$1"  # Guaranteed to be integer
    ;;
  -C|--context)
    arg_num "$@"
    shift
    CONTEXT_LINES="$1"
    ;;
esac; shift; done
```

**What it validates:**
- Argument exists (`${#@}-1<1`)
- Argument matches integer pattern (`^[0-9]+$`)
- Rejects: negative numbers, decimals, non-numeric text

**Type safety benefit:**
```bash
# Without validation:
-d|--depth) shift; MAX_DEPTH="$1" ;;
# User types: script --depth abc
# Result: MAX_DEPTH='abc' → errors in arithmetic later

# With validation:
-d|--depth) arg2_num "$@"; shift; MAX_DEPTH="$1" ;;
# User types: script --depth abc
# Result: Immediate clear error: '--depth requires a numeric argument'
```

### Complete Example with All Three

```bash
declare -i MAX_DEPTH=5 VERBOSE=0
declare -- OUTPUT_FILE=''
declare -a INPUT_FILES=()

main() {
  while (($#)); do case $1 in
    -o|--output)
      arg2 "$@"                 # String validation
      shift
      OUTPUT_FILE=$1
      ;;

    -d|--depth)
      arg_num "$@"              # Numeric validation
      shift
      MAX_DEPTH=$1
      ;;

    -v|--verbose)
      VERBOSE=1                 # No argument needed
      ;;

    -h|--help)
      noarg "$@"                # Basic check (also valid)
      shift
      HELP_TOPIC=$1
      ;;

    -*)
      die 22 "Invalid option ${1@Q}"
      ;;

    *)
      INPUT_FILES+=("$1")       # Positional argument
      ;;
  esac; shift; done

  readonly -- OUTPUT_FILE MAX_DEPTH VERBOSE

  # ... rest of script
}

# Validation helpers
arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }

arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }

noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }

main "$@"
```

### Choosing the Right Validator

| Validator | Use Case | Example Options |
|-----------|----------|----------------|
| `noarg()` | Simple existence check | `-o FILE`, `-m MSG` |
| `arg2()` | String args, prevent `-` prefix | `--prefix PATH`, `--output FILE` |
| `arg_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT`, `-C NUM` |

### Anti-Patterns

```bash
# ✗ No validation - silent failure
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose → OUTPUT='--verbose'

# ✗ No validation - type error later
-d|--depth) shift; MAX_DEPTH="$1" ;;
# Problem: --depth abc → arithmetic errors: "abc: syntax error"

# ✗ Manual validation - verbose
-p|--prefix)
  if (($# < 2)); then
    die 2 "Option '-p' requires an argument"
  fi
  shift
  PREFIX=$1
  ;;
# Problem: Repetitive, verbose, inconsistent error messages

# ✓ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Error Message Quality

**Note the `${1@Q}` pattern** used in `arg2()` and `arg2_num()`:

```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

See BCS04XX for detailed explanation of the `${parameter@Q}` shell quoting operator.

### Integration with Case Statements

These validators work seamlessly with the standard argument parsing pattern (BCS1001):

```bash
while (($#)); do case $1 in
  -d|--depth)     arg_num "$@"; shift; MAX_DEPTH=$1 ;;
  -v|--verbose)   VERBOSE=1 ;;
  -h|--help)      show_help; exit 0 ;;
  -[dvh]*)        set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              FILES+=("$1") ;;
esac; shift; done
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.
