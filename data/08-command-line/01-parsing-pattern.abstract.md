## Standard Argument Parsing Pattern

**Use `while (($#)); do case $1 in ... esac; shift; done` pattern with short option support.**

**Core structure:**
```bash
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift; output_file=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -[ovVh]*)       set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              files+=("$1") ;;
esac; shift; done
```

**Rationale:**
- `(($#))` more efficient than `[[ $# -gt 0 ]]` for loop condition
- Case statement more readable/scannable than if/elif chains
- Short bundling pattern (`-[ovVh]*`) enables `-vvv` and `-vno output.txt` syntax
- Mandatory `noarg "$@"` before shift prevents missing-argument errors

**Helper function (required):**
```bash
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }
```

**Anti-patterns:**
- `while [[ $# -gt 0 ]]` ’ use `while (($#))`
- Missing `noarg` before shift ’ causes failures on missing args
- Forgetting `shift` at loop end ’ infinite loop
- if/elif chains ’ use case statement

**Ref:** BCS1001
