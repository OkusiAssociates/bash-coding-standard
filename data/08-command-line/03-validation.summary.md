## Argument Validation

**Use validation helpers to ensure option arguments exist and are valid types before processing.**

**Rationale:** Prevents silent failures (e.g., `--output --verbose` where filename missing becomes `OUTPUT='--verbose'`), provides clear error messages, validates data types before arithmetic use.

### Three Validation Patterns

**1. `noarg()` - Basic Existence Check**

```bash
noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }
```

Checks: at least 2 arguments remain, next argument doesn't start with `-`.

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

Validates integer pattern (`^[0-9]+$`). Rejects negative numbers, decimals, non-numeric text.

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
| `arg_num()` | Numeric args requiring integers | `--depth NUM`, `--retries COUNT` |

### Anti-Patterns

```bash
# ✗ No validation - silent failure
-o|--output) shift; OUTPUT="$1" ;;
# Problem: --output --verbose �' OUTPUT='--verbose'

# ✗ No validation - type error later
-d|--depth) shift; MAX_DEPTH="$1" ;;
# Problem: --depth abc �' arithmetic errors: "abc: syntax error"

# ✗ Manual validation - verbose and repetitive
-p|--prefix)
  if (($# < 2)); then
    die 2 "Option '-p' requires an argument"
  fi
  shift
  PREFIX=$1
  ;;

# ✓ Use helpers
-p|--prefix) arg2 "$@"; shift; PREFIX=$1 ;;
```

### Edge Cases

**Error message quality with `${1@Q}`:**
```bash
# User input: script '--some-weird$option' value
# With ${1@Q}: error: '--some-weird$option' requires argument
# Without:     error: --some-weird (crashes or expands $option)
```

**Critical:** Always call validator BEFORE `shift` - validator needs to inspect `$2`.

See BCS04XX for `${parameter@Q}` shell quoting operator details.
