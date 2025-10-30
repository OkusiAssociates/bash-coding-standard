# Code Style & Best Practices - Rulets
## Code Formatting
- [BCS1301] Use 2 spaces for indentation (NOT tabs) and maintain consistent indentation throughout.
- [BCS1301] Keep lines under 100 characters when practical; long file paths and URLs can exceed this limit when necessary.
- [BCS1301] Use line continuation with `\` for long commands.
## Comments
- [BCS1302] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT (which the code already shows).
- [BCS1302] Document intentional deviations, non-obvious business rules, edge cases, and why specific approaches were chosen: `# PROFILE_DIR intentionally hardcoded to /etc/profile.d for system-wide bash profile integration`.
- [BCS1302] Avoid commenting simple variable assignments, obvious conditionals, standard patterns, or self-explanatory code.
- [BCS1302] Use standardized emoticons only: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error).
## Blank Lines
- [BCS1303] Use one blank line between functions to create visual separation.
- [BCS1303] Use one blank line between logical sections within functions, after section comments, and between groups of related variables.
- [BCS1303] Place blank lines before and after multi-line conditional or loop blocks; avoid multiple consecutive blank lines (one is sufficient).
- [BCS1303] Never use blank lines between short, related statements.
## Section Comments
- [BCS1304] Use lightweight section comments (`# Description`) without dashes or box drawing to organize code into logical groups.
- [BCS1304] Keep section comments short (2-4 words): `# Default values`, `# Derived paths`, `# Core message function`.
- [BCS1304] Place section comment immediately before the group it describes, followed by a blank line after the group.
- [BCS1304] Reserve 80-dash separators for major script divisions only; use simple section comments for grouping related variables, functions, or logical blocks.
## Language Best Practices
- [BCS1305] Always use `$()` instead of backticks for command substitution: `var=$(command)` not ``var=`command` ``.
- [BCS1305] Prefer shell builtins over external commands for 10-100x performance improvement and better reliability: `$((x + y))` not `$(expr "$x" + "$y")`.
- [BCS1305] Use builtin alternatives: `${var##*/}` for basename, `${var%/*}` for dirname, `${var^^}` for uppercase, `${var,,}` for lowercase, `[[` instead of `[` or `test`.
- [BCS1305] Avoid external commands (`expr`, `basename`, `dirname`, `tr` for case conversion, `seq`) when builtins exist; builtins are guaranteed in bash and require no PATH dependency.
## Development Practices
- [BCS1306] ShellCheck compliance is compulsory for all scripts; use `#shellcheck disable=SCxxxx` only for documented exceptions with explanatory comments.
- [BCS1306] Always end scripts with `#fin` (or `#end`) marker after `main "$@"`.
- [BCS1306] Use defensive programming: default critical variables with `: "${VERBOSE:=0}"`, validate inputs early with `[[ -n "$1" ]] || die 1 'Argument required'`, and guard against unset variables with `set -u`.
- [BCS1306] Minimize subshells, use built-in string operations over external commands, batch operations when possible, and use process substitution over temp files for performance.
- [BCS1306] Make functions testable with dependency injection, support verbose/debug modes, and return meaningful exit codes for testing support.
## Emoticons
- [BCS1307] Standard severity icons: `◉` (info), `⦿` (debug), `▲` (warn), `✗` (error), `✓` (success).
- [BCS1307] Extended icons: `⚠` (caution/important), `☢` (fatal/critical), `↻` (redo/retry/update), `◆` (checkpoint), `●` (in progress), `○` (pending), `◐` (partial).
- [BCS1307] Action icons: `▶` (start/execute), `■` (stop), `⏸` (pause), `⏹` (terminate), `⚙` (settings/config), `☰` (menu/list).
- [BCS1307] Directional icons: `→` (forward/next), `←` (back/previous), `↑` (up/upgrade), `↓` (down/downgrade), `⇄` (swap), `⇅` (sync), `⟳` (processing/loading), `⏱` (timer/duration).
