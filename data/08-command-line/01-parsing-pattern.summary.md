## Standard Argument Parsing Pattern

**Complete pattern with short option support:**

```bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth=$1 ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; ((VERBOSE)) || VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;

  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option ${1@Q}" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

**Pattern breakdown:**

| Element | Purpose |
|---------|---------|
| `while (($#))` | Arithmetic test, true while args remain (more efficient than `[[ $# -gt 0 ]]`) |
| `case $1 in` | Pattern matching for options, supports multiple patterns: `-a\|--add` |
| `noarg "$@"; shift` | Validate arg exists before capturing value |
| `VERBOSE+=1` | Allows stacking: `-vvv` = `VERBOSE=3` |
| `-V\|--version)` | Exit immediately with `exit 0` (or `return 0` in functions) |
| `esac; shift; done` | Mandatory shift at end prevents infinite loop |

**Short option bundling (always include):**

```bash
-[VhamLpvq]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

Splits `-vpL file` �' `-v -p -L file`. Mechanism: `${1:1}` removes dash, `grep -o .` splits chars, `printf -- "-%c "` adds dashes, `set --` replaces arg list.

**The `noarg` helper:**

```bash
noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }
```

Validates option has argument before shift. `./script -m` (missing value) �' "Option '-m' requires an argument"

**Anti-patterns:**

```bash
# ✗ Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient
# ✓ Correct
while (($#)); do

# ✗ Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!
# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - forgetting shift at loop end
esac; done  # Infinite loop!
# ✓ Correct
esac; shift; done

# ✗ Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
# ✓ Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
```

**Rationale:** Consistent structure for all scripts. Handles options with/without arguments and bundled shorts. Safe argument validation. Case statement more readable than if/elif. Arithmetic `(($#))` faster than `[[ ]]`. Follows Unix conventions.
