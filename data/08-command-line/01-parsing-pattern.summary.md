## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

NOTE: Short-option splitting should be implemented in *all* scripts that have more than 2 short options.

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

  -p|--prompt)    PROMPT=1; VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern components:**

**Loop structure:** `while (($#)); do ... done` - Arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`, exits when no arguments remain.

**Options with arguments:**
```bash
-m|--depth)     noarg "$@"; shift
                max_depth=$1 ;;
```
- `noarg "$@"` validates argument exists
- First `shift` moves to value, second shift (loop end) moves past it

**Flag options:**
```bash
-v|--verbose)   VERBOSE+=1 ;;
```
- No shift needed (handled at loop end)
- `VERBOSE+=1` allows stacking: `-vvv` = `VERBOSE=3`

**Exit options:**
```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
```
- Print and exit, no shift needed

**Short option bundling:**
```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```
- Allows `-vpL` instead of `-v -p -L`
- `${1:1}` removes dash, `grep -o .` splits characters, `printf -- '-%c '` adds dash to each
- `set --` replaces argument list with expanded options

**Invalid option:** `die 22 "Invalid option ${1@Q}"` catches unrecognized options (exit code 22 = EINVAL).

**Positional arguments:** `*)` case appends to array for later processing.

**Mandatory shift:** `esac; shift; done` - Without this, infinite loop!

**The `noarg` helper:**

```bash
noarg() {
  (($# > 1)) || die 2 "Option ${1@Q} requires an argument"
}
```

Validates option has argument before shifting. Check `(($# > 1))` ensures at least 2 args (option + value).

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

# ============================================================================
# Utility Functions
# ============================================================================

error() {
  >&2 echo "$SCRIPT_NAME: error: $*"
}

die() {
  local -i exit_code=$1
  shift
  (($#)) && error "$@"
  exit "$exit_code"
}

noarg() {
  (($# > 1)) || die 2 "Option ${1@Q} requires an argument"
}

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...

Process files with various options.

Options:
  -o, --output FILE  Output file (required)
  -v, --verbose      Verbose output
  -n, --dry-run      Dry-run mode
  -V, --version      Show version
  -h, --help         Show this help

Examples:
  $SCRIPT_NAME -o output.txt file1.txt file2.txt
  $SCRIPT_NAME -v -n -o result.txt *.txt
EOF
}

# ============================================================================
# Main Function
# ============================================================================

main() {
  # Parse arguments
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift
                    output_file=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; return 0 ;;
    -h|--help)      show_help; return 0 ;;

    # Short option bundling support
    -[ovnVh]*)    #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option ${1@Q}'" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  # Make variables readonly after parsing
  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  # Validate required arguments
  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  # Use parsed arguments
  ((VERBOSE)) && echo "Processing ${#files[@]} files" ||:
  ((DRY_RUN)) && echo '[DRY RUN] Would write to:' "$output_file" ||:

  # Process files (example logic)
  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE)) && echo "Processing ${file@Q}" ||:
    # Processing logic here
  done

  ((VERBOSE)) && echo "Would write results to: $output_file" ||:
}

main "$@"

#fin
```

**Short option bundling examples:**

```bash
# These are equivalent:
./script -v -n -o output.txt file.txt
./script -vno output.txt file.txt

# These are equivalent:
./script -v -v -v file.txt
./script -vvv file.txt

# Mixed long and short:
./script --verbose -no output.txt --dry-run file.txt
```

**Anti-patterns:**

```bash
#  Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient

#  Correct
while (($#)); do

#  Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!

#  Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

#  Wrong - forgetting shift at loop end
while (($#)); do case $1 in
  ...
esac; done  # Infinite loop!

#  Correct
while (($#)); do case $1 in
  ...
esac; shift; done

#  Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
  VERBOSE+=1
elif [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
  show_help
  ...
fi

#  Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -h|--help)    show_help; exit 0 ;;
  ...
esac
```

**Rationale:** Consistent structure, handles all option types, validates before use, case statement more readable than if/elif chains, arithmetic test more efficient, supports Unix conventions (bundling, short/long options).
