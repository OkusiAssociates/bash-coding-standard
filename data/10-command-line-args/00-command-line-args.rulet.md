# Command-Line Arguments - Rulets
## Standard Parsing Pattern
- [BCS1001] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing - arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`.
- [BCS1001] Support both short and long options in case patterns: `-v|--verbose)` for user flexibility.
- [BCS1001] Call `noarg "$@"` before shifting when an option requires an argument to validate the argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`.
- [BCS1001] Place mandatory `shift` at end of loop after `esac` to advance to next argument - without this, infinite loop results.
- [BCS1001] Use `case $1 in` instead of if/elif chains for cleaner, more scannable option handling.
- [BCS1001] Implement `noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }` to validate option arguments exist before capturing them.
## Options and Arguments
- [BCS1001] For options with arguments, use pattern: `noarg "$@"; shift; variable=$1 ;;` - first shift moves to value, second shift (at loop end) moves past it.
- [BCS1001] For boolean flags, just set variables without shifting: `-v|--verbose) VERBOSE+=1 ;;` - shift happens at loop end.
- [BCS1001] For options that exit immediately, use `exit 0` and no shift needed: `-V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;`.
- [BCS1001] Use `+=1` for stackable options to allow `-vvv` to set `VERBOSE=3`.
- [BCS1001] Catch invalid options with `-*) die 22 "Invalid option '$1'" ;;` before positional argument case.
- [BCS1001] Collect positional arguments in default case: `*) files+=("$1") ;;`.
## Short Option Bundling
- [BCS1005] Support short option bundling with pattern `-[ovnVh]*)` that explicitly lists valid short options - prevents incorrect disaggregation of unknown options.
- [BCS1005] Use pure bash method for 68% performance improvement (318 iter/sec vs 190 iter/sec) and no external dependencies: `opt=${1:1}; new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`.
- [BCS1005] Alternative grep method (current standard): `set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"` requires `#shellcheck disable=SC2046`.
- [BCS1005] Alternative fold method: `set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"` is 3% faster than grep but still requires external command.
- [BCS1005] Place bundling case before `-*)` invalid option handler and after all explicit option cases.
- [BCS1005] Options requiring arguments cannot be in middle of bundle: `-vno output.txt` works (expands to `-v -n -o output.txt`), but `-von output.txt` fails (`-o` captures "n" as argument).
## Version Output
- [BCS1002] Format version output as `$SCRIPT_NAME $VERSION` without the word "version" between them: `echo "$SCRIPT_NAME $VERSION"; exit 0` produces "myscript 1.2.3".
## Validation
- [BCS1003] Validate required arguments after parsing loop, before making variables readonly: `((${#files[@]} > 0)) || die 2 'No input files specified'`.
- [BCS1003] Validate option values and detect conflicts: `[[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"`.
## Parsing Location
- [BCS1004] Place argument parsing inside `main()` function for better testability, cleaner scoping, and easier mocking - not at top level.
- [BCS1004] Make variables readonly after parsing completes: `readonly -- VERBOSE DRY_RUN output_file` prevents accidental modification.
- [BCS1004] For very simple scripts (<200 lines) without `main()`, top-level parsing is acceptable.
