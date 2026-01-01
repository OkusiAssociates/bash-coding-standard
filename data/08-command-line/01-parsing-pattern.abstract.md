## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all CLI argument parsing.**

### Core Pattern

```bash
while (($#)); do case $1 in
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;
  -o|--output)    noarg "$@"; shift; output=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -[Vhov]*)       #shellcheck disable=SC2046
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

### Essential Helper

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

### Key Rationale

- `(($#))` more efficient than `[[ $# -gt 0 ]]`
- `case` more readable than if/elif chains
- Short bundling: `-vvv` â†' `VERBOSE=3`

### Anti-Patterns

```bash
# âœ— Missing shift â†' infinite loop
esac; done

# âœ— Missing noarg â†' fails silently
-o|--output) shift; output=$1 ;;

# âœ“ Correct
esac; shift; done
-o|--output) noarg "$@"; shift; output=$1 ;;
```

**Ref:** BCS0801
