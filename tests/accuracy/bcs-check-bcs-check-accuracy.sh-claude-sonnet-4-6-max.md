bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll perform an exhaustive line-by-line audit.

---

**Line 1: `#!/bin/bash`**
BCS0102 — `/bin/bash` is acceptable per the standard. ✓

**Line 3: `set -euo pipefail`** ✓

**Line 4: `shopt -s inherit_errexit extglob`** ✓

**Lines 6–9: Metadata** ✓

**Line 11: `declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")`**
The entries `md2ansi`, `cln`, `which` are unquoted. These are alphanumeric/bare words — the standard permits unquoted one-word alphanumeric literals. `$SCRIPT_PATH` is correctly quoted. ✓ (Bare word literals are permitted by BCS0301.)

**Lines 12, 33, 67, 70: variable declarations** — `declare -- script scriptname` etc., typed correctly. ✓

**Lines 35–63: Argument handling**
The script handles `--version`, `--help`, and an invalid-argument fallback using extglob `@(-V|--version)` / `@(-h|--help)` patterns directly in `[[ ]]`. This is a valid pattern. The exit code for the invalid argument case is `1` (line 60); BCS0602 recommends `22` for invalid arguments. Flagged below.

The `exit 0` on line 62 is outside the `if/elif/else` block and fires regardless of which branch was taken — but every branch either reaches it naturally (version/help) or has already called `exit 1` (error branch). This is correct logic. ✓

**Line 44: `${BASH_SCRIPTS[@]@Q}`** — This is valid Bash 5.x parameter transformation applied to an array expansion inside a here-doc with an unquoted delimiter (`<<HELP`). The here-doc expands variables. ✓

**Line 59: `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"`**
This is a direct `printf` to stderr — not using the `error()` / `die()` messaging functions. The script has no `error()` or `die()` function defined. Since those functions don't exist in this script, BCS0405 applies — we cannot flag the absence of undefined functions. However, the script uses `exit 1` rather than a standard `die` call and does not follow the standard exit code table (BCS0602 specifies `22` for invalid argument). The `>&2 printf` is a valid stderr form (BCS0702). The exit code is the finding.

**Line 60: `exit 1`** — Exit code `1` used for invalid argument; BCS0602 specifies `22`. Flagged.

**Line 69: `declare -i start_time=$EPOCHSECONDS`**
`EPOCHSECONDS` is a Bash builtin integer variable. This is a simple integer assignment, no command substitution — no `SC2155` concern. ✓

**Line 72: `script=$(realpath -- "$script")`**
Command substitution assigned to an existing `declare --` variable. Under `set -euo pipefail` + `inherit_errexit`, a failing `realpath` will propagate correctly. No `#shellcheck disable=SC2155` present. However, `SC2155` applies specifically to `declare -r VAR=$(...)` or `local VAR=$(...)` combined declarations — not to plain assignments to already-declared variables. This is a plain assignment, so SC2155 does not apply. ✓

**Line 77: `model_safe=${model//[:\/]/_}`**
Bash character class in parameter expansion: `[:/]` is the standard form. Using `[:\/]` with an escaped slash works correctly, but the `\/` escape is unnecessary inside `[[ ]]` bracket expressions in Bash — however this is a parameter expansion `${...}`, not `[[ ]]`. In parameter expansion `${var//pattern/repl}`, the pattern is a glob pattern where `/` has no special meaning inside character classes, so `[:]` or `[:/]` or `[:\/]` all work. The backslash-escaped form is harmless but mildly non-idiomatic. Minor style point, not a violation.

**Line 80: `>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"`**
This line echoes a "preview" of the command to stderr, showing what would be run. The string uses double-quotes (appropriate — contains variable expansion). However, this is a status/diagnostic message: it uses `echo` directly rather than a messaging function. Since no `info()` function is defined in this script, this is the expected pattern. ✓

Also note: `$model`, `$effort` are unquoted inside double quotes — this is fine (they expand within double quotes). ✓

