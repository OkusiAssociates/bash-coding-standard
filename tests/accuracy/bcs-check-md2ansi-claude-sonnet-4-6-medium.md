bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
I'll analyze this script systematically against the BCS.

---

## Findings

### BCS0188 — VIOLATION — Line 188: Inverted color-count logic

```bash
((color_count < 256)) || HAS_COLOR=1
```

This sets `HAS_COLOR=1` only when `color_count >= 256`. The condition is backwards: `tput colors` on a 256-color terminal returns `256`, so `256 < 256` is false, meaning `HAS_COLOR` is never set via this path. The intent is clearly to set `HAS_COLOR=1` when 256+ colors are available.

**Fix:**
```bash
((color_count >= 256)) && HAS_COLOR=1 ||:
# or equivalently:
((color_count < 256)) || { HAS_COLOR=1; }
```

Wait — re-reading: `((color_count < 256)) || HAS_COLOR=1` means: if `color_count` is NOT less than 256, set `HAS_COLOR=1`. That is: set `HAS_COLOR=1` when `color_count >= 256`. This is actually correct logic. Retracting — no finding here.

---

### BCS0606 — VIOLATION — Line 188: Missing `||:` on arithmetic-guarded assignment

```bash
((color_count < 256)) || HAS_COLOR=1
```

Under `set -e`, this is safe because the right-hand side (`HAS_COLOR=1`) always succeeds. But the inverted `||` pattern is explicitly the *preferred* form per BCS0606. This is fine — no violation.

Retracting again. The inverted `||` form is the *preferred* form, not a violation.

---

### BCS0103 — WARNING — Line 13: `SCRIPT_PATH` and `SCRIPT_DIR` absent without suppression on those variables

The `#bcscheck disable=BCS0103` on line 12 suppresses the next command (line 13: `SCRIPT_NAME`). `SCRIPT_PATH` and `SCRIPT_DIR` are not declared, which is explicitly permitted by BCS0103 ("Not all scripts will require all Script Metadata variables"). `SCRIPT_NAME` is derived from `$0` without `realpath`, which is a minor deviation — but the suppression covers it intentionally. No finding.

---

### BCS0503 — VIOLATION — Lines 759, 815, 825, 865, 891: `i++` / `i+=1` in C-style for loops

Line 759: `for ((i=0; i<${#cells[@]}; i+=1))` — uses `i+=1`. ✓ Compliant.
Line 815: `for ((i=0; i<_col_count; i+=1))` — uses `i+=1`. ✓ Compliant.
Line 825: `for ((i=0; i<${#cells[@]} && i<_col_count; i+=1))` — uses `i+=1`. ✓ Compliant.
Line 865: `for ((i=0; i<_col_count; i+=1))` — uses `i+=1`. ✓ Compliant.
Line 891: `for ((i=0; i<_col_count; i+=1))` — uses `i+=1`. ✓ Compliant.

No violations.

---

### BCS0503 — VIOLATION — Line 362: `current_len+=1` then `current_len+=$word_len` — acceptable two-step increment

These are separate `+=` increments, not `++`. Compliant.

---

### BCS0401 — VIOLATION — Lines 430, 464, 504, 528, 864: `local` declared inside loop body

```bash
# Line 430-433 (render_list_item)
for line in "${wrapped_lines[@]:1}"; do
  printf '%s%s%s\n' "$text_indent" "$line" "$ANSI_RESET"
done
```

Line 430: `local -- line` appears *before* the loop (line 430 is the local, loop starts at 431). Let me re-check:

```
429:   # Print continuation lines if any
430:   local -- line
431:   for line in "${wrapped_lines[@]:1}"; do
```

Line 430 is before the loop. ✓ Compliant.

Same pattern at lines 464, 504, 528. All `local` declarations appear before their respective loops. No violations.

---

### BCS0401 — VIOLATION — Lines 1013–1019: `local` declarations interspersed mid-body in `parse_markdown`

```bash
1013:   local -- fence lang_spec
1014:   local -- formatted_line quote_content
1015:   local -- hashes header_text
1016:   local -- indent status task_content list_content number
1017:   local -- footnote_id footnote_text
1018:   local -- ref_id ref_match
1019:   local -a wrapped
```

These are declared after early variable declarations (lines 1003–1004) and before the loop. This is explicitly permitted by BCS0401: "Declarations may appear mid-body… between logical sections." No violation.

---

### BCS0501 — VIOLATION — Line 561: Comparison against literal `0` for associative array value

```bash
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```

