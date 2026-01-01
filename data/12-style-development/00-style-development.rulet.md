# Style & Development - Rulets
## Code Formatting
- [BCS1201] Use 2 spaces for indentation, never tabs; maintain consistent indentation throughout the script.
- [BCS1201] Keep lines under 100 characters; long file paths and URLs may exceed this limit when necessary.
- [BCS1201] Use line continuation with `\` for long commands that would otherwise exceed line length limits.
## Comments
- [BCS1202] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT (which the code already shows).
- [BCS1202] Good comment patterns: explain non-obvious business rules, document intentional deviations, clarify complex logic, note why specific approaches were chosen, warn about gotchas.
- [BCS1202] Avoid commenting: simple variable assignments, obvious conditionals, standard patterns, self-explanatory code with good naming.
- [BCS1202] Use 80-dash section separators for major script divisions: `# --------------------------------------------------------------------------------`
- [BCS1202] Use only these documentation icons: info `◉`, debug `⦿`, warn `▲`, success `✓`, error `✗`; avoid other emoticons unless justified.
## Blank Line Usage
- [BCS1203] Use one blank line between functions, between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1203] Place blank lines before and after multi-line conditional or loop blocks for visual separation.
- [BCS1203] Avoid multiple consecutive blank lines (one is sufficient); no blank line needed between short, related statements.
## Section Comments
- [BCS1204] Use lightweight section comments with simple `# Description` format (no dashes, no box drawing) to organize code into logical groups.
- [BCS1204] Keep section comments short (2-4 words): `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`.
- [BCS1204] Place section comment immediately before the group it describes; follow with a blank line after the group.
- [BCS1204] Reserve 80-dash separators for major script divisions only; use section comments for grouping related variables, functions, or logical blocks.
## Language Practices
- [BCS1205] Always use `$()` for command substitution, never backticks: `var=$(command)` not `` var=`command` ``
- [BCS1205] Prefer shell builtins over external commands for 10-100x performance improvement: `$((x + y))` not `$(expr $x + $y)`.
- [BCS1205] Use builtin string operations: `${path##*/}` for basename, `${path%/*}` for dirname, `${var^^}` for uppercase, `${var,,}` for lowercase.
- [BCS1205] Use `[[ ]]` instead of `[ ]` for conditionals; use brace expansion `{1..10}` or `for ((i=1; i<=10; i+=1))` instead of `seq`.
- [BCS1205] External commands are acceptable when no builtin equivalent exists: `sha256sum`, `whoami`, `sort`.
## Development Practices
- [BCS1206] ShellCheck is compulsory for all scripts; use `#shellcheck disable=SC####` only for documented exceptions with reason comments.
- [BCS1206] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1206] Use defensive programming: provide default values with `: "${VAR:=default}"`, validate inputs early with `[[ -n "$1" ]] || die 1 'Argument required'`.
- [BCS1206] Minimize subshells, use built-in string operations, batch operations when possible, use process substitution over temp files.
- [BCS1206] Make functions testable: use dependency injection for external commands, support verbose/debug modes, return meaningful exit codes.
## Debugging
- [BCS1207] Implement debug mode with `declare -i DEBUG="${DEBUG:-0}"` and enable trace with `((DEBUG)) && set -x ||:`
- [BCS1207] Use enhanced PS4 for better trace output: `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '`
- [BCS1207] Implement conditional debug output: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`
- [BCS1207] Run scripts with debug output using: `DEBUG=1 ./script.sh`
## Dry-Run Mode
- [BCS1208] Declare dry-run flag as `declare -i DRY_RUN=0`; parse with `-n|--dry-run) DRY_RUN=1 ;;` and `-N|--not-dry-run) DRY_RUN=0 ;;`
- [BCS1208] In functions that modify state: check `((DRY_RUN))` first, display preview message with `[DRY-RUN]` prefix using `info`, return 0 early.
- [BCS1208] Dry-run pattern maintains identical control flow—same function calls, same logic paths—making it easy to verify logic without side effects.
## Testing Support
- [BCS1209] Use dependency injection for testability: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` then override in tests.
- [BCS1209] Implement test mode flag: `declare -i TEST_MODE="${TEST_MODE:-0}"` with conditional behavior for test vs production paths.
- [BCS1209] Use assert function pattern: `assert() { [[ "$1" == "$2" ]] || { >&2 echo "ASSERT FAIL: ${3:-Assertion failed}"; return 1; }; }`
- [BCS1209] Implement test runner: iterate over functions matching `test_*` pattern, track passed/failed counts, return `((failed == 0))`.
## Progressive State Management
- [BCS1210] Declare all boolean flags at the top with initial values: `declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0`
- [BCS1210] Use separate flags for user intent vs. runtime state: `BUILTIN_REQUESTED` tracks original request, `INSTALL_BUILTIN` tracks current state.
- [BCS1210] Apply state changes in logical order: parse → validate → execute; progressively disable features when prerequisites fail or operations error.
- [BCS1210] Never modify flags during execution phase—only in setup/validation; execute actions based on final flag state.
- [BCS1210] Use fail-safe pattern: `((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0` disables feature on failure.