**Line 86: `bcs check --model "$model" --effort "$effort" "$script" &>"$output_to"`**
No return value check. If `bcs check` fails, `set -e` will exit the script. If intentional (errors written to the output file), the suppression should be explicit (`|| :`). However, since stdout+stderr are redirected to `$output_to`, a failure exit code from `bcs check` under `set -e` would abort the loop. This may or may not be intentional. If the intent is to continue on failure (continue collecting outputs from other model/effort combinations), this is a bug. If the intent is to abort on failure, this is correct. Without context I'll flag it as a WARNING — the lack of explicit error handling means a single model failure aborts all subsequent tests.

**Line 93: `TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))`**
BCS1213 recommends `printf '%()T'` (builtin strftime). This usage is correct and idiomatic. `$((EPOCHSECONDS-start_time))` is an unquoted arithmetic expansion used as a printf argument — this is safe (it's an integer, no word splitting concern). `TZ=UTC0` is the inline environment variable assignment form. ✓

However, `TZ=UTC0` sets TZ to `UTC0` (POSIX timezone string meaning UTC offset 0). BCS1213 example shows `TZ=UTC` — both are valid POSIX timezone strings for UTC. Minor style note, not a violation.

**Line 95: `#fin`** ✓

---

## Findings

### VIOLATION — BCS0108: No `main()` function; argument parsing at top level

Lines 35–93 constitute the script's logic, with argument parsing inline at the top level. The script is under 200 lines, so BCS0108 says "`main()` may be omitted for scripts under 200 lines" — this is explicitly permitted. ✓ (Retracting — not a finding.)

### VIOLATION — BCS0602: Wrong exit code for invalid argument (line 60)

`exit 1` is used for an invalid argument. BCS0602 specifies exit code `22` for invalid arguments.

**Fix:**
```bash
exit 22
```

### WARNING — BCS0801/BCS0806: Argument parsing does not use the standard `while (($#)); do case` pattern (lines 35–63)

The script uses `if (($#)); then` with nested `if/elif/else` rather than the standard `while (($#)); do case $1 in ... esac; shift; done` pattern. For a script that accepts only one argument and exits immediately after processing it, this works correctly — but it deviates from the BCS standard parsing pattern. No option bundling support. No `--` separator handling.

**Fix:** Use the standard pattern:
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; break ;;
  -*)           >&2 printf '%s: ✗ Invalid option %s\n' "$SCRIPT_NAME" "${1@Q}"; exit 22 ;;
esac; shift; done
```

### WARNING — BCS0703/BCS0602: No `die()` function; raw `exit 1` for error (lines 59–60)

The script has no `die()` or `error()` function. The error path uses a bare `>&2 printf` + `exit 1`. While BCS0405 prevents flagging *missing* unused functions, using `exit 1` for an error without `die()` means there is no consistent error reporting pattern. This is a WARNING rather than a VIOLATION since the script is simple and BCS0405 permits omitting functions not used.

The primary finding here is the exit code (`22` for invalid argument per BCS0602), already flagged above.

### WARNING — BCS0606: `bcs check` on line 86 has no error handling; under `set -e` a failure aborts all remaining iterations

```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to"
```

If `bcs check` returns non-zero, `set -e` terminates the script, skipping all remaining model/effort combinations. This is almost certainly unintentional in a test-harness script that is expected to be resilient to individual failures.

**Fix:**
```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" ||:
```
Or handle the failure explicitly:
```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" \
  || warn "bcs check failed for $model/$effort"
```

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0602 | VIOLATION | 60 | Exit code `1` used for invalid argument; BCS0602 specifies `22` for invalid arguments |
| BCS0801 | WARNING | 35–63 | Argument parsing uses `if/elif/else` instead of the standard `while (($#)); do case` pattern; no `--` separator, no option bundling |
| BCS0606 | WARNING | 86 | `bcs check` command has no `||:` or error handler; under `set -e` any failure aborts all remaining loop iterations |
bcs: ◉ Tokens: in=23715 out=2558
bcs: ◉ Elapsed: 44s
