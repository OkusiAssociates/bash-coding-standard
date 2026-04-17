bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll analyze the script systematically against the BCS rules.

---

**Line-by-line analysis:**

**Line 1:** `#!/bin/bash` — acceptable per BCS0102 (three valid forms listed).

**Line 11:** `declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")` — inline declaration of variable-content array. The values `md2ansi`, `cln`, `which` are bare strings without path prefix; not a BCS issue per se.

**Lines 12, 33, 67:** Global variables declared with `declare --` but assigned `''` implicitly — need to check if they're later assigned inside a loop (they are, lines 72–74, 80, 81). These are loop-control variables declared globally but used as loop variables. Minor observation — not a clear violation.

**Line 35:** `if (($#)); then` — arithmetic conditional without `||:`. But this is in `if` context, not a standalone `&&` chain, so BCS0606 does not apply. Fine.

**Line 36:** `[[ $1 == @(-V|--version) ]]` — uses extglob pattern in `[[`. Fine, `extglob` is enabled at line 4.

**Lines 35–63:** Argument parsing is done outside `main()`, using `if/elif` instead of the BCS0801 `while/case` pattern. The script is under 200 lines so `main()` is optional per BCS0403/BCS0108, but the parsing pattern itself deviates from BCS0801.

**Line 59:** `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"` — uses inline printf instead of `die()` or `error()`. No messaging functions are defined in this script. The script never defines `die`, `error`, `info`, etc. — per BCS0405, that's fine if not used, BUT error output IS happening (line 59) and exit codes are used (line 60) — `die()` is specifically the BCS standard for this pattern (BCS0602). However, BCS0602 says "Use `die()` as the standard exit function" — since `die()` isn't defined, this is a deviation but arguably a style issue.

**Line 60:** `exit 1` — BCS0602 says use `die()`. This should be `die 1 "..."` with die defined, or the inline approach at line 59+60 is a workaround without defining die. Since `die` is not defined, this is a deviation from BCS0602.

**Line 65:** `cd "$SCRIPT_DIR"` with a comment but no error check: `cd "$SCRIPT_DIR" || die 1 "Cannot cd to ${SCRIPT_DIR@Q}"`. Missing return value check on critical operation.

**Line 72:** `script=$(realpath -- "$script")` — reassigning a for-loop variable inside the loop. The loop variable `script` is global (line 12), and `realpath` result is assigned back. No `local` issue since we're not in a function. This is fine at global scope.

**Line 76:** `cd "$scriptdir"` — again, no error check on `cd`.

**Line 83:** `>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"` — double-quoted static portions. The string `"bcs check --model "` etc. could use single quotes for static parts, but since it contains variable expansions, double quotes are required for the whole thing. Actually this is fine — the string is not static.

**Line 85:** `>&2 echo "    ${output_to@Q} already exists; skipping"` — double quotes with variable expansion, fine.

**Line 96:** `TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))` — uses `printf '%()T'` builtin, good per BCS1213. However the argument `$((EPOCHSECONDS-start_time))` is unquoted. Inside `$(())` this is fine, but the result passed to printf is unquoted. Not a quoting issue per se since it's an integer. Fine.

**Line 96:** `TZ=UTC0` — the TZ format. BCS1213 shows `TZ=UTC printf`. `UTC0` is a valid POSIX timezone meaning UTC with offset 0 — this is functionally correct, not a BCS issue.

**Line 26:** Comment has a typo `ommitted` — not a BCS issue (not a code rule).

Now let me check for missed issues:

**BCS0101 / shopt:** Line 4 has `shopt -s inherit_errexit extglob` — `extglob` is reasonable here (used at line 36). Fine.

**BCS0103:** SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME all declared. Good.

**BCS0105 / Colors:** No color declarations — fine per BCS0405 since no color-using functions are defined.

**BCS0108 / main():** Script is ~98 lines, under 200, so `main()` is optional. Fine.

**BCS0109:** `#fin` at line 98. ✓

