bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
[WARN] BCS0111 line 110: `read_conf()` does not implement the documented cascade-source config pattern and instead does first-match-wins parsing with `grep`/`readarray`; this is an intentional deviation from the recommended reference pattern but is not documented in help/comments as such. Fix: either implement the standard cascade `source` search order, or document that this script uses first-match-wins line-based pattern loading and list the actual search order.

[WARN] BCS0111 lines 114-118: config search order differs from the recommended BCS cascade order, with user config checked first and `/usr/local/etc` last. Fix: either reorder paths to the documented BCS order, or explicitly document this alternate order in help/comments as a deliberate deviation.

[WARN] BCS0201 line 112: `local -- conf_file` is declared without initialization. BCS examples consistently declare strings with an explicit value. Fix: initialize it, e.g. `local -- conf_file=''`.

[WARN] BCS0201 line 136: `local -- path` is declared without initialization. Fix: initialize it, e.g. `local -- path=''`.

[WARN] BCS0201 line 139: `local -- spec` is declared without initialization. Fix: initialize it, e.g. `local -- spec=''`.

[WARN] BCS0301 lines 213-214: static text is wrapped in double quotes where only literal text plus separately quoted expansions would better follow BCS quoting style. Fix: prefer forms like `info 'Searching directory '"${path@Q}"', depth '"$max_depth"` and `info "$(decp find_expr)"` only when command substitution requires it.

[WARN] BCS0301 line 239: static text is wrapped in double quotes. Fix: prefer `info 'No matching files found in '"${path@Q}"`.

[WARN] BCS0502 line 146: `case $1 in` leaves the case expression unguarded under `set -u`; although protected by `(($#))`, the recommended pattern is `case ${1:-} in`. Fix: change to `while (($#)); do case ${1:-} in`.

[WARN] BCS0704 line 75: help text uses `Usage: $SCRIPT_NAME [Options] [path ...]`; BCS usage examples standardize on uppercase `OPTIONS`. Fix: change to `Usage: $SCRIPT_NAME [OPTIONS] [path ...]`.

[WARN] BCS0806 lines 170-172: standard option letters are reassigned: `-n` is used for prompt instead of dry-run, and `-N` for no-prompt instead of not-dry-run. Fix: avoid repurposing standard letters; use different non-standard flags for prompt toggling.

[WARN] BCS0806 line 173: `-v|--verbose` increments verbosity instead of acting as the standard boolean verbose toggle. Fix: if following BCS standard options, make `-v` set `VERBOSE=1` and use another option if multi-level verbosity is needed.

[WARN] BCS1202 lines 17-17: comment paraphrases the declaration below (`DELETE_FILES`) rather than adding non-obvious information. Fix: remove it or replace with rationale/constraint information not evident from the code.

[WARN] BCS1202 lines 23-23: comment restates the immediately following TTY test. Fix: remove it or replace with non-obvious rationale.

[WARN] BCS1202 lines 55-55: comment paraphrases the helper function `s()`. Fix: remove it or replace with a constraint/rationale comment.

[WARN] BCS1202 lines 110-110: comment paraphrases the purpose of `read_conf()`. Fix: remove it or replace with useful non-obvious context, such as noting that this is a first-match-wins line parser rather than BCS cascade sourcing.

[WARN] BCS1202 lines 130-130: comment paraphrases `read_conf ||:`. Fix: remove it or replace with a comment explaining why missing config is intentionally non-fatal.

[WARN] BCS1202 lines 133-133: comment paraphrases the following local default declarations. Fix: remove it.

[WARN] BCS1202 lines 188-188: comment paraphrases the default-path assignment below. Fix: remove it.

[WARN] BCS1202 lines 195-195: comment paraphrases the combination of spec arrays below. Fix: remove it.

[WARN] BCS1202 lines 199-199: comment paraphrases the `find_expr` construction below. Fix: remove it.

[WARN] BCS1202 lines 203-203: comment paraphrases `unset 'find_expr[-1]'`. Fix: remove it.

[WARN] BCS1202 lines 206-206: comment paraphrases the upcoming loop over paths. Fix: remove it.

[WARN] BCS1202 lines 215-215: comment paraphrases the `readarray` command below. Fix: remove it.

[WARN] BCS1202 lines 227-227: comment paraphrases the `if ((fnd))` test below. Fix: remove it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0111 | recommended | [WARN] | 110 | `read_conf()` deviates from the recommended cascade-source config pattern without documenting the deviation |
| BCS0111 | recommended | [WARN] | 114-118 | Config search order differs from the recommended BCS order |
| BCS0201 | style | [WARN] | 112 | String local `conf_file` declared without initialization |
| BCS0201 | style | [WARN] | 136 | String local `path` declared without initialization |
| BCS0201 | style | [WARN] | 139 | String local `spec` declared without initialization |
| BCS0301 | style | [WARN] | 213-214 | Double quotes used for mostly static status strings |
| BCS0301 | style | [WARN] | 239 | Double quotes used for static status string |
| BCS0502 | recommended | [WARN] | 146 | `case` expression uses `$1` instead of `${1:-}` |
| BCS0704 | style | [WARN] | 75 | Help usage line uses `[Options]` instead of `[OPTIONS]` |
| BCS0806 | recommended | [WARN] | 170-172 | Standard option letters `-n`/`-N` are repurposed for prompt behavior |
| BCS0806 | recommended | [WARN] | 173 | `-v` is used as incrementing verbosity rather than standard verbose toggle |
| BCS1202 | style | [WARN] | 17 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 23 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 55 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 110 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 130 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 133 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 188 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 195 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 199 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 203 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 206 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 215 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 227 | Comment paraphrases code |
bcs: ◉ Tokens: in=26985 out=1690
bcs: ◉ Elapsed: 25s
