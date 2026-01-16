## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all CLI parsing.**

### Core Pattern

```bash
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift; output=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -V|--version)   echo "$VERSION"; exit 0 ;;
  -[ovV]?*)       set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

### Key Components

- **`noarg()`**: `(($# > 1)) || die 2 "Option ${1@Q} requires an argument"` â†' validate before shift
- **Bundling**: `-[opts]?*)` splits `-vvn` â†' `-v -vn` â†' `-v -v -n` iteratively
- **Exit handlers**: `-V`, `-h` print and `exit 0` immediately
- **Default case**: `*)` collects positional args to array

### Anti-Patterns

- `while [[ $# -gt 0 ]]` â†' use `while (($#))`
- Missing `noarg "$@"` before shift â†' silent failures
- Missing `shift` after `esac` â†' infinite loop

### Rationale

1. `(($#))` arithmetic test more efficient than `[[ ]]`
2. Case statements more readable than if/elif chains
3. Bundling support (`-vvn`) follows Unix conventions

**Ref:** BCS0801
