# Code Style & Best Practices - Rulets

## Code Formatting

- [BCS1301] Use 2 spaces for indentation, never tabs, and maintain consistent indentation throughout the script.
- [BCS1301] Keep lines under 100 characters when practical; long file paths and URLs may exceed this limit when necessary using line continuation with `\`.

## Comments

- [BCS1302] Focus comments on explaining WHY (rationale, business logic, non-obvious decisions) rather than WHAT the code already shows.
- [BCS1302] Use comments to explain non-obvious business rules, edge cases, intentional deviations, complex logic, why specific approaches were chosen, and subtle gotchas or side effects.
- [BCS1302] Avoid commenting simple variable assignments, obvious conditionals, standard patterns already documented, or self-explanatory code with good naming.
- [BCS1302,BCS1307] In documentation use standardized icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error); avoid other emoticons unless justified.

## Blank Line Usage

- [BCS1303] Use one blank line between functions, between logical sections within functions, after section comments, between groups of related variables, and before/after multi-line conditional or loop blocks.
- [BCS1303] Avoid multiple consecutive blank lines; one blank line is sufficient for visual separation.
- [BCS1303] No blank line needed between short, related statements.

## Section Comments

- [BCS1304] Use simple `# Description` format (no dashes, no box drawing) for section comments to organize code into logical groups.
- [BCS1304] Keep section comments short and descriptive (2-4 words typically), place immediately before the group described, and follow with a blank line after the group.
- [BCS1304] Reserve 80-dash separators (`# ---...---`) for major script divisions only; use lightweight section comments for grouping related variables, functions, or logical blocks.
- [BCS1304] Common section comment patterns: `# Default values`, `# Derived paths`, `# Core message function`, `# Conditional messaging functions`, `# Unconditional messaging functions`, `# Helper functions`, `# Business logic`, `# Validation functions`.

## Language Best Practices

- [BCS1305] Always use `$()` for command substitution instead of backticks; it's more readable, nests naturally without escaping, and has better editor support.
- [BCS1305] Prefer shell builtins over external commands: use `$(())` instead of `expr`, `${var##*/}` instead of `basename`, `${var%/*}` instead of `dirname`, `${var^^}` or `${var,,}` instead of `tr` for case conversion, and `[[` instead of `[` or `test`.
- [BCS1305] Builtins are 10-100x faster than external commands because they avoid process creation, have no PATH dependency, and are guaranteed in bash.

## Development Practices

- [BCS1306] ShellCheck is compulsory for all scripts; use `#shellcheck disable=SCxxxx` only for documented exceptions with explanatory comments.
- [BCS1306] Always end scripts with `#fin` or `#end` marker after the `main "$@"` invocation.
- [BCS1306] Use defensive programming: set default values for critical variables with `: "${VAR:=default}"`, validate inputs early, and guard against unset variables with `set -u`.
- [BCS1306] Optimize performance by minimizing subshells, using built-in string operations over external commands, batching operations when possible, and using process substitution over temp files.
- [BCS1306] Make functions testable with dependency injection for external commands, support verbose/debug modes, and return meaningful exit codes.

## Emoticons

- [BCS1307] Standard severity icons: `◉` (info), `⦿` (debug), `▲` (warn), `✗` (error), `✓` (success).
- [BCS1307] Extended icons: `⚠` (caution/important), `☢` (fatal/critical), `↻` (redo/retry/update), `◆` (checkpoint), `●` (in progress), `○` (pending), `◐` (partial).
- [BCS1307] Action icons: `▶` (start/execute), `■` (stop), `⏸` (pause), `⏹` (terminate), `⚙` (settings/config), `☰` (menu/list).
- [BCS1307] Directional icons: `→` (forward/next), `←` (back), `↑` (up/upgrade), `↓` (down/downgrade), `⇄` (swap), `⇅` (sync/bidirectional).
