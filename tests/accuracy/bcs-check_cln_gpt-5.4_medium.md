bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
[WARN] BCS0103 line 15: `SCRIPT_DIR` metadata is omitted even though the standard metadata set is declared immediately after `shopt`; fix by adding `declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}` alongside `SCRIPT_NAME`, or remove metadata commentary reliance if intentionally unused.

[WARN] BCS0301 line 60: static text is double-quoted in help/version output context; fix by using single quotes for literal-only strings where no expansion is needed, or keep expansions isolated from literals.

[WARN] BCS0301 line 62: static text is double-quoted unnecessarily; fix by using single quotes for literal-only strings.

[WARN] BCS0301 line 197: static error message uses double quotes unnecessarily; fix by writing `die 22 'No file patterns specified'`.

[WARN] BCS0502 line 146: `case $1 in` leaves the case expression unprotected against unset access under strict mode if the loop condition is ever changed; fix by using `case ${1:-} in` as the standard pattern.

[WARN] BCS0704 lines 68-74: help text documents config search as “first found wins,” but `read_conf()` actually returns on first readable file after searching user-first order, which deviates from the BCS cascade reference and should be documented precisely; fix by either updating help to match the implemented order/semantics exactly or changing `read_conf()` to the documented behavior.

[WARN] BCS0111 lines 111-126: `read_conf()` deviates from the recommended standard config-loading pattern: it uses first-match-wins and non-standard search order; fix by either implementing the documented cascade order or documenting the intentional deviation clearly in help/comments.

[WARN] BCS1202 line 130: comment paraphrases the immediately following `read_conf ||:` call without adding new information; fix by removing the comment or replacing it with rationale not evident from the code.

[WARN] BCS1202 line 133: comment paraphrases the local declarations that follow without adding information; fix by removing the comment or replacing it with a non-obvious rationale.

[WARN] BCS1202 line 188: comment paraphrases the next statement; fix by removing it or replacing it with context not obvious from the code.

[WARN] BCS1202 line 195: comment paraphrases the next assignment; fix by removing it or replacing it with rationale.

[WARN] BCS1202 line 199: comment paraphrases the following loop logic; fix by removing it or adding non-obvious explanation.

[WARN] BCS1202 line 203: comment paraphrases the following `unset 'find_expr[-1]'`; fix by removing it.

[WARN] BCS1202 line 206: comment paraphrases the following loop; fix by removing it.

[WARN] BCS1202 line 215: comment paraphrases the subsequent `readarray` operation; fix by removing it.

[WARN] BCS1202 line 227: comment paraphrases the following `if ((fnd)); then`; fix by removing it.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0103 | recommended | [WARN] | 15 | `SCRIPT_DIR` metadata omitted from standard metadata block |
| BCS0301 | style | [WARN] | 60 | Literal/static text uses unnecessary double quotes |
| BCS0301 | style | [WARN] | 62 | Literal/static text uses unnecessary double quotes |
| BCS0301 | style | [WARN] | 197 | Literal/static text uses unnecessary double quotes |
| BCS0502 | recommended | [WARN] | 146 | Case expression uses `$1` instead of `${1:-}` standard form |
| BCS0704 | style | [WARN] | 68-74 | Help text describes config semantics/order imprecisely relative to implementation |
| BCS0111 | recommended | [WARN] | 111-126 | `read_conf()` deviates from recommended cascade loader pattern and order |
| BCS1202 | style | [WARN] | 130 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 133 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 188 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 195 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 199 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 203 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 206 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 215 | Comment paraphrases following code |
| BCS1202 | style | [WARN] | 227 | Comment paraphrases following code |
bcs: ◉ Tokens: in=26983 out=1046
bcs: ◉ Elapsed: 23s
