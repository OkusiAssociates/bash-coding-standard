## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in...esac; shift; done` for all argument parsing.**

### Core Pattern

```bash
while (($#)); do case $1 in
  -o|--output)  noarg "$@"; shift; output=$1 ;;
  -v|--verbose) VERBOSE+=1 ;;
  -V|--version) echo "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -[ovVh]*)     set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            files+=("$1") ;;
esac; shift; done
```

### Key Elements

- **Options with args**: `noarg "$@"; shift` before capturing value
- **Flags**: Set variable directly, loop-end shift handles advancement
- **Short bundling**: `-[opts]*` pattern splits `-vvv` �' `-v -v -v`
- **noarg helper**: `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }`

### Anti-Patterns

```bash
# ✗ Missing noarg before shift
-o|--output) shift; output=$1 ;;        # Fails silently if no arg

# ✗ Missing loop-end shift
esac; done                              # Infinite loop!

# ✓ Correct
-o|--output) noarg "$@"; shift; output=$1 ;;
esac; shift; done
```

### Rationale

- `(($#))` more efficient than `[[ $# -gt 0 ]]`
- Case statement more readable than if/elif chains
- Uniform shift at loop end handles all branches

**Ref:** BCS0801
