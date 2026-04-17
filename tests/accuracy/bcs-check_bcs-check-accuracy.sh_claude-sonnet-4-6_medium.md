bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll analyze the script systematically against the BCS rules.

**Line 1:** `#!/bin/bash` — acceptable per BCS0102 (all three shebang forms are acceptable).

**Line 11:** `declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")` — global array with lowercase names mixed in, and the spacing before the closing `)` is inconsistent but not a BCS violation per se. The values `md2ansi`, `cln`, `which` are unquoted — single-word alphanumeric literals are permitted unquoted per BCS0301. No violation.

**Lines 12, 33:** `declare -- script scriptname scriptdir` and `declare -- model effort modelname` — variables declared globally but used only as loop variables. Not a strict BCS violation (BCS0202 applies to functions), but worth noting. Actually, loop variables in the main body (not in a function) don't require `local`. No violation.

**Lines 35–63:** Argument parsing is done outside of `main()` with a chain of if/elif. This script is under 200 lines, so `main()` is optional per BCS0403. However, the parsing pattern uses `if [[ $1 == @(...) ]]` instead of the standard `while (($#)); do case $1 in` pattern from BCS0801. This is a notable deviation.

**Line 36:** `[[ $1 == @(-V|--version) ]]` — uses extglob for option matching, not the standard case-based parsing pattern from BCS0801.

**Line 44:** `${BASH_SCRIPTS[@]@Q}` — inside an unquoted heredoc (`<<HELP`), so expansion occurs. This is correct — help text should show expanded values. No violation.

**Line 59:** `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"` — error message goes to stderr correctly. However, the script uses `exit 1` without a `die()` function. This is a style deviation — BCS0602 recommends `die()` as the standard exit function.

**Line 62:** `exit 0` — after the if/elif block but `exit 0` at line 62 will exit whether help or version was handled, which is correct but the structure is non-standard.

**Line 69:** `declare -i start_time=$EPOCHSECONDS` — `EPOCHSECONDS` is a Bash builtin variable, no fork. Correct per BCS1213.

**Line 80:** `modelname=${model//[:\/]/-}` — parameter expansion for sanitization. The `\/` inside a character class `[...]` doesn't need escaping in Bash (the `\` is literal inside `[]` in parameter expansion context, though Bash accepts it). Minor style point but not a BCS violation.

**Line 83:** `>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"` — uses `echo` with double-quoted string for a status message. Per BCS0702, status goes to stderr (correct with `>&2`). However, this is displaying what would be executed — it uses `echo` rather than `info()` or a messaging function. Also, the format string contains double quotes around a static-plus-dynamic string. The `&>` inside the string is just being displayed as text, not redirecting — this is intentional and correct.

**Line 83:** Also: using `echo` for status output directly rather than through messaging functions. BCS0703/BCS0705 recommend using messaging functions. Since no `info()` function exists, `echo` is the fallback — per BCS0405, we should NOT flag absence of `info()` if the script doesn't define it. But the script IS using `>&2 echo` for status, which functionally equivalent. This is a WARN-level deviation.

**Line 89:** `bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" ||:` — uses `||:` correctly. `&>` per BCS0711 is correct.

**Line 96:** `TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))` — uses `printf '%()T'` builtin correctly per BCS1213. The `$((EPOCHSECONDS-start_time))` is unquoted — inside `printf` arguments after the format string this is fine as it's an arithmetic expansion yielding an integer. No violation.

**Line 96:** However, `$((EPOCHSECONDS-start_time))` is passed to `printf '%(%T)T'` which expects an epoch timestamp. This interprets the elapsed seconds as a time-of-day (e.g., 75 seconds → `00:01:15`). This is intentional — the author is using `strftime` with elapsed seconds as if it were a midnight-relative timestamp to display HH:MM:SS duration. This is a clever idiom, not a violation.

Now checking more carefully:

**BCS0801 — Standard Parsing Pattern:** The script uses `if/elif` chains with extglob patterns instead of `while (($#)); do case $1 in`. This is a clear deviation from the standard parsing pattern for a script that takes options.

**No `main()` function:** Script is approximately 98 lines, under the ~200 line threshold, so this is not required.

**No messaging functions / no `die()`:** The script uses raw `>&2 printf` and `>&2 echo` instead of messaging functions. Since the script doesn't define messaging functions, BCS0405 means we don't flag their absence. However, using `exit 1` without `die()` deviates from BCS0602 recommendation.

**Line 26 comment:** `# Efforts; low ommitted because of consistent poor quality with current models` — typo "ommitted" but not a BCS violation.

**BCS0703/BCS0705:** No messaging functions defined. Per BCS0405, not flagged if unused. The script uses `>&2 echo` directly, which is the fallback pattern.

---

## Findings

[WARN] BCS0801 lines 35–62: Argument parsing uses `if/elif` with extglob patterns instead of the standard `while (($#)); do case $1 in` pattern. The `@(-V|--version)` and `@(-h|--help)` extglob comparisons inside `[[ ]]` achieve the same result but deviate from the BCS-standard case-based parsing pattern.

**Fix recommendation:** Refactor to standard pattern:
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           die 22 "Invalid argument ${1@Q}" ;;
  *)            die 22 "Invalid argument ${1@Q}" ;;
esac; shift; done
```

[WARN] BCS0602 line 59–60: Error exit uses raw `>&2 printf` + `exit 1` instead of the standard `die()` function. BCS0602 recommends `die()` as the standard exit function with appropriate exit codes. Exit code `1` (general error) is used where exit code `22` (invalid argument) would be more appropriate per the standard table.

**Fix recommendation:** Define `die()` and use:
```bash
die 22 "Invalid argument ${1@Q}"
```

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0801 | recommended | WARN | 35–62 | Argument parsing uses `if/elif` + extglob instead of standard `while (($#)); do case $1 in` pattern |
| BCS0602 | recommended | WARN | 59–60 | Error exit uses raw `>&2 printf` + `exit 1` instead of `die()` with appropriate exit code (22 for invalid argument) |
bcs: ◉ Tokens: in=28420 out=1953
bcs: ◉ Elapsed: 35s