**BCS0201:** Global variables `script`, `scriptname`, `scriptdir` (line 12) and `model`, `effort`, `modelname` (line 33) are declared at global scope with `declare --`. They're used as loop variables in nested for loops. Since loops are at global scope (not in a function), `local` is not applicable. Fine.

**BCS0503 loops:** For loops with arrays are properly quoted `"${BASH_SCRIPTS[@]}"`, `"${LLM_MODELS[@]}"`, `"${EFFORTS[@]}"`. ✓

**BCS0604:** `cd` commands at lines 65 and 76 — `cd` failures are critical. Missing return-value checks.

**BCS0801:** The argument parsing (lines 35–63) uses `if/elif` instead of `while (($#)); do case`. This is a deviation from the standard pattern. For a simple 2-option handler, this is a meaningful deviation.

**BCS0802:** Version output at line 37: `printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"` — correct format per BCS0802. ✓

**BCS0806:** `-V`/`--version` and `-h`/`--help` implemented. Good. But not using the standard while/case structure.

**BCS1102 / Shebang:** `#!/bin/bash` — acceptable per BCS0102.

Now let me compile findings:

---

[ERROR] **BCS0604** line 65: `cd "$SCRIPT_DIR"` — return value of `cd` is not checked. If the directory doesn't exist or is inaccessible, the script silently continues in the wrong directory.

**Fix:**
```bash
cd "$SCRIPT_DIR" || die 1 "Cannot cd to ${SCRIPT_DIR@Q}"
```
(or `|| { >&2 printf '%s: ✗ Cannot cd to %s\n' "$SCRIPT_NAME" "${SCRIPT_DIR@Q}"; exit 1; }` if not using `die`)

---

[ERROR] **BCS0604** line 76: `cd "$scriptdir"` — return value of `cd` inside the loop is not checked. A bad path from `realpath` or a missing directory would leave subsequent iterations operating in the wrong directory.

**Fix:**
```bash
cd "$scriptdir" || { >&2 printf '%s: ✗ Cannot cd to %s\n' "$SCRIPT_NAME" "${scriptdir@Q}"; exit 1; }
```

---

[WARN] **BCS0801** lines 35–63: Argument parsing uses `if/elif` rather than the standard BCS `while (($#)); do case $1 in ... esac; shift; done` pattern.

**Fix:** Restructure to the standard pattern:
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           >&2 printf '%s: ✗ Invalid option %s\n' "$SCRIPT_NAME" "${1@Q}"; exit 1 ;;
  *)            die 22 "Unexpected argument ${1@Q}" ;;
esac; shift; done
```

---

[WARN] **BCS0602** lines 59–60: Error reporting uses inline `>&2 printf` + `exit 1` rather than a `die()` function. BCS0602 specifies `die()` as the standard exit function for error exits.

**Fix:** Define `die()` and use it:
```bash
die() { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
# ...
die 1 "Invalid argument ${1@Q}"
```

---

[WARN] **BCS0704** lines 39–57: The help text is output via a heredoc directly in the `elif` branch rather than in a `show_help()` function. BCS0704 recommends a `show_help()` function for structured help text.

**Fix:** Extract to a function:
```bash
show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION - ...
HELP
}
# then call: show_help; exit 0
```

---

Now the summary table:

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0604 | core | ERROR | 65 | `cd "$SCRIPT_DIR"` return value unchecked |
| BCS0604 | core | ERROR | 76 | `cd "$scriptdir"` return value unchecked inside loop |
| BCS0801 | core | WARN | 35–63 | Argument parsing uses `if/elif` instead of standard `while/case` pattern |
| BCS0602 | recommended | WARN | 59–60 | Error exit uses inline `printf`+`exit` instead of `die()` function |
| BCS0704 | style | WARN | 39–57 | Help text inlined in `elif` branch instead of `show_help()` function |
bcs: ◉ Tokens: in=28424 out=2557
bcs: ◉ Elapsed: 43s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
