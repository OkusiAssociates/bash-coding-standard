bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
[WARN] BCS0111 line 110: The documented config handling says “BCS0111 search order”, but `read_conf()` uses a different order and the help text does not fully document the actual order used by the function. BCS0111 allows deviations only when documented; update the help text to match the real search order, or reorder `search_paths` to match the documented behavior.

[WARN] BCS0202 line 158: `DELETE_FILES` is modified inside `main()` without a local declaration, so the function writes to a global variable. If this is intentional state, document it clearly; otherwise copy to a local array at function start and modify that local array instead.

[WARN] BCS0301 line 165: Static text inside the error message uses double quotes instead of single quotes. Use single quotes for the literal part and concatenate the expanded value, e.g. `die 22 'Option -m|--depth requires a numeric argument, got '"${1@Q}"`.

[WARN] BCS0301 line 210: Static message text uses double quotes where only `${path@Q}` needs expansion. Prefer single-quoted literal text with a separately quoted expansion, e.g. `warn "${path@Q}"' is not a directory. Skipping.'`

[WARN] BCS0301 line 213: Static message text uses double quotes for a string that only interpolates variables. Prefer single-quoted literal segments around the expansions, e.g. `info 'Searching directory '"${path@Q}"', depth '"$max_depth"`.

[WARN] BCS0301 line 214: Static string passed to `decp` debug display is embedded in double quotes via command substitution output formatting. Prefer keeping literal text single-quoted where practical, e.g. `info "$(decp find_expr)"` is acceptable for substitution, but if adding literal framing text, use single-quoted segments.

[WARN] BCS0301 line 230: Static message text uses double quotes instead of single-quoted literal segments around expansions. Prefer `'Found '`... style concatenation.

[WARN] BCS0301 line 234: Static prompt text uses double quotes instead of single-quoted literal segments around expansions. Prefer `'Remove '`... style concatenation.

[WARN] BCS0301 line 236: Static message text uses double quotes instead of single-quoted literal segments around expansions. Prefer `'Removing '`... style concatenation.

[WARN] BCS0301 line 239: Static message text uses double quotes instead of single-quoted literal segments around the expansion. Prefer `info 'No matching files found in '"${path@Q}"`.

[WARN] BCS0502 line 146: `case $1 in` uses an unbraced positional parameter in the case expression. BCS examples use `case ${1:-} in` to safely handle unset/defaulted values; change to `case ${1:-} in`.

[WARN] BCS0709 line 47: `read -r -n 1` in `yn()` reads from stdin without checking for an interactive terminal. Since this is an interactive prompt helper, gate prompting on terminal use or read from `/dev/tty` to avoid consuming piped data unexpectedly.

[WARN] BCS0806 line 169: The script suppresses BCS0806 and reassigns standard option letters: `-n` is used for `--prompt` and `-N` for `--no-prompt` instead of dry-run toggles. Even though suppressed for enforcement at that command, the script’s interface deviates from recommended standard option meanings. Prefer non-conflicting letters for prompt control, or document the deviation prominently.

[WARN] BCS1002 line 10: `PATH` includes `~/.local/bin`, a user home directory, which BCS1002 explicitly says never to include in a hardened script PATH. Use a fixed trusted PATH such as `/usr/local/bin:/usr/bin:/bin`.

[WARN] BCS1202 line 17: Comment paraphrases the declaration below rather than adding extra information. Replace it with a comment that explains rationale or constraints, or remove it.

[WARN] BCS1202 line 20: Comment paraphrases the following messaging/color section rather than adding non-obvious information. Remove it or replace it with a comment explaining a real design constraint.

[WARN] BCS1202 line 21: Comment describes what the listed functions are, which is directly evident from the code below. Remove it or replace it with a comment that adds non-obvious context.

[WARN] BCS1202 line 23: Comment restates the TTY test on the next line. Remove it or replace it with rationale not obvious from the code.

[WARN] BCS1202 line 55: Comment paraphrases the `s()` helper implementation. Remove it or replace it with non-obvious context.

[WARN] BCS1202 line 110: Comment paraphrases `read_conf()` rather than adding information beyond the code; it also claims BCS0111 order though the function differs. Remove or rewrite it to explain the intentional deviation.

[WARN] BCS1202 line 130: Comment paraphrases the next statement `read_conf ||:`. Remove it or replace it with rationale for loading config before argument parsing.

[WARN] BCS1202 line 133: Comment paraphrases the block of local default declarations below. Remove it.

[WARN] BCS1202 line 188: Comment paraphrases the next statement setting the default path. Remove it.

[WARN] BCS1202 line 195: Comment paraphrases the array concatenation below. Remove it.

[WARN] BCS1202 line 199: Comment paraphrases the subsequent `find_expr` construction. Remove it.

[WARN] BCS1202 line 203: Comment paraphrases `unset 'find_expr[-1]'`. Remove it.

[WARN] BCS1202 line 206: Comment paraphrases the loop over paths. Remove it.

[WARN] BCS1202 line 215: Comment paraphrases the `readarray`/`find` block below. Remove it.

[WARN] BCS1202 line 227: Comment paraphrases the `if ((fnd)); then` block below. Remove it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0111 | recommended | [WARN] | 110 | Config-loading behavior/order is not properly documented to match the actual implementation |
| BCS0202 | core | [WARN] | 158 | Function modifies global `DELETE_FILES` without local scoping |
| BCS0301 | style | [WARN] | 165 | Double quotes used for mostly static error text |
| BCS0301 | style | [WARN] | 210 | Double quotes used for mostly static warning text |
| BCS0301 | style | [WARN] | 213 | Double quotes used for mostly static info text |
| BCS0301 | style | [WARN] | 214 | Double-quoted formatting where single-quoted literal segments are preferred |
| BCS0301 | style | [WARN] | 230 | Double quotes used for mostly static warning text |
| BCS0301 | style | [WARN] | 234 | Double quotes used for mostly static prompt text |
| BCS0301 | style | [WARN] | 236 | Double quotes used for mostly static info text |
| BCS0301 | style | [WARN] | 239 | Double quotes used for mostly static info text |
| BCS0502 | recommended | [WARN] | 146 | `case` expression uses `$1` instead of `${1:-}` |
| BCS0709 | style | [WARN] | 47 | Prompt helper reads from stdin without interactive-terminal handling |
| BCS0806 | recommended | [WARN] | 169 | Option interface deviates from standard option meanings |
| BCS1002 | core | [WARN] | 10 | Hardened PATH incorrectly includes a home-directory path |
| BCS1202 | style | [WARN] | 17 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 20 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 21 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 23 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 55 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 110 | Comment paraphrases code and mismatches actual config-order behavior |
| BCS1202 | style | [WARN] | 130 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 133 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 188 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 195 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 199 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 203 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 206 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 215 | Comment paraphrases code |
| BCS1202 | style | [WARN] | 227 | Comment paraphrases code |
bcs: ◉ Tokens: in=26986 out=1995
bcs: ◉ Elapsed: 32s
