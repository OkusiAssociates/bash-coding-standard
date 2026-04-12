bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll analyze the script systematically against BCS rules.

**Line 1:** `#!/bin/bash` — acceptable (BCS0102 allows this form).

**Line 11:** `declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")` — `which` is a command name used as a literal string element; this is fine contextually. The space before closing `)` is a minor style note but not a BCS rule.

**Lines 35–63:** Argument handling is done inline (no `main()`). The script is short (~95 lines, under the ~200-line threshold), so this is acceptable per BCS0403.

**Line 36:** `[[ $1 == @(-V|--version) ]]` — uses extglob pattern matching in `[[ ]]`. This works since `extglob` is enabled (line 4). However, the standard parsing pattern (BCS0801) uses `case` for argument dispatch; this uses chained `if/elif`. Check severity: BCS0801 is the *standard* pattern recommendation, so deviation is a WARNING rather than a VIOLATION.

**Lines 35–63:** No standard `case`-based argument loop; instead a one-shot `if (($#))` block. The script only handles `-V` and `-h`, no positional arguments, so this is a deliberate minimal design. BCS0801 deviation → WARNING.

**Lines 35–63:** `-V` exits on line 37 with no explicit `exit 0` before reaching line 62's `exit 0`. After the `if/elif` block, control falls to `exit 0` on line 62 for both `-V` and `-h`. For the `else` branch, `exit 1` is on line 60. This is correct.

**Line 59:** `exit 1` for an invalid argument. BCS0602 specifies exit code 22 for invalid arguments.

**Line 59:** `>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"` — this is a direct `printf` call rather than using an `error()` messaging function. The script defines no messaging functions at all. Check BCS0405: are messaging functions needed? The script uses direct `>&2 echo` and `>&2 printf` for status. Since no messaging functions are defined, BCS0405 says don't require them. However, BCS0703 defines `die()` as the standard exit function for error exits — the absence of `die()` while doing manual error+exit is relevant. Since `die()` is the "standard exit function" per BCS0602, its absence is a WARNING.

**Line 80:** `>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"` — the format string uses double quotes with variable expansion. The static prefix `"bcs check --model "` etc. is embedded in double quotes — BCS0301 prefers single quotes for static strings, but here the entire string includes variables so double quotes are required. This is correct.

**Line 80:** `echo` vs `printf` — BCS1205 doesn't mandate `printf` over `echo` for simple output. Fine.

**Line 82:** Same double-quote reasoning — fine.

**Line 93:** `TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))` — `$((EPOCHSECONDS-start_time))` is passed as an unquoted arithmetic expansion to `printf`. This is an integer result, so word splitting produces exactly one token; safe. The `TZ=UTC0` inline env var is the standard BCS1213 UTC pattern (BCS1213 shows `TZ=UTC printf`). `UTC0` vs `UTC` — both are valid POSIX TZ strings. Fine.

**Line 12:** `declare -- script scriptname` and **line 33:** `declare -- model effort model_safe` — these declare variables with no initializer. BCS0201 shows `declare -- filename=''` with an empty string initializer. Declaring without initializer leaves them unset, which under `set -u` could trigger an error if referenced before assignment. However, all of these are assigned before use in the loops (lines 72, 73, 77, 79). Still, BCS0201 pattern shows explicit initialization — WARNING.

**Line 67:** `declare -- output_to` — same pattern, assigned before use on line 79. WARNING per BCS0201.

**Line 69:** `declare -i start_time=$EPOCHSECONDS` — no `#shellcheck disable=SC2155` before this. SC2155 warns about combined declare-and-assign that masks return values. For `$EPOCHSECONDS` (a variable, not a command substitution) this is actually not triggered by shellcheck, so no directive needed. Fine.

**Lines 35–63:** Option handling exits cleanly but doesn't use `main()`. Script is ~95 lines. BCS0403 says "generally use `main()` for scripts over ~200 lines" and "scripts under 200 lines may run directly without `main()`". No violation.