BCS0501 says: use `((count))` for truthiness instead of `((count > 0))` or `((FLAG == 1))`. The equivalent idiomatic form would be `((!OPTIONS[syntax_highlight]))`. This is a WARNING-level style deviation, not a VIOLATION (it's functionally correct).

**Fix:**
```bash
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then
```

---

### BCS0606 — VIOLATION — Line 793: Missing `||:` on `&&` chain under `set -e`

```bash
((${#cells[@]} <= max_cols)) || max_cols=${#cells[@]}
```

This uses the preferred inverted `||` form. The right-hand side always succeeds. Safe. No violation.

---

### BCS0606 — VIOLATION — Line 836: Same pattern

```bash
((width <= _col_widths[i])) || _col_widths[i]=$width
```

Preferred inverted `||` form. No violation.

---

### BCS0606 — VIOLATION — Line 942: `((padding >= 0)) || padding=0`

Preferred inverted `||` form. No violation.

---

### BCS0806 — WARNING — Lines 1321–1323: Option bundling character class includes `-t` but `--plain` has no argument

```bash
-[wDVht]?*) # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

The character class includes `w`, which takes a required argument (`--width WIDTH`). Per BCS0805: "The user must place arg-taking options last in a bundle." This is documented behavior, not a defect. No violation.

---

### BCS0503 — VIOLATION — Lines 362–363: Separate increments instead of single compound operation

```bash
current_len+=1
current_len+=$word_len
```

This is two `+=` operations rather than `((current_len += word_len + 1))`. The BCS does not mandate combining arithmetic into a single statement — both are compliant. No violation.

---

### BCS0201 — WARNING — Lines 186–188: `color_count` declared with `declare -i` inside `if` block at global scope, but not as `local`

```bash
185: if [[ -t 1 && -t 2 ]] || [[ -n ${TERM:-} && $TERM != dumb ]]; then
186:   declare -i color_count
187:   color_count=$(tput colors 2>/dev/null || echo 0)
188:   ((color_count < 256)) || HAS_COLOR=1
189: fi
```

`color_count` is declared at global scope inside an `if` block. Since this is top-level script code (not a function), `local` is not applicable. `declare -i` is correct. However, `color_count` persists as a global variable after the `if` block completes — it leaks into the script's global namespace unnecessarily. A minor style issue but technically compliant since this is global scope. No finding per BCS.

---

### BCS0301 — WARNING — Line 77: Double-quoted static string fragments mixed with variables

```bash
>&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
```

The format string `'[%(%T)T.%s] %s⦿%s %s\n'` is correctly single-quoted (literal format). ✓

---

### BCS0703 — WARNING — Line 77: `debug()` increments `DEBUG` counter

```bash
debug() {
  ((DEBUG)) || return 0
  local -- msg
  for msg in "$@"; do
    >&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
    DEBUG+=1
  done
}
```

`DEBUG` is used both as a boolean flag (`((DEBUG)) || return 0`) and as a counter that increments with each call. This is a creative but non-standard design — callers set `DEBUG=1` to enable, and each debug message increments the counter. However, if `DEBUG` is declared with `declare -i` (line 41), this works correctly. The `#bcscheck disable=BCS0703` suppression on line 72 covers this intentional deviation. No finding.

---

### BCS0702 — WARNING — Line 62: `_msg()` does not redirect to stderr

```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    warn)    prefix+=" $YELLOW▲$NC" ;;
    error)   prefix+=" $RED✗$NC" ;;
    *) ;;
  esac
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}
```

`_msg()` writes to stdout. The callers (`warn()`, `error()`) redirect to stderr via `>&2 _msg`. This is correct — the redirection happens at the call site. ✓ No violation.

---

### BCS0101 — WARNING — Line 5: `shift_verbose` included in `shopt`

```bash
shopt -s inherit_errexit shift_verbose extglob nullglob
```

`shift_verbose` is appropriate here per BCS0101. ✓

---

### BCS0503 — VIOLATION — Line 1394: `||` without `||:` on arithmetic+command assignment

```bash
((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)
```

This uses the preferred inverted `||` form. The right-hand side is a command substitution assignment — if `get_terminal_width` fails, this line fails and the script exits under `set -e`. This is intentional fail-fast behavior. ✓ No violation.

---

### BCS0401 — VIOLATION — Line 1408: `local` declared inside `main()` after argument parsing

```bash
1407:   if ((${#INPUT_FILES[@]})); then
1408:     local -- file
1409:     for file in "${INPUT_FILES[@]}"; do
```

`local -- file` is declared inside an `if` block, which is mid-body. BCS0401 explicitly permits declarations "between logical sections." This is acceptable. No violation.

---

### BCS0301 — VIOLATION — Line 1073: Redundant condition check

```bash
1069:     if [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables])); then
1070:       render_table _lines i
1071:       # render_table updates i to next line after table
1072:       continue
1073:     elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```

The `elif` re-checks `$line =~ ^[[:space:]]*\|` which is already known true (we're in the `elif` branch, so the `if` failed only because `OPTIONS[tables]` was 0). The equivalent of `((OPTIONS[tables] == 0))` is just `((!OPTIONS[tables]))` — if the `if` failed with the regex matching, the only reason is `OPTIONS[tables]` is 0. This is a style/logic redundancy, not a BCS violation per se. However, the use of `((OPTIONS[tables] == 0))` vs `((!OPTIONS[tables]))` is a BCS0501 style note.

**Finding:** BCS0501 WARNING at line 1073 — `((OPTIONS[tables] == 0))` should be `((!OPTIONS[tables]))`.

---

### Real findings summary after thorough analysis:

**BCS0501 — WARNING — Lines 561, 1073:** Equality comparison against 0 for boolean/flag values instead of negation operator.

```bash
# Line 561
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
# Should be:
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then

# Line 1073
elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
# Should be:
elif [[ $line =~ ^[[:space:]]*\| ]] && ((!OPTIONS[tables])); then
```

**BCS0108 — WARNING — Lines 1267–1336:** `parse_arguments()` is a separate function called from `main()` rather than argument parsing being inline within `main()`. The `#bcscheck disable=BCS0804` suppresses BCS0804 (parsing location), but BCS0108 (main function structure) is not suppressed. Per BCS0804: "Place argument parsing inside `main()` for better testability." The suppression on line 1266 (`#bcscheck disable=BCS0804`) directly addresses this. Since the suppression is present and BCS0804 is the rule being cited, this is fully suppressed. No finding.

---

### BCS0606 — VIOLATION — Line 1318: `(($#==0))` — spacing style

```bash
(($#==0)) || INPUT_FILES+=("$@")
```

No spaces around `==` inside `(())`. This is purely a style choice — arithmetic expressions inside `(())` work without spaces. Very minor, not a BCS rule. No finding.

---

### BCS0401 — VIOLATION — Line 1362: `local -i byte_count=0` declared mid-body inside `else` block

```bash
1359:   else
1360:     # Process stdin
1361:     debug 'Processing stdin'
1362:     local -i byte_count=0
```

Per BCS0401: "Declarations may appear mid-body (e.g., after early-return guards, inside conditionals, or between logical sections)." The key prohibition is *inside loops*. Being inside an `else` block is explicitly permitted ("inside conditionals"). ✓ No violation.

---

### Actual Confirmed Findings

#### BCS0501 — WARNING — Line 561

```bash
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```

Comparing flag to literal `0` instead of using negation. Should be `((!OPTIONS[syntax_highlight]))`.

#### BCS0501 — WARNING — Line 1073

```bash
elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```

Same issue: `((OPTIONS[tables] == 0))` should be `((!OPTIONS[tables]))`.

#### BCS0301 — WARNING — Line 45: NC declared before RED/YELLOW for readability convention

```bash
declare -r NC=$'\033[0m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m'
```

Minor: `NC` is declared first in the line rather than last (conventional to declare `NC` last as "no color" reset). BCS0706 example shows `NC` last. Very minor style point.

Actually, BCS0706 shows: `declare -r RED=... GREEN=... YELLOW=... CYAN=... NC=...` — `NC` is last. This is a reference pattern deviation. Very minor WARNING.

#### BCS0104 — OBSERVATION — No `PREFIX` support

The script has no installation path support. Since this is a rendering tool without installation logic shown, this is not applicable. No finding.

---

## Final Confirmed Findings

After careful analysis, the only genuine deviations are:

---

### Finding 1: BCS0501 — WARNING — Lines 561, 1073

**What:** Boolean flag values compared to literal `0` using `==` instead of the idiomatic negation form.

**Line 561:**
```bash
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```
**Line 1073:**
```bash
elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```

**Fix:**
```bash
# Line 561
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then

# Line 1073
elif [[ $line =~ ^[[:space:]]*\| ]] && ((!OPTIONS[tables])); then
```

---

### Finding 2: BCS0706 — WARNING — Line 45

**What:** `NC` declared before `RED` and `YELLOW` in the color declaration block. The BCS0706 reference pattern shows `NC` last (as it is the "no color" reset, logically following the color definitions).

**Line 45:**
```bash
declare -r NC=$'\033[0m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m'
```

**Fix:**
```bash
declare -r RED=$'\033[0;31m' YELLOW=$'\033[0;33m' NC=$'\033[0m'
```

(And the corresponding `else` branch at line 47 similarly.)

---

### Finding 3: BCS0103 — WARNING — Lines 10–13: `SCRIPT_PATH`/`SCRIPT_DIR` absent, `SCRIPT_NAME` derived without `realpath`

The `#bcscheck disable=BCS0103` suppression covers line 13. The suppression is valid and the finding is suppressed. **No reportable finding.**

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0501 | WARNING | 561 | `((OPTIONS[syntax_highlight] == 0))` — use `((!OPTIONS[syntax_highlight]))` instead of comparing flag to literal `0` |
| BCS0501 | WARNING | 1073 | `((OPTIONS[tables] == 0))` — use `((!OPTIONS[tables]))` instead of comparing flag to literal `0` |
| BCS0706 | WARNING | 45, 47 | `NC` declared first in color block; BCS0706 reference pattern places `NC` last as the reset sentinel |
bcs: ◉ Tokens: in=40925 out=4827
bcs: ◉ Elapsed: 87s
