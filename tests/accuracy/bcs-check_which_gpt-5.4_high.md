bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
[WARN] BCS0109 line 111: script ends with `#end` instead of the mandated final marker `#fin`. Fix: replace line 111 with `#fin`.

[WARN] BCS0201 line 11: `target`, `path`, `full_path`, and `resolved` are declared with `local` but without explicit type semantics (`local --`). Fix: change line 11 to `local -- target path full_path resolved`.

[WARN] BCS0201 line 49: `_path` is assigned without an explicit type declaration. Fix: change line 49 to `local -- _path=${PATH:-}`.

[WARN] BCS0202 line 49: `_path` is assigned inside a function without `local`, so it becomes global and leaks function state. Fix: declare it locally, e.g. `local -- _path=${PATH:-}`.

[WARN] BCS0301 line 35: static string uses double quotes via `printf 'which 2.0\n'`? No issue there. Actual violation is line 38 comment? Omit.

[WARN] BCS0401 line 49: local declaration appears mid-body after executable statements; this is allowed, so omit. 

[WARN] BCS0502 line 31: `case "$1" in` is preferred? Not applicable; current code is fine. 

[WARN] BCS0704 line 15: help/version text hardcodes `which 2.0` instead of using metadata variables. Fix: declare `VERSION` and `SCRIPT_NAME` metadata and use them in help/version output.

[WARN] BCS0802 line 35: version output format should be `scriptname X.Y.Z`; here it prints `which 2.0`, which lacks a three-component version. Fix: use a standard version string such as `which 2.0.0` and print it via metadata variables.

[WARN] BCS1202 line 100: comment paraphrases the next statement without adding useful information. Fix: remove the comment or replace it with context not obvious from the code.

[WARN] BCS1202 line 103: comment paraphrases the next statement without adding useful information. Fix: remove the comment or replace it with a comment explaining why this fence form was chosen.

[WARN] BCS1202 line 105: comment paraphrases the following block without adding non-obvious information. Fix: remove it or replace it with a comment documenting a real constraint or rationale.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0109 | style | [WARN] | 111 | Final marker uses `#end` instead of required `#fin` |
| BCS0201 | style | [WARN] | 11 | Local string variables lack explicit `--` type declaration |
| BCS0201 | style | [WARN] | 49 | `_path` assigned without explicit type declaration |
| BCS0202 | core | [WARN] | 49 | `_path` assigned in function without `local`, leaking scope |
| BCS0704 | style | [WARN] | 15 | Help/version text hardcodes script metadata instead of using metadata variables |
| BCS0802 | style | [WARN] | 35 | Version output not in standard `scriptname X.Y.Z` form |
| BCS1202 | style | [WARN] | 100 | Comment paraphrases next statement |
| BCS1202 | style | [WARN] | 103 | Comment paraphrases next statement |
| BCS1202 | style | [WARN] | 105 | Comment paraphrases following block |
bcs: ◉ Tokens: in=25042 out=778
bcs: ◉ Elapsed: 12s
