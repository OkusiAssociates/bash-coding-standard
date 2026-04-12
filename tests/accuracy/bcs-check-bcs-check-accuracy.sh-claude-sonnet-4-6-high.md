bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
I'll analyze the script systematically against the BCS rules.

---

## Findings

### WARNING — BCS0102 — Line 1

**Shebang uses `/bin/bash` equivalent (`#!/bin/bash`) — preferred form is `#!/usr/bin/bash`.**

The BCS0102 reference lists `#!/usr/bin/bash` as "Preferred for Linux systems." `#!/bin/bash` is "Acceptable," so this is a WARNING, not a VIOLATION.

**Fix:** Change to `#!/usr/bin/bash`

---

### WARNING — BCS0108 — Lines 35–63, 65–93

**No `main()` function; script logic is at top level.**

The script is well over 200 lines when the full argument-parsing and loop logic is counted as a single linear block — actually under 100 lines total, so the 200-line threshold is not crossed. However, the argument parsing is done inline rather than in `main()`.

**Correction on re-examination:** The script is ~95 lines. BCS0108 states "Generally, use `main()` for scripts over ~200 lines." At ~95 lines this is below the threshold. This finding does **not** apply. *(Omitted per rules — no actual deviation.)*

---

### VIOLATION — BCS0108 / BCS0806 — Lines 35–63

**Argument parsing does not follow the standard `while (($#)); do case $1 in ... esac; shift; done` pattern.**

The script uses a hand-rolled `if/elif/else` chain instead of the canonical BCS while/case loop. Consequences:

- No `--` end-of-options handling
- No bundled short option support
- No fallthrough to positional argument collection
- The structure diverges from BCS0801's mandatory parsing pattern

Additionally, the `exit 0` at line 62 is inside the `if (($#))` block — if `--help` or `--version` is given, it exits correctly, but the structure is fragile and non-standard.

**Fix:** Rewrite using the standard pattern:

```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; break ;;
  -*)           >&2 printf '%s: ✗ Invalid option %s\n' "$SCRIPT_NAME" "${1@Q}"; exit 22 ;;
  *)            break ;;
esac; shift; done
```

---

### WARNING — BCS0602 — Lines 59–60

**Error exit uses code `1` (general error) for an invalid argument; BCS0602 specifies exit code `22` for invalid arguments.**

```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
exit 1
```

Exit code `22` is the BCS-standard code for invalid arguments (matching the table in BCS0602: "22 — Invalid argument").

**Fix:**
```bash
>&2 printf '%s: ✗ Invalid argument %s\n' "$SCRIPT_NAME" "${1@Q}"
exit 22
```

---

### WARNING — BCS0303 — Line 36, 38

**`extglob` patterns used inside `[[ ]]` for `--version` / `--help` matching, but the standard parsing pattern (BCS0801) uses `case` for this.**

```bash
if [[ $1 == @(-V|--version) ]]; then
```

Using `@(...)` inside `[[ == ]]` is valid with `extglob` enabled, and technically works. However, BCS0801 specifies `case` for multi-option matching (`-V|--version`), which is clearer, more idiomatic, and does not require extglob. This is a style WARNING tied to the non-standard parsing pattern already flagged above.

**Fix:** Use `case` per BCS0801 (addressed by the BCS0801 fix above).

---

### WARNING — BCS0703 / BCS0705 — Lines 59, 80, 82

**`printf` used for status/error messages to stderr directly, bypassing the `error()`/`info()` messaging functions.**

```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
>&2 echo "    ${output_to@Q} already exists; skipping"
```

BCS0703 establishes `error()` and `info()` as the standard messaging functions. Inlining `>&2 printf` / `>&2 echo` throughout logic code bypasses the messaging layer (including color support, consistent prefixing, and the `_msg()` dispatch). This is a WARNING because a small script may reasonably omit the full messaging suite, but the inline error message at line 59 in particular should use `error()` or `die()`.

**Fix:** Define and use `error()` / `info()` / `die()` per BCS0703, or at minimum use `die()` for the error-and-exit case:

```bash
die()   { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
# ...
die 22 "Invalid argument ${1@Q}"
```

---

### WARNING — BCS0105 — Lines 12, 33, 67

**Variables `script`, `scriptname`, `model`, `effort`, `model_safe`, and `output_to` are declared as globals at script top level, but are used exclusively as loop iteration variables.**

