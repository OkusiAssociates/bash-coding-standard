# Style & Development - Rulets
## Code Formatting
- [BCS1201] Use 2 spaces for indentation, never tabs; maintain consistent indentation throughout the script.
- [BCS1201] Keep lines under 100 characters when practical; long file paths and URLs may exceed this limit when necessary.
- [BCS1201] Use line continuation with `\` for long commands that exceed the line length limit.
## Comments
- [BCS1202] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT the code already shows.
- [BCS1202] Good comment patterns: explain non-obvious business rules, document intentional deviations, clarify complex logic, note why specific approaches were chosen, warn about subtle gotchas.
- [BCS1202] Avoid commenting simple variable assignments, obvious conditionals, standard patterns documented in the style guide, or self-explanatory code with good naming.
- [BCS1202] Use standardized documentation icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error); avoid other emoticons unless justified.
- [BCS1202] Use 80-dash separator lines (`# ----...----`) only for major script divisions.
## Blank Lines
- [BCS1203] Use one blank line between functions, between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1203] Add blank lines before and after multi-line conditional or loop blocks.
- [BCS1203] Avoid multiple consecutive blank lines (one is sufficient); no blank line needed between short, related statements.
## Section Comments
- [BCS1204] Use simple `# Description` format for section comments (no dashes, no box drawing); keep them short and descriptive (2-4 words typically).
- [BCS1204] Place section comment immediately before the group it describes; follow the group with a blank line before the next section.
- [BCS1204] Common section comment patterns: `# Default values`, `# Derived paths`, `# Core message function`, `# Helper functions`, `# Business logic`, `# Validation functions`.
- [BCS1204] Reserve 80-dash separators for major script divisions only; use lightweight section comments for organizing code into logical groups.
## Language Practices
- [BCS1205] Always use `$()` instead of backticks for command substitution: `var=$(command)` not `` var=`command` ``.
- [BCS1205] Prefer shell builtins over external commands for performance (10-100x faster) and reliability: `$((x + y))` not `$(expr $x + $y)`, `${var^^}` not `$(echo "$var" | tr a-z A-Z)`.
- [BCS1205] Common builtin replacements: `${path##*/}` for basename, `${path%/*}` for dirname, `${var^^}` or `${var,,}` for case conversion, `[[ ]]` for test/`[`, brace expansion `{1..10}` for seq.
## Development Practices
- [BCS1206] ShellCheck is compulsory for all scripts; use `#shellcheck disable=...` only for documented exceptions with explanatory comments.
- [BCS1206] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1206] Use defensive programming: provide default values for critical variables with `: "${VAR:=default}"`, validate inputs early, always use `set -u`.
- [BCS1206] Minimize subshells, use built-in string operations over external commands, batch operations when possible, use process substitution over temp files.
- [BCS1206] Make functions testable: use dependency injection for external commands, support verbose/debug modes, return meaningful exit codes.
## Debugging
- [BCS1207] Declare debug flag with default: `declare -i DEBUG=${DEBUG:-0}` and enable trace mode conditionally: `((DEBUG)) && set -x ||:`.
- [BCS1207] Set enhanced PS4 for better trace output: `export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '`.
- [BCS1207] Implement conditional debug function: `debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }`.
- [BCS1207] Enable debug mode at runtime: `DEBUG=1 ./script.sh`.
## Dry-Run Pattern
- [BCS1208] Declare dry-run flag: `declare -i DRY_RUN=0` and parse from command-line: `-n|--dry-run) DRY_RUN=1 ;;`.
- [BCS1208] Pattern structure: check `((DRY_RUN))` at function start, display preview message with `[DRY-RUN]` prefix using `info`, return 0 early without performing actual operations.
- [BCS1208] Show detailed preview of what would happen: `info '[DRY-RUN] Would install:' "  $BIN_DIR/tool1" "  $BIN_DIR/tool2"`.
- [BCS1208] Dry-run maintains identical control flow (same function calls, same logic paths) to verify logic without side effects.
## Testing Support
- [BCS1209] Use dependency injection for testing: `declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }` then override in tests: `FIND_CMD() { echo 'mocked_file.txt'; }`.
- [BCS1209] Implement test mode flag: `declare -i TEST_MODE="${TEST_MODE:-0}"` with conditional behavior for test data directories and disabled destructive operations.
- [BCS1209] Implement assert function comparing expected vs actual values with descriptive failure messages: `assert "$expected" "$actual" 'message'`.
- [BCS1209] Test runner pattern: find all `test_*` functions with `declare -F | awk '$3 ~ /^test_/ {print $3}'`, execute each, track passed/failed counts, exit with `((failed == 0))`.
## Progressive State Management
- [BCS1210] Declare all boolean flags at the top with initial values, then progressively adjust based on runtime conditions.
- [BCS1210] Separate user intent tracking from runtime state: `BUILTIN_REQUESTED=1` (what user asked for) vs `INSTALL_BUILTIN=0` (what will actually happen).
- [BCS1210] Apply state changes in logical order: parse → validate → execute; never modify flags during execution phase.
- [BCS1210] Disable features when prerequisites fail: `((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0`.
- [BCS1210] Execute actions based on final flag state: `((INSTALL_BUILTIN)) && install_builtin ||:` runs only if flag remains enabled after all checks.
