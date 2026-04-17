bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll analyze the script line by line against the BCS.

---

**[WARN] BCS0102 line 1:** Shebang uses `/bin/bash` rather than the preferred `/usr/bin/bash`.
*Fix:* Change to `#!/usr/bin/bash`.

---

**[WARN] BCS0108 line 35–63:** The argument-handling block is inline (not inside `main()`), and the script is ~98 lines — borderline but the pattern mixes argument handling, business logic, and inline flow at the top level rather than using `main()`. More importantly, argument parsing uses ad-hoc `if/elif` rather than the standard `while (($#)); do case $1 in ... esac; shift; done` pattern (BCS0801).
*Fix:* Use the standard while/case parsing loop, even for this limited set of options.

---

**[ERROR] BCS0801 line 35–63:** The standard argument-parsing pattern `while (($#)); do case $1 in ... esac; shift; done` is not used. Instead, a bare `if (($#))` with `elif` branches is used. The `--` end-of-options separator is also absent, and there is no `-*) die 22 ...` fallthrough for the inner elif. The else at line 58 uses `exit 1` rather than `die 22`.
*Fix:*
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; break ;;
  -*)           die 22 "Invalid argument ${1@Q}" ;;
esac; shift; done
```

---

**[WARN] BCS0704 line 39–57:** Help text is inlined directly in the argument-parsing block rather than in a dedicated `show_help()` function. BCS0704 calls for a named function to structure help output.
*Fix:* Extract the heredoc into a `show_help()` function and call it from the argument parser.

---

**[WARN] BCS0107 line 35–94:** The script has no `main()` function and no clear bottom-up function layering — all logic runs at the top level. At ~98 lines this is borderline, but the presence of distinct phases (argument handling, setup, nested loops, timing) makes a `main()` beneficial and consistent with BCS intent.
*Fix:* Wrap the script body in `main()` and call `main "$@"` before `#fin`.

---

**[WARN] BCS0703 / BCS0602 line 59–60:** The error message uses a bare `>&2 printf` + `exit 1` rather than `die()`. No `die()` function is defined. BCS0602 prescribes `die()` as the standard exit function. Exit code `1` (general error) is used where `22` (invalid argument) is the standard code.
*Fix:* Define `die()` and use `die 22 "Invalid argument ${1@Q}"`.

---

**[WARN] BCS0502 line 36–61:** `extglob` is enabled (line 4), and the script uses `@(-V|--version)` and `@(-h|--help)` patterns inside `[[ ]]`. While this works correctly, using `case` patterns (which support `|` natively without `extglob`) would be cleaner and consistent with the standard parsing pattern (BCS0801). This is a style concern subordinate to the BCS0801 finding above.
*Fix:* Addressed by adopting BCS0801's `while/case` pattern.

---

**[WARN] BCS0203 line 12:** `script`, `scriptname`, `scriptdir` are declared as globals at the top level. These are loop-iteration variables used only within the outer `for script` loop. Declaring them globally pollutes the namespace; they should be local to a function.
*Fix:* Move them inside a `main()` function (or a dedicated processing function), declared with `local`.

---

**[WARN] BCS0203 line 33:** Similarly, `model`, `effort`, `modelname` are declared as globals. These are loop-iteration variables and should be local to a function.
*Fix:* Declare inside `main()` or a processing function with `local`.

---

**[WARN] BCS0203 line 67:** `output_to` is declared as a global. It is used only within the innermost loop and should be local.
*Fix:* Declare inside `main()` with `local`.

---

**[WARN] BCS0503 line 81 (inner for loop):** The for-loop variables `effort` and `model` are declared globally (lines 33) rather than locally. Per BCS0410, loop variables in functions must be `local`. Even outside a function, these are conceptually iteration variables.
*Fix:* Move into a function and declare `local -- model effort modelname output_to`.

---