**Line 86:** `bcs check --model "$model" --effort "$effort" "$script" &>"$output_to"` — this is a critical operation whose failure is not checked. Under `set -e`, if `bcs check` fails, the script exits. That may be intentional. But if the intent is to continue testing other combinations even when one fails, the lack of `|| error ...` handling is a design consideration. BCS0604 says "always check return values of critical operations." The `bcs check` output is being captured to a file, so a failure would exit the script mid-loop. This is a WARNING — the failure mode may be intentional (abort on first failure) but is undocumented.

**Lines 11, 33, 67:** The global variable declarations `script`, `scriptname`, `model`, `effort`, `model_safe`, `output_to` at global scope — these are loop variables used only within the loop body. BCS0202 states function-specific variables should be `local`. Since there's no enclosing function (no `main()`), these are necessarily global. Not a BCS violation given the no-`main()` design for short scripts.

**No `#fin` check:** Line 95 is `#fin` — ✓

**Colors:** None used, none declared — correct per BCS0405.

**No cleanup/trap:** No temp files created, no background jobs — trap not required.

**Summary of findings:**

---

## Findings

### VIOLATION — BCS0602 — Line 60 — Wrong exit code for invalid argument

Exit code `1` (general error) is used for an invalid argument. BCS0602 specifies exit code `22` for invalid arguments.

**Fix:**
```bash
    >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
    exit 22
```

---

### WARNING — BCS0801 — Lines 35–63 — Non-standard argument parsing pattern

Arguments are handled with `if/elif` on extglob patterns rather than the BCS standard `while (($#)); do case $1 in` loop. While the script's minimal option set makes this workable, it diverges from the standard pattern and would not scale. The `extglob` patterns also require `extglob` to be enabled, adding an implicit dependency.

**Fix:** Use the standard parsing pattern:
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           >&2 printf '%s: ✗ Invalid option %s\n' "$SCRIPT_NAME" "${1@Q}"; exit 22 ;;
esac; shift; done
```

---

### WARNING — BCS0602 — Lines 59–60 — No `die()` function; manual error+exit pattern

BCS0602 designates `die()` as the standard exit function. The script manually combines `>&2 printf` + `exit` instead. While the script has no other messaging functions (BCS0405 applies), `die()` specifically is the standard for error exits with codes.

**Fix:** Add a minimal `die()`:
```bash
die() { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
```
Then use:
```bash
die 22 "Invalid argument ${1@Q}"
```

---

### WARNING — BCS0201 — Lines 12, 33, 67 — Variables declared without initializers

`declare -- script scriptname`, `declare -- model effort model_safe`, and `declare -- output_to` are declared without empty-string initializers. BCS0201 shows `declare -- filename=''` as the pattern.

**Fix:**
```bash
declare -- script='' scriptname=''
declare -- model='' effort='' model_safe=''
declare -- output_to=''
```

---

### WARNING — BCS0604 — Line 86 — Return value of `bcs check` not explicitly handled

```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to"
```

A failure causes silent script termination under `set -e` with no diagnostic. If partial runs are acceptable, failures should be caught and logged; if not, the failure mode should be documented.

**Fix (continue on failure):**
```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" \
  || >&2 printf '%s: ✗ bcs check failed for %s/%s/%s\n' "$SCRIPT_NAME" "$scriptname" "$model" "$effort"
```

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0602 | VIOLATION | 60 | Exit code `1` used for invalid argument; should be `22` |
| BCS0801 | WARNING | 35–63 | Non-standard `if/elif` argument parsing instead of `while (($#)); do case` |
| BCS0602 | WARNING | 59–60 | No `die()` function; manual `printf`+`exit` pattern used for error exit |
| BCS0201 | WARNING | 12, 33, 67 | Variables declared without empty-string initializers |
| BCS0604 | WARNING | 86 | `bcs check` failure not explicitly handled; silent termination under `set -e` |
bcs: ◉ Tokens: in=23717 out=2580
bcs: ◉ Elapsed: 51s
