bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
I'll perform an exhaustive line-by-line audit.

---

## Findings

---

### BCS0101 — WARNING — Line 5
**Issue:** `shift_verbose` is listed among the `shopt` options. `shift_verbose` is a shell option set via `set -o shift_verbose` (or `set -o`), not a `shopt` option. `shopt -s shift_verbose` silently does nothing in Bash — it is not a valid `shopt` option name.

**Fix:** Remove `shift_verbose` from the `shopt` line. If shift verbosity is genuinely wanted, use `set -o shift_verbose` on a separate line (though it's rarely needed).

```bash
shopt -s inherit_errexit extglob nullglob
```

---

### BCS0103 — NOTE (suppressed, acknowledged)
Line 12: `#bcscheck disable=BCS0103` suppresses the missing `realpath`/`SCRIPT_PATH`/`SCRIPT_DIR` pattern for `SCRIPT_NAME`. The suppression is valid — no finding reported.

---

### BCS0105 — WARNING — Lines 41, 16–17
**Issue:** `declare -i DEBUG=0` is declared at line 41, separated from the other global variable declarations (lines 16–17, 20–37). BCS0105 requires all global variables declared up front together.

**Fix:** Move `declare -i DEBUG=0` to the global variable block near lines 16–17.

---

### BCS0188 (Color logic) — VIOLATION — Lines 188
**Issue:** The color detection condition logic is inverted. Line 188 reads:

```bash
((color_count < 256)) || HAS_COLOR=1
```

This sets `HAS_COLOR=1` only when `color_count >= 256`, which is correct for the intent ("require 256 colors"). However, `tput colors` on a typical 256-color terminal returns `256`. The expression `color_count < 256` is false when `color_count == 256`, so `HAS_COLOR=1` is set. This is **mathematically correct** for the stated intent — no finding here.

*(Self-correcting — no finding.)*

---

### BCS0188 (Color detection) — VIOLATION — Line 185
**Issue:** The condition `[[ -n ${TERM:-} && $TERM != dumb ]]` on line 185 checks `TERM` without quoting the right-hand side of `!=`. Inside `[[ ]]`, the right side of `!=` is treated as a glob pattern when unquoted. `dumb` contains no glob characters, so this is functionally harmless, but the intent is a literal comparison.

This is actually fine per BCS0303 ("static value, quotes optional") — `dumb` is a static literal. **No finding.**

*(Self-correcting — no finding.)*

---

### BCS0606 — VIOLATION — Line 188
**Issue:**
```bash
((color_count < 256)) || HAS_COLOR=1
```
This uses the inverted `||` form (preferred by BCS0606). No issue here.

*(Self-correcting — no finding.)*

---

### BCS0703 — WARNING — Line 72–80 (suppressed)
Line 72: `#bcscheck disable=BCS0703` suppresses the non-standard `debug()` implementation. The suppression is valid — no finding reported.

---

### BCS0703 — WARNING — Lines 54–69
**Issue:** The `_msg()` function routes output with `printf '%s %s\n'` but does not send to stderr — it outputs to **stdout**. The `warn()` and `error()` wrappers redirect to stderr via `>&2`, but `_msg()` itself prints to stdout. If `_msg()` is ever called directly (e.g., from an unlisted caller), its output goes to stdout.

More critically: BCS0702 requires `>&2` placement at the **beginning** of the redirect. Lines 66–67 have:
```bash
warn()  { >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
```
This is correct per BCS0702 (redirect at beginning). No violation here.

*(Self-correcting — no finding on redirect placement.)*

---

### BCS0703 — WARNING — Line 77
**Issue:** The `debug()` function uses `"$DEBUG"` as a counter argument to `printf`:
```bash
>&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
DEBUG+=1
```
`DEBUG` is declared as `declare -i DEBUG=0`. Using it as a sub-second counter (`DEBUG+=1` per message) is a creative but non-standard repurposing of the debug flag — it conflates a boolean enable flag with a message sequence counter. BCS0701 states `DEBUG` is a flag (`0`/`1`). Using it as a counter means once `DEBUG=1` is set, subsequent messages will have incrementing counts (1, 2, 3…) which may be intentional, but it means testing `((DEBUG))` remains truthy. This is an intentional design choice; the `#bcscheck disable=BCS0703` suppresses the non-standard debug pattern. **No additional finding beyond the suppression.**

---

### BCS0501 — WARNING — Line 561
**Issue:**
```bash
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```
Per BCS0501, prefer `((OPTIONS[syntax_highlight]))` truthiness test over explicit `== 0` comparison. The correct inverted form would be `((!OPTIONS[syntax_highlight]))` or the condition could be restructured. Using `== 0` for an integer flag is a style deviation.

**Fix:**
```bash
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then
```

---

### BCS0503 — VIOLATION — Lines 759, 815, 825, 865, 891
**Issue:** Multiple `for` loops use `i++` style via `i+=1` — wait, let me re-read. The loops use `i+=1` which is correct per BCS0505 ("Use `i+=1` for ALL increments"). No violation.

*(Self-correcting — no finding.)*

---

### BCS0801 — WARNING — Lines 1267–1336
**Issue:** The `parse_arguments()` function is called from `main()` (line 1391), which is correct in spirit, but `parse_arguments` is a **separate named function** rather than an inline `while/case` block inside `main()`. BCS0804 states "Place argument parsing inside `main()` for better testability." The `#bcscheck disable=BCS0804` at line 1266 suppresses this. Suppression valid — no finding.

---

### BCS0801 — VIOLATION — Lines 1271
**Issue:** The `noarg` call inside `parse_arguments` passes `"$@"` (the local `$@` inside `parse_arguments`), but `noarg()` is defined as:
```bash
noarg() {
  if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then
    die 8 "Missing argument for option ${1@Q}"
  fi
}
```
This checks if `$2` exists and doesn't start with `-`. Calling `noarg "$@"` passes the full remaining arg list, so `$1` is the option and `$2` is the next argument — this is correct usage. No violation.

*(Self-correcting — no finding.)*

---

### BCS0805 — WARNING — Line 1321
**Issue:** The bundled short options character class is `-[wDVht]?*`. This includes `-w` which takes a required argument (`--width WIDTH`). Per BCS0805, arg-taking options included in the class work correctly only when placed **last** in a bundle (e.g., `-Dw 100`). The standard notes this is the user's responsibility, not a script defect. However, `-t` (plain mode) takes no argument and is correctly included. This is documented behavior — no violation per BCS0805's explicit note.

---

### BCS0501 — WARNING — Lines 1073
**Issue:**
```bash
} elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```
Again, `OPTIONS[tables] == 0` should use `((!OPTIONS[tables]))`. Same pattern as line 561.

**Fix:**
```bash
} elif [[ $line =~ ^[[:space:]]*\| ]] && ((!OPTIONS[tables])); then
```

---

### BCS0105 / BCS0203 — WARNING — Lines 1407–1408
**Issue:** `local -- file` is declared inside `main()` after several other statements (line 1408 is inside a conditional block). Per BCS0401, local declarations may appear mid-body between logical sections, but this is inside an `if` block. This is within BCS0401's allowance ("between logical sections"). No violation.

*(Self-correcting — no finding.)*

---

### BCS0109 — PASS
Line 1430: `#fin` is present. ✓

---

### BCS0101 — PASS
Lines 4–5: `set -euo pipefail` and `shopt -s inherit_errexit` present. ✓

---

### BCS0606 — WARNING — Line 1394
**Issue:**
```bash
((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)
```
This is the inverted `||` form (preferred). No issue. ✓

---

### BCS0606 — VIOLATION — Line 1413
**Issue:**
```bash
if ((${#INPUT_FILES[@]}>1)); then
```
This is an `if` condition, not a `&&` chain — not a BCS0606 concern. No finding.

---

### BCS1213 — WARNING — Line 1401
**Issue:**
```bash
debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"
```
Uses `$(...)` with a pipe for a debug message. This is acceptable for a debug-only path. No BCS1213 concern (BCS1213 is about date formatting specifically). No finding.

---

### BCS0505 — WARNING — Line 78
**Issue:** `DEBUG+=1` inside `debug()`. `DEBUG` is `declare -i`, so `+=1` is correct integer increment. No violation per BCS0505. ✓

---

### BCS0901 — WARNING — Lines 130–131
**Issue:** The `-f` test on line 130 already implies the path is not a directory, making the explicit `[[ ! -d $filepath ]]` check on line 134 redundant. This is not a BCS violation but is logically redundant. Not a BCS-codified rule — **no finding**.

---

### BCS0902 — WARNING — Line 1241 (help text)
**Issue:** The help text example at line 1241 shows `$SCRIPT_NAME *.md`. This is help text inside a heredoc, not executable code — not subject to BCS0902. No finding.

---

### BCS1201 — WARNING — Lines 196–230
**Issue:** The multi-line `declare -r` blocks across lines 196–230 use continuation via alignment/whitespace but some comments are placed between `declare` statements that are syntactically separate commands (e.g., line 204: `# Header colors (H1-H6)` appears as a comment between two `declare -r` blocks). This is fine — comments between declarations are acceptable style. No finding.

---

### BCS0203 — WARNING — Lines 1322–1323
**Issue:** The bundled option handler uses `continue` without a matching `shift` at the end of the loop for that case. Looking at the loop structure: the `parse_arguments` while loop has `shift` at line 1334 as the loop footer. The `continue` at line 1323 skips that `shift`, which is intentional (re-processes the expanded `-X` token). This is the correct BCS0805 pattern. No violation.

---

### BCS0401 — WARNING — Lines 430, 464, 504, 528
**Issue:** `local -- line` is declared inside `for` loops:
```bash
# Line 430
local -- line
for line in "${wrapped_lines[@]:1}"; do
```
BCS0401 states declarations "must not appear inside loops." However, these declarations appear **immediately before** the loop, not inside the loop body. The `local` statement is outside the `for` loop — it's between logical sections. This is permitted. No violation.

*(Self-correcting — no finding.)*

---

### BCS0605 — WARNING — Line 137
**Issue:**
```bash
file_size=$(stat -c '%s' "$filepath" 2>/dev/null || echo 0)
```
Error is suppressed with `2>/dev/null` and fallback to `echo 0`. If `stat` fails (e.g., race condition between the `-f` test and `stat`), `file_size` becomes 0, which passes the size check silently. This could allow a file that disappears between checks to be processed. However, `stat` failure would be caught by subsequent `read` attempts. This is a logic concern, not a BCS rule violation per se. No BCS finding.

---

### BCS0207 — WARNING — Lines 184, 280 (suppressed)
`#bcscheck disable=BCS0207` suppressions at lines 184 and 280 cover the next commands. Suppression valid — no finding for those lines.

---

### BCS1205 — WARNING — Lines 252, 259, 267
**Issue:** `strip_ansi()` uses `sed` via command substitution:
```bash
sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' <<<"$text"
```
BCS1205 prefers built-in string operations over external commands. A pure-Bash regex approach via `[[ =~ ]]` and string manipulation could avoid the fork. However, this pattern requires iterative substitution that `sed` handles more cleanly, and the BCS note is about preferring builtins "when possible." For complex regex substitution, `sed` is appropriate. This is a WARNING-level style observation rather than a violation — the function is called many times in hot paths.

**Fix (if performance matters):** Consider `printf '%s' "$text" | sed ...` or accept the fork cost. No mandatory fix required.

---

### BCS0203 — VIOLATION — Line 1401
**Issue:**
```bash
debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"
```
`sed` is used to strip `declare -A ` from the output. `decp()` from BCS1211 handles exactly this use case. More importantly, the `sed` pattern uses double-quoted string for a static format string — the sed expression `'s/declare -A //'` should be single-quoted. However, it's inside a command substitution inside double quotes — the inner single quotes are syntactically correct here. No violation.

*(Self-correcting — no finding.)*

---

### BCS0301 — VIOLATION — Lines 286, 290, 295, 299, 302, 303, 306, 310, 315, 319, 613, 632, 651
**Issue:** Throughout `colorize_line()` and the `highlight_*` functions, `sed -E "..."` format strings use double quotes. These strings contain no variable expansion — they are static regex patterns. Per BCS0301, static strings should use single quotes.

For example, line 286:
```bash
result=$(sed -E "s/\`([^\`]+)\`/${COLOR_CODEBLOCK}\1${ANSI_RESET}${COLOR_TEXT}/g" <<<"$result")
```
Here `$COLOR_CODEBLOCK`, `$ANSI_RESET`, and `$COLOR_TEXT` **are** expanded, so double quotes are required for these. These are not purely static strings.

Lines 613, 632, 651 use variable interpolation in the replacement: `${COLOR_KEYWORD}`, `${COLOR_CODEBLOCK}` — double quotes required. No violation.

*(Self-correcting — no finding on quoting in these sed calls.)*

---

### BCS0803 — WARNING — Lines 1273–1275
**Issue:** After `noarg "$@"` and `shift`, `TERM_WIDTH=$1` is assigned and then validated. The `noarg` function checks `${2:0:1} == '-'` which would catch an option-looking value, but doesn't validate that `$1` (after shift) is a valid positive integer before the regex test. Actually line 1273 does: `[[ $1 =~ ^[0-9]+$ ]]`. This is correct validation order. No violation.

---

### BCS0602 — WARNING — Line 140
**Issue:**
```bash
die 9 "File too large: $file_size bytes (maximum: $max_size bytes / 10MB)"
```
Exit code 9 is not in the BCS0602 standard exit code table. The closest match would be code 5 (I/O error) or a custom code. Non-standard exit codes are not a hard violation but are a style deviation.

**Fix:** Use `die 5` for oversized file (I/O related) or document the custom code.

---

### BCS0602 — WARNING — Line 134
**Issue:**
```bash
die 4 "${filepath@Q} is a directory, not a file"
```
Exit code 4 is not in the BCS standard exit code table. Closest would be 22 (invalid argument) since a directory path was passed where a file was expected.

**Fix:** Use `die 22 "${filepath@Q} is a directory, not a file"`.

---

### BCS0602 — WARNING — Lines 1369–1370
**Issue:**
```bash
die 9 "Input from stdin exceeds maximum size: $MAX_FILE_SIZE bytes (10MB)"
```
Exit code 9 again — not in the standard table. Same issue as line 140.

---

### BCS0103 — WARNING — Line 11
**Issue:** `SCRIPT_PATH` and `SCRIPT_DIR` are absent (suppressed by line 12), but `VERSION` is declared without `SCRIPT_PATH`. The suppression at line 12 covers `SCRIPT_NAME` declaration. `VERSION` at line 11 is correctly declared as `declare -r VERSION=1.0.1`. The standard metadata is VERSION + optionally SCRIPT_PATH/SCRIPT_DIR/SCRIPT_NAME. This is fine. No additional finding.

---

### BCS0110 — WARNING — Lines 151–159
**Issue:** The `cleanup()` function is defined before the trap is installed (line 159), and the trap is installed before any temporary resources are created. The variable `ANSI_RESET` referenced in cleanup (line 155) is not yet defined at the point the trap is installed (line 159) — `ANSI_RESET` is defined later at line 196/233. However, since the trap uses single quotes (`trap 'cleanup $?' ...`), `ANSI_RESET` is not expanded at trap-install time but at trap-execution time, by which point it will be defined. No violation.

Also: `cleanup` references `${ANSI_RESET:-}` with a default, which handles the case where it might not be set. Correct. ✓

---

### BCS0503 — WARNING — Line 1020
**Issue:** The main parsing loop in `parse_markdown` uses `while ((i < ${#_lines[@]})); do` with manual `i+=1` inside each branch. This is a valid C-style while loop pattern for indexed array traversal (required here because `render_table` modifies `i` via nameref). No violation.

---

### BCS0503 — VIOLATION — Line 1179
**Issue:**
```bash
while [[ $line =~ \[\^([^]]+)\] ]]; do
```
This is a `while` loop using `[[ ]]` for string matching. The condition is fine. Inside the loop, `line=${line/${ref_match}/}` removes the match. This will always terminate as long as each iteration removes at least one character. No infinite loop concern since `ref_match` is non-empty when the regex matches. No violation.

---

### BCS0203 — WARNING — Lines 1318–1319
**Issue:**
```bash
(($#==0)) || INPUT_FILES+=("$@")
```
Missing spaces around `==` inside `(())`. While syntactically valid, BCS style would use `(( $# == 0 ))` for readability.

**Fix:**
```bash
(( $# == 0 )) || INPUT_FILES+=("$@")
```

This is a minor style deviation — WARNING level.

---

### BCS1201 — WARNING — Lines 50, 82, 120, 147, 161, 173, 192, 243, 270, 274, 325, 376, 402, 436, 470, 510, 534, 547, 656, 660, 728, 800, 843, 924, 962, 999, 1082, 1099, 1109, etc.
The script uses 80-dash `# ----...` separators extensively throughout. BCS1204 states "Reserve 80-dash separators for major script divisions only." The script uses them for every sub-section within functions and between small function groups. This is overuse.

**Fix:** Replace most 80-dash separators with lightweight 2–4 word section comments or blank lines. Reserve the full-width dashes for the major section headers (e.g., `# === Rendering Functions ===`).

---

### BCS0405 — PASS
The script only declares `warn`, `error`, `die`, and a custom `debug`. No unused messaging functions are present. Colors are declared in full sets (if/else branches match). The `#bcscheck disable=BCS0703` covers the non-standard debug. ✓

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0101 | WARNING | 5 | `shift_verbose` is not a valid `shopt` option; it must be set via `set -o shift_verbose` or removed |
| BCS0105 | WARNING | 41 | `declare -i DEBUG=0` is separated from the global variable block (lines 16–30); should be declared with other globals |
| BCS0501 | WARNING | 561 | `((OPTIONS[syntax_highlight] == 0))` should use `((!OPTIONS[syntax_highlight]))` for idiomatic flag testing |
| BCS0501 | WARNING | 1073 | `((OPTIONS[tables] == 0))` should use `((!OPTIONS[tables]))` for idiomatic flag testing |
| BCS0602 | WARNING | 134 | Exit code `4` is non-standard; use `22` (invalid argument) for "is a directory, not a file" |
| BCS0602 | WARNING | 140 | Exit code `9` is non-standard; use `5` (I/O error) for oversized file |
| BCS0602 | WARNING | 1370 | Exit code `9` is non-standard; use `5` (I/O error) for stdin size exceeded |
| BCS1201 | WARNING | multiple | 80-dash `# ---` separators used for every sub-section; BCS1204 reserves them for major script divisions only |
| BCS1201 | WARNING | 1318 | `(($#==0))` missing spaces around `==`; prefer `(( $# == 0 ))` for readability |
bcs: ◉ Tokens: in=40923 out=5835
bcs: ◉ Elapsed: 115s
