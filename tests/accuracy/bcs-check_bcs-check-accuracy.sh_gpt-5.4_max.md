bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
[WARN] BCS0301 line 59: Static string uses double quotes (`"Invalid argument ${1@Q}"`) instead of single quotes for the literal portion. Fix by using single-quoted literal text with separate expansion, e.g. `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" 'Invalid argument '"${1@Q}"`.

[WARN] BCS0602 line 60: Usage/argument error exits with code `1`, but BCS recommends code `22` for invalid arguments. Fix by changing `exit 1` to `exit 22`, or use a `die 22 ...` helper.

[WARN] BCS1202 line 65: Comment paraphrases the code (`# anchor to script's dir path`) without adding meaningful information. Fix by removing the comment or replacing it with a non-obvious rationale if needed.

[WARN] BCS0202 line 72: Variable `script` is assigned inside a loop in the main scope without an explicit local scope; in functions this would be required, and this pattern increases global state mutation. Fix by moving the main logic into `main()` and declaring loop variables local there.

[WARN] BCS0202 line 73: Variable `scriptname` is assigned in the main scope and not scoped locally. Fix by placing the logic in a function and declaring `local -- scriptname=${script##*/}`.

[WARN] BCS0202 line 74: Variable `scriptdir` is assigned in the main scope and not scoped locally. Fix by placing the logic in a function and declaring `local -- scriptdir=${script%/*}`.

[WARN] BCS0202 line 80: Variable `modelname` is assigned in the main scope and not scoped locally. Fix by placing the logic in a function and declaring `local -- modelname=${model//[:\/]/-}`.

[WARN] BCS0202 line 82: Variable `output_to` is assigned in the main scope and not scoped locally. Fix by placing the logic in a function and declaring `local -- output_to=...`.

[WARN] BCS0301 line 83: Static strings in `echo` use double quotes where single quotes should be used for literal text. Fix by switching to `printf` or composing the message with single-quoted literals and quoted expansions.

[WARN] BCS0702 line 85: Uses `echo` for status output to stderr instead of messaging functions; BCS expects status messages via messaging functions. Fix by adding a minimal `info()`/`warn()` helper and sending status through it.

[WARN] BCS0301 line 85: Static string uses double quotes for a message containing literal text plus expansion. Fix by separate quoting, e.g. `>&2 printf '    %s already exists; skipping\n' "${output_to@Q}"`.

[WARN] BCS1213 line 96: `printf '%()T'` is preferred without unnecessary arithmetic expansion formatting style around the argument. Fix by storing elapsed time in an integer variable first, e.g. `declare -i elapsed=EPOCHSECONDS-start_time; TZ=UTC0 printf '%(%T)T\n' "$elapsed"`.

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0301 | style | [WARN] | 59 | Static string uses double quotes instead of single quotes for literal text |
| BCS0602 | recommended | [WARN] | 60 | Invalid argument exits with code 1 instead of recommended 22 |
| BCS1202 | style | [WARN] | 65 | Comment paraphrases code without adding information |
| BCS0202 | core | [WARN] | 72 | Assignment to `script` occurs in main scope rather than local function scope |
| BCS0202 | core | [WARN] | 73 | Assignment to `scriptname` occurs in main scope rather than local function scope |
| BCS0202 | core | [WARN] | 74 | Assignment to `scriptdir` occurs in main scope rather than local function scope |
| BCS0202 | core | [WARN] | 80 | Assignment to `modelname` occurs in main scope rather than local function scope |
| BCS0202 | core | [WARN] | 82 | Assignment to `output_to` occurs in main scope rather than local function scope |
| BCS0301 | style | [WARN] | 83 | Status string uses double quotes for literal text |
| BCS0702 | core | [WARN] | 85 | Status output uses `echo` to stderr instead of messaging functions |
| BCS0301 | style | [WARN] | 85 | Static string uses double quotes instead of single quotes |
| BCS1213 | style | [WARN] | 96 | Date/time builtin use could be clearer by assigning elapsed time first |
bcs: ◉ Tokens: in=24794 out=1032
bcs: ◉ Elapsed: 14s
