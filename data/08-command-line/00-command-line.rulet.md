# Command-Line Arguments - Rulets
## Standard Parsing Pattern
- [BCS0801] Use `while (($#)); do case $1 in ... esac; shift; done` for argument parsing; prefer arithmetic test `(($#))` over `[[ $# -gt 0 ]]` for efficiency.
- [BCS0801] Support both short and long options with pipe patterns: `-v|--verbose) VERBOSE+=1 ;;`
- [BCS0801] For options requiring arguments, call `noarg "$@"` before shifting, then capture: `noarg "$@"; shift; OUTPUT=$1`
- [BCS0801] Use `exit 0` for `--help` and `--version` handlers (or `return 0` if inside a function).
- [BCS0801] Catch invalid options with: `-*) die 22 "Invalid option ${1@Q}" ;;`
- [BCS0801] Collect positional arguments in arrays: `*) FILES+=("$1") ;;`
- [BCS0801] The mandatory `shift` at loop end (`esac; shift; done`) is critical—omitting it causes infinite loops.
## Short Option Disaggregation
- [BCS0801,BCS0805] Always include short option bundling support in parsing loops to allow `-vvn` instead of `-v -v -n`: `-[vVhn]*) set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;`
- [BCS0805] List only valid short options in the disaggregation pattern: `-[ovnVh]*` documents valid options and prevents incorrect expansion of unknown options.
- [BCS0805] For performance-critical scripts, use pure bash disaggregation (68% faster): `local -- opt=${1:1}; local -a new_args=(); while ((${#opt})); do new_args+=("-${opt:0:1}"); opt=${opt:1}; done; set -- '' "${new_args[@]}" "${@:2}"`
- [BCS0805] Options requiring arguments cannot be bundled mid-string; place them at end or use separately: `-vno output.txt` works, but `-von file` captures `n` as argument to `-o`.
## Version Output Format
- [BCS0802] Version output must be `scriptname X.Y.Z` without the word "version": `echo "$SCRIPT_NAME $VERSION"; exit 0`
- [BCS0802] Never include "version", "vs", or "v" between script name and version number.
## Argument Validation Helpers
- [BCS0803] Use `noarg()` for basic existence check: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }`
- [BCS0803] Use `arg2()` for enhanced validation with safe quoting: `arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }`
- [BCS0803] Use `arg_num()` for numeric argument validation: `arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }`
- [BCS0803] Always call validators BEFORE `shift`—they must inspect `$2` to work correctly.
- [BCS0803] Validators prevent silent failures like `--output --verbose` where `--verbose` becomes the filename.
## Parsing Location
- [BCS0804] Place argument parsing inside `main()` for better testability, cleaner scoping, and encapsulation.
- [BCS0804] Top-level parsing is acceptable only for simple scripts under 200 lines without a `main()` function.
