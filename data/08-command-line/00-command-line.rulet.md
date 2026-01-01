# Command-Line Arguments - Rulets
## Standard Parsing Pattern
- [BCS0801] Use `while (($#)); do case $1 in ... esac; shift; done` as the canonical argument parsing structure; `(($#))` is more efficient than `while [[ $# -gt 0 ]]`.
- [BCS0801] Support both short and long options for every option: `-V|--version`, `-h|--help`, `-v|--verbose`.
- [BCS0801] For options with arguments, always call `noarg "$@"` before `shift` to validate the argument exists: `-o|--output) noarg "$@"; shift; output_file=$1 ;;`
- [BCS0801] For options that exit immediately (`-V`, `-h`), use `exit 0` (or `return 0` inside a function) without needing an additional shift.
- [BCS0801] Use `VERBOSE+=1` for stackable verbose flags allowing `-vvv` to set `VERBOSE=3`; requires prior `declare -i VERBOSE=0`.
- [BCS0801] Always include a mandatory `shift` at the end of the loop after `esac` to prevent infinite loops.
- [BCS0801] Catch invalid options with `-*) die 22 "Invalid option ${1@Q}" ;;` using exit code 22 (EINVAL).
- [BCS0801] Collect positional arguments in a default case: `*) files+=("$1") ;;`
## The noarg Helper
- [BCS0801] Define `noarg() { (($# > 1)) || die 2 "Option ${1@Q} requires an argument"; }` to validate option arguments exist.
- [BCS0801] Always call `noarg "$@"` BEFORE `shift` since it needs to inspect `$2` for the argument value.
## Version Output Format
- [BCS0802] Use format `<script_name> <version_number>` for version output: `echo "$SCRIPT_NAME $VERSION"` → "myscript 1.2.3".
- [BCS0802] Never include the words "version", "vs", or "v" between script name and version number.
## Argument Validation
- [BCS0803] Use `noarg()` for basic existence checking: `noarg() { (($# > 1)) && [[ ${2:0:1} != '-' ]] || die 2 "Missing argument for option ${1@Q}"; }`
- [BCS0803] Use `arg2()` for enhanced validation that prevents options being captured as values: `arg2() { ((${#@}-1<1)) || [[ "${2:0:1}" == '-' ]] && die 2 "${1@Q} requires argument" ||:; }`
- [BCS0803] Use `arg_num()` for numeric argument validation: `arg_num() { ((${#@}-1<1)) || [[ ! "$2" =~ ^[0-9]+$ ]] && die 2 "${1@Q} requires a numeric argument" ||:; }`
- [BCS0803] Never shift before validating—always call the validator with `"$@"` first, then shift, then capture the value.
- [BCS0803] Use `${1@Q}` shell quoting in error messages to safely display option names with special characters.
## Parsing Location
- [BCS0804] Place argument parsing inside the `main()` function for better testability, cleaner scoping, and encapsulation.
- [BCS0804] For simple scripts (<200 lines) without a `main()` function, top-level parsing is acceptable.
- [BCS0804] Make parsed variables readonly after parsing is complete: `readonly -- VERBOSE DRY_RUN output_file`
## Short Option Bundling (Disaggregation)
- [BCS0805] Always include short option bundling support in argument parsing loops to allow `-vvn` instead of `-v -v -n`.
- [BCS0805] List all valid short options explicitly in the bundling pattern: `-[ovnVh]*)` to prevent disaggregation of unknown options.
- [BCS0805] Place the bundling case before the `-*)` invalid option case so unknown bundled options fall through correctly.
- [BCS0805] Grep method (one-liner): `set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"` with `#shellcheck disable=SC2046`.
- [BCS0805] Fold method (alternative): `set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"` with `#shellcheck disable=SC2046`.
- [BCS0805] Pure bash method (recommended, 68% faster): use a while loop with `opt=${1:1}` and `new_args+=("-${opt:0:1}")` to build the expanded argument array.
- [BCS0805] Options requiring arguments cannot be bundled in the middle; document that they should be at the end of a bundle or used separately.
- [BCS0805] For high-performance scripts, prefer the pure bash method to avoid external command overhead.
## Anti-Patterns
- [BCS0801] Never use `while [[ $# -gt 0 ]]`; use `while (($#))` instead.
- [BCS0801] Never use if/elif chains for option parsing; use case statements for readability.
- [BCS0801] Never forget the `shift` at the end of the parsing loop—this causes infinite loops.
- [BCS0803] Never shift before validating option arguments; validation must inspect `$2`.
- [BCS0803] Never skip validation—`-o|--output) shift; OUTPUT=$1 ;;` silently captures `--verbose` as the filename if user forgets the argument.
