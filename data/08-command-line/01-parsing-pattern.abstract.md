## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` for all argument parsing.**

### Core Pattern
```bash
while (($#)); do case $1 in
  -o|--out)    noarg "$@"; shift; out=$1 ;;
  -v|--verbose) VERBOSE+=1 ;;
  -V|--version) echo "$NAME $VER"; exit 0 ;;
  -[ovV]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)          die 22 "Invalid option ${1@Q}" ;;
  *)           args+=("$1") ;;
esac; shift; done
```

### Key Rules
- **`noarg`**: `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }` — call before shift for options with args
- **Bundled shorts**: `-[ovV]?*` pattern splits `-vo out` → `-v -o out` iteratively
- **`VERBOSE+=1`**: Allows stacking (`-vvv` = 3)
- **Exit code 22**: EINVAL for invalid options

### Anti-Patterns
```bash
while [[ $# -gt 0 ]]; do  # → while (($#)); do
-o) shift; out=$1 ;;      # → noarg "$@"; shift; out=$1
esac; done                # → esac; shift; done (prevents infinite loop)
```

**Ref:** BCS0801
