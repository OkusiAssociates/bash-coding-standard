# Command-Line Arguments - Rulets

## Standard Parsing Pattern

- [BCS1001] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing; arithmetic test `(($#))` is more efficient than `[[ $# -gt 0 ]]`.
- [BCS1001] Support both short and long options in case branches: `-v|--verbose)` pattern for user flexibility.
- [BCS1001] For options requiring arguments, always call `noarg "$@"` before shifting to validate argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`.
- [BCS1001] Place mandatory `shift` at end of loop after `esac` to advance to next argument; without this, loop runs infinitely.
- [BCS1001] For options that exit immediately (help, version), use `exit 0` and no shift is needed: `-h|--help) show_help; exit 0 ;;`.
- [BCS1001] Implement `noarg()` helper function: `noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }`.
- [BCS1001] Catch invalid options with `-*)` case before positional arguments: `die 22 "Invalid option '$1'"` using exit code 22 (EINVAL).
- [BCS1001] Collect positional arguments in default case: `*) Paths+=("$1") ;;`.

## Short Option Bundling

- [BCS1005] Support short option bundling to allow `-vvn` instead of `-v -v -n` following Unix conventions.
- [BCS1005] Use pure bash method for 68% faster performance with no external dependencies: `opt=${1:1}; new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`.
- [BCS1005] Alternative grep method (slower, external dependency): `-[amLpvqVh]*) #shellcheck disable=SC2046; set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;`.
- [BCS1005] Alternative fold method (marginally faster than grep): `-[amLpvqVh]*) set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}" ;;`.
- [BCS1005] List valid short options explicitly in bundling pattern `-[ovnVh]*` to prevent incorrect disaggregation of unknown options.
- [BCS1005] Document that options requiring arguments must be placed at end of bundle or used separately: `-vno output.txt` works (becomes `-v -n -o output.txt`), but `-von output.txt` fails.

## Version Output

- [BCS1002] Format version output as `scriptname version-number` without the word "version": `echo "$SCRIPT_NAME $VERSION"; exit 0`.
- [BCS1002] Never include the word "version" between script name and version number; this follows GNU standards.

## Argument Validation

- [BCS1003] Validate option arguments with `noarg()`: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option '$1'"; }`.
- [BCS1003] Check that next argument doesn't start with `-` to catch missing arguments: `[[ ${2:0:1} != '-' ]]`.

## Parsing Location

- [BCS1004] Place argument parsing inside `main()` function rather than at top level for better testability, cleaner variable scoping, and encapsulation.
- [BCS1004] Top-level parsing is acceptable only for very simple scripts (< 200 lines) without a `main()` function.
- [BCS1004] Make variables readonly after parsing completes: `readonly -- VERBOSE DRY_RUN output_file`.

## Flag Variables

- [BCS1001] Use integer flags for boolean options: `declare -i VERBOSE=0` with `VERBOSE+=1` for stackable flags like `-vvv`.
- [BCS1001] Use compound assignments for multi-flag options: `-p|--prompt) PROMPT=1; VERBOSE=1 ;;` to enable multiple behaviors.
- [BCS1001] Test boolean flags with arithmetic: `((VERBOSE))` or `((DRY_RUN))`.

## Required Arguments Validation

- [BCS1001,BCS1004] Validate required arguments after parsing completes: `((${#files[@]} > 0)) || die 2 'No input files specified'`.
- [BCS1001,BCS1004] Check for required options: `[[ -n "$output_file" ]] || die 2 'Output file required (use -o)'`.

## Performance Considerations

- [BCS1005] Pure bash disaggregation is ~318 iter/sec vs ~190 iter/sec for grep (68% faster) with no external dependencies or shellcheck warnings.
- [BCS1005] For scripts called frequently or in tight loops, always use pure bash method for short option bundling.
- [BCS1005] grep/fold methods are acceptable when argument parsing happens once at startup and performance is not critical.

## Edge Cases

- [BCS1005] Options requiring arguments cannot be in middle of bundle; document that they should be at end, separate, or use long-form.
- [BCS1005] Use `set -- '' "${new_args[@]}" "${@:2}"` with leading empty string to handle edge case where no options are provided.
- [BCS1001] Invalid option case `-*)` must come after bundling case to catch unrecognized options properly.