**[WARN] BCS0702 line 83:** `>&2 echo` is used for a status/progress message. This is correct (stderr). However, the script has no `info()` or messaging function defined — it uses raw `>&2 echo` throughout. BCS0703 recommends using core message functions rather than bare redirected echo.
*Fix:* Define an `info()` function (BCS0703 pattern) and use it for status messages, or at minimum define `die()` (required by BCS0602).

---

**[WARN] BCS0702 line 85:** Same as above — `>&2 echo` for status message, no messaging function.

---

**[WARN] BCS1202 line 26:** Comment `# Efforts; low ommitted because of consistent poor quality with current models` — typo "ommitted" (should be "omitted"). Minor, but comments should be accurate.
*Fix:* Correct spelling to "omitted".

---

**[WARN] BCS1202 line 65:** `cd "$SCRIPT_DIR" # anchor to script's dir path` — the inline comment is marginally useful (the `cd` is self-evident), but it does document the *reason* (anchoring). Borderline; not flagged as a clear violation.

---

**[WARN] BCS0602 line 60:** `exit 1` used for an invalid-argument condition. BCS0602 standard exit code table specifies `22` for invalid argument.
*Fix:* Use `exit 22` or (once `die` is defined) `die 22 "Invalid argument ${1@Q}"`.

---

**[WARN] BCS0801 line 36:** The version output at line 37 is `printf '%s %s\n'` — this matches BCS0802 format exactly. ✓ No finding here. (Noted to confirm compliance.)

---

**[WARN] BCS1213 line 96:** `TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))` — The arithmetic expression `$((EPOCHSECONDS-start_time))` is unquoted as a printf argument. This is safe (it's integer arithmetic), but `TZ=UTC0` is a non-standard timezone specifier; `TZ=UTC` is the conventional form. `UTC0` works on most Linux systems but `UTC` is more portable.
*Fix:* Use `TZ=UTC printf '%(%T)T\n' $((EPOCHSECONDS - start_time))`.

---

**[ERROR] BCS0503 line 96:** `$((EPOCHSECONDS-start_time))` passes the result as an argument to `printf '%(%T)T'`. Under strict mode, an unquoted arithmetic expansion is safe here (integers don't word-split in ways that matter), but `printf '%(%T)T'` with a large elapsed-seconds value interprets it as an epoch timestamp and formats it as a wall-clock time (e.g., 125 seconds → `00:02:05` in UTC, which appears correct). However, this is only correct because `TZ=UTC0` forces UTC interpretation of the epoch offset. This is actually correct behavior — not a violation. Retracting this finding.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0102 | recommended | [WARN] | 1 | Shebang uses `/bin/bash`; prefer `/usr/bin/bash` |
| BCS0801 | core | [ERROR] | 35–63 | Non-standard argument parsing; `while/case` pattern not used |
| BCS0602 | recommended | [WARN] | 59–60 | No `die()` function; bare `>&2 printf` + `exit 1`; wrong exit code (1 vs 22) |
| BCS0704 | style | [WARN] | 39–57 | Help text inlined; should be in `show_help()` function |
| BCS0107 | style | [WARN] | 35–94 | No `main()` function; all logic at top level |
| BCS0203 | style | [WARN] | 12 | `script`, `scriptname`, `scriptdir` declared as globals; should be local |
| BCS0203 | style | [WARN] | 33 | `model`, `effort`, `modelname` declared as globals; should be local |
| BCS0203 | style | [WARN] | 67 | `output_to` declared as global; should be local |
| BCS0703 | style | [WARN] | 83, 85 | Raw `>&2 echo` used; no messaging functions defined |
| BCS1213 | style | [WARN] | 96 | `TZ=UTC0` non-standard; prefer `TZ=UTC` |
| BCS1202 | style | [WARN] | 26 | Typo "ommitted" in comment |
bcs: ◉ Tokens: in=28418 out=2443
bcs: ◉ Elapsed: 42s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