```bash
declare -- script scriptname          # line 12
declare -- model effort model_safe    # line 33
declare -- output_to                  # line 67
```

These are used only within the `for` loops. In a `main()`-style script they would be `local`. In a top-level script, this is unavoidable in Bash (no scope outside functions), but pre-declaring them as globals is an unusual pattern that adds noise. More importantly, `declare -- output_to` appears at line 67 with an empty value but is used in loop bodies — this is acceptable but the mid-script declaration breaks the "declare all global variables up front" convention (BCS0105 says "Declare all global variables up front").

**Fix:** Move `output_to` declaration to the top with the other globals (lines 12–13 area), or restructure into `main()`.

---

### WARNING — BCS0201 — Line 11

**`BASH_SCRIPTS` array is declared but immediately populated with a mix of bare command names and a full path.**

```bash
declare -a BASH_SCRIPTS=( md2ansi cln which "$SCRIPT_PATH")
```

No issue with the declaration itself. However, `which` as a script-under-test is a bare name (not a path), and on line 72 it is passed to `realpath -- "$script"`. If `which` is not in the current directory or `$SCRIPT_DIR`, `realpath` will fail. This is a potential runtime correctness issue, not a BCS rule violation per se — flagged as a WARNING for robustness.

**Fix:** Use `$(command -v which)` or a full path if a real file is intended:
```bash
declare -a BASH_SCRIPTS=( md2ansi cln "$(command -v which)" "$SCRIPT_PATH" )
```
*(Or document that `cd "$SCRIPT_DIR"` makes these relative paths valid.)*

---

### VIOLATION — BCS1205 — Line 93

**`printf '%(%T)T'` used with `TZ=UTC0` for elapsed time display — the format `UTC0` is a non-standard timezone specification.**

```bash
TZ=UTC0 printf '%(%T)T\n' $((EPOCHSECONDS-start_time))
```

`TZ=UTC0` is a POSIX TZ string meaning "UTC with zero offset" — it works on Linux with glibc but is not the conventional `TZ=UTC` form. BCS1213 shows `TZ=UTC printf '%(%T)T'`. Using `UTC0` instead of `UTC` is a minor deviation.

More importantly: `printf '%(%T)T'` with an elapsed-seconds integer argument does not display elapsed time — it interprets the integer as a Unix epoch timestamp and formats it as a wall-clock time in UTC. For an elapsed time of e.g. 75 seconds, it would print `00:01:15`, which coincidentally looks like a duration. This works for durations under 86400 seconds but is semantically wrong (it's formatting an epoch, not a duration). This is a correctness WARNING.

**Fix for timezone:** Use `TZ=UTC`.
**Fix for elapsed time formatting:** Use `printf '%02d:%02d:%02d'` with arithmetic division, or accept the epoch-trick with a comment explaining it:
```bash
TZ=UTC printf '%(%T)T\n' $((EPOCHSECONDS - start_time))
```

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0102 | WARNING | 1 | Shebang `#!/bin/bash` — preferred form is `#!/usr/bin/bash` |
| BCS0801 | VIOLATION | 35–63 | Argument parsing uses `if/elif/else` instead of mandatory `while (($#)); do case` pattern; missing `--`, bundling, and standard exit codes |
| BCS0602 | WARNING | 59–60 | Invalid argument exits with code `1`; BCS standard is `22` for invalid arguments |
| BCS0303 | WARNING | 36, 38 | `extglob` `@(...)` patterns in `[[ ]]` for option matching; BCS0801 mandates `case` for multi-option dispatch |
| BCS0703 | WARNING | 59, 80, 82 | Status/error messages use inline `>&2 printf`/`>&2 echo` instead of `error()`/`info()`/`die()` messaging functions |
| BCS0105 | WARNING | 67 | `output_to` declared mid-script; all global variables should be declared up front |
| BCS0201 | WARNING | 11 | Bare names (`md2ansi`, `cln`, `which`) in `BASH_SCRIPTS` array passed to `realpath`; may fail if not resolvable from `$SCRIPT_DIR` |
| BCS1213 | WARNING | 93 | `TZ=UTC0` is non-standard; use `TZ=UTC`. Elapsed time via epoch `printf '%(%T)T'` is semantically an epoch format, not a duration formatter |
bcs: ◉ Tokens: in=23721 out=2671
bcs: ◉ Elapsed: 52s
