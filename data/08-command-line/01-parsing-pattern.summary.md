## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

```bash
while (($#)); do case $1 in
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth=$1 ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; ((VERBOSE)) || VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern components:**

| Component | Purpose |
|-----------|---------|
| `while (($#))` | Arithmetic test, more efficient than `[[ $# -gt 0 ]]` |
| `case $1 in` | Pattern matching, cleaner than if/elif chains |
| `noarg "$@"; shift` | Validate argument exists, then shift to capture value |
| `VERBOSE+=1` | Stackable flags: `-vvv` = `VERBOSE=3` |
| `-[opts]*` branch | Short option bundling: `-vpL` �' `-v -p -L` |
| `die 22` | Exit code 22 (EINVAL) for invalid options |
| `*)` | Default: collect positional arguments |
| `esac; shift; done` | Mandatory shift after each iteration |

**The `noarg` helper:**

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

Validates option has argument before shifting. `(($# > 1))` ensures at least 2 args remain.

**Short option bundling mechanism:**

```bash
-[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

1. `${1:1}` removes leading dash (`-vpL` �' `vpL`)
2. `grep -o .` splits to individual characters
3. `printf -- "-%c "` adds dash before each
4. `set --` replaces argument list with expanded options

**Complete example:**

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Default values
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...

Options:
  -o, --output FILE  Output file (required)
  -v, --verbose      Verbose output
  -n, --dry-run      Dry-run mode
  -V, --version      Show version
  -h, --help         Show this help
EOF
}

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift
                    output_file=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    -[ovnVh]*)    #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option ${1@Q}" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE)) && echo "Processing ${file@Q}" ||:
  done
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - verbose loop condition
while [[ $# -gt 0 ]]; do
# ✓ Correct
while (($#)); do

# ✗ Wrong - missing noarg validation
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - missing shift causes infinite loop
esac; done
# ✓ Correct
esac; shift; done

# ✗ Wrong - if/elif chains
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct - case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
```

**Rationale:** Consistent structure across scripts, handles all option types, validates arguments safely, case statements more readable than conditionals, arithmetic tests more efficient.
