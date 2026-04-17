bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
I'll analyze the script systematically against the BCS rules.

---

## Findings

---

**[WARN] BCS0102 line 1: Shebang uses `env bash` form**
`#!/usr/bin/env bash` is acceptable per BCS0102 but the preferred form for Linux systems is `#!/usr/bin/bash`. Minor deviation only.
*Fix:* Change to `#!/usr/bin/bash` if targeting Linux.

---

**[WARN] BCS0103 line 13: `SCRIPT_PATH` and `SCRIPT_DIR` omitted without suppression**
`SCRIPT_NAME` is derived from `${0##*/}` directly rather than from `SCRIPT_PATH`. This is a deviation from the standard pattern (which derives `SCRIPT_NAME` from `realpath`-resolved `SCRIPT_PATH`). The `#bcscheck disable=BCS0103` at line 12 suppresses the rule entirely, so this is not reportable. *No finding — suppressed.*

---

**[WARN] BCS0105 line 41: `DEBUG` declared after color block and messaging functions, not at the top with other globals**
`declare -i DEBUG=0` appears at line 41, after the color block setup at lines 44–48, but before the messaging functions. The global variable section (lines 15–37) is where all globals should be declared. `DEBUG` is separated from the other global declarations by the `## Utility Functions ##` section comment.
*Fix:* Move `declare -i DEBUG=0` to the global configuration section (e.g., line 18 alongside `TERM_WIDTH` and `MAX_FILE_SIZE`).

---

**[ERROR] BCS0110 line 159: Trap installed before cleanup function is fully understood in context — actually correct; but `ANSI_RESET` is used in `cleanup()` before it is defined**
`cleanup()` references `$ANSI_RESET` at line 155, but `ANSI_RESET` is only declared at lines 196–233 (inside the `if ((HAS_COLOR))` block). The trap is installed at line 159. If the script exits between lines 159 and 194 (e.g., during `tput colors` at line 187), `cleanup()` will reference an unbound variable, which under `set -u` causes a fatal error in the cleanup handler itself.
*Fix:* Either declare `ANSI_RESET=''` as a global default before line 159, or guard the reference in `cleanup()` with `${ANSI_RESET:-}` (which it already does — line 155 uses `${ANSI_RESET:-}`, so `set -u` is safe here). *Retracting — line 155 already uses `${ANSI_RESET:-}`, this is handled correctly.* No finding.

---

**[WARN] BCS0203 line 39: Section comment uses `##` double-hash decoration**
`## Utility Functions ##` uses `##` prefix and trailing `##`. BCS1204 specifies section comments must use a single `#` prefix with no box-drawing or decorative characters.
*Fix:* Change to `# Utility functions` (single `#`, 2–4 words, followed by blank line).

---

**[WARN] BCS0503 line 759: `for ((i=0; ...))` loop uses `i+=1` correctly but `i` is not declared `local` before the loop in `_parse_table_structure()`**
In `_parse_table_structure()`, `i` is declared at line 743 as `local -i row_num=0 max_cols=0 i` — this is correct, `i` is `local`. *No finding.*

---

**[ERROR] BCS0503 line 362–363: `current_len` incremented in two separate statements inside loop**
```bash
current_len+=1
current_len+=$word_len
```
This is functionally correct but the idiomatic form is `current_len=$((current_len + 1 + word_len))` or `((current_len += 1 + word_len))`. This is a style matter, not a violation. *No finding.*

---

**[WARN] BCS0606 line 188: `((color_count < 256)) || HAS_COLOR=1` — inverted form, correct**
This is the inverted `||` form. No `||:` needed. *No finding.*

---

**[WARN] BCS0606 line 1394: `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` — inverted form, correct. No finding.**

---

**[ERROR] BCS0801 line 1267–1336: `parse_arguments()` uses `while (($#))` with `case` but the mandatory `shift` at loop end is inside the `case` block only for some arms — the function has a `shift` at line 1334 at the bottom of the loop, which is correct. However, the `continue` at line 1323 (option bundling) bypasses the bottom `shift`. This is intentional and correct for bundling (re-processes the split option without shifting). No finding.**

---

**[WARN] BCS0804 line 1266–1336: Argument parsing placed in a separate `parse_arguments()` function rather than inside `main()`**
BCS0804 recommends placing parsing inside `main()`. The `#bcscheck disable=BCS0804` at line 1266 suppresses this. *No finding — suppressed.*

---

**[ERROR] BCS0801 line 1321: Option bundling character class `-[wDVht]?*` includes `-t` but `-t` (`--plain`) sets six associative array keys — it takes no argument, so this is fine. However, `-w` takes an argument. BCS0805 notes that arg-taking options must be last in a bundle for correct disaggregation. The character class correctly includes `-w`, and the user must place it last. This is documented behavior. No finding.**

---

**[WARN] BCS1202 lines 53, 65, 68, 71, 85–86, 123–124, 133, 136, 150, 164–165, 246–247, 255–256, 263–264, 277–279, 328–329, 379–380, 405–407, 436–437, 471–472, 513–514, 537–538, 550–551, 592–593, 619–620, 637–638, 663–665, 731–732, 802–804, 846–847, 927–928, 970–971, 999–1000, 1209, 1265, 1338–1340, 1387: Many comments describe function purpose/usage — these are acceptable as API documentation, not code-paraphrasing. No mass finding.**

Specific paraphrasing violations:

**[WARN] BCS1202 line 133: Comment paraphrases the next statement**
```bash
# Check if it's a directory
[[ ! -d $filepath ]] || die 4 "${filepath@Q} is a directory, not a file"
```
The comment adds nothing a competent reader cannot see from the test itself.
*Fix:* Remove the comment, or replace with something non-obvious if there is a rationale (e.g., why this check comes after the `-f` check).

**[WARN] BCS1202 line 136: Comment paraphrases**
```bash
# Get file size in bytes
file_size=$(stat -c '%s' "$filepath" 2>/dev/null || echo 0)
```
*Fix:* Remove or annotate with a non-obvious detail (e.g., `# stat -c '%s' is Linux-specific; BSD uses -f '%z'`).

**[WARN] BCS1202 line 1006–1010: Comments "Reset parsing state" followed by variable resets — the comment adds no information not visible from the statements.**
*Fix:* Remove.

**[WARN] BCS1202 line 1390: `# Parse command-line arguments` before `parse_arguments "$@"` — paraphrasing.**
*Fix:* Remove.

**[WARN] BCS1202 line 1393: `# Determine terminal width` before the `((TERM_WIDTH)) || ...` line — paraphrasing.**
*Fix:* Remove.

**[WARN] BCS1202 line 1403: `# Print initial reset to ensure clean terminal state` is borderline — it explains *why* (ensure clean state). Acceptable. No finding.**

---

**[WARN] BCS1201 line 17: Inline arithmetic expression uses `$((10*1024*1024))` with no spaces**
```bash
declare -i MAX_FILE_SIZE=$((10*1024*1024))
```
Style: `$((10 * 1024 * 1024))` with spaces around operators is more readable and consistent.
*Fix:* `declare -i MAX_FILE_SIZE=$((10 * 1024 * 1024))`

---

**[WARN] BCS1204 line 39: Section comment format violation**
`## Utility Functions ##` uses `##` prefix and trailing decorators instead of single `#`.
*Fix:* `# Utility functions`

---

**[WARN] BCS1204 lines 82, 120, 147, 161, 173, 192, 243, 270, 274, 325, 376, 402, 510, 534, 547, 656, 660, 695, 717, 722, 724, 728, 800, 843, 861, 872, 877, 887, 919, 924, 962, 966–968, 1027, 1060, 1067, 1082, 1090, 1099, 1109, 1126, 1136, 1147, 1166, 1174, 1198, 1205, 1428: Many section dividers use the `# ---...---` (80-dash) format**
BCS1204 states 80-dash separators should be reserved for major script divisions, "typically no more than two or three per file." This script uses them as section dividers throughout every subsection — at least 30+ occurrences. This is a pervasive style violation.
*Fix:* Reserve `# ----` lines for 2–3 top-level divisions (e.g., between the ANSI library, the parser, and main). Replace subsection dividers with simple `# Section name` comments.

---

**[ERROR] BCS0503 line 355: Loop variable `word` declared before the loop at line 335 as part of a compound `local` declaration — correct. No finding.**

---

**[WARN] BCS0905 line 252: Uses `sed ... <<<"$text"` instead of a builtin approach**
`strip_ansi` forks `sed` for every call, and it is called in tight loops (per cell in tables, per word in wrapping). This is a performance concern for large documents. No pure-bash ANSI-strip is practical without `sed`, so this is unavoidable given the constraint, but worth noting.
*Fix:* Document the performance trade-off; no pure alternative without external tools.

---

**[WARN] BCS0105 line 16: `declare -i TERM_WIDTH=0` comment `# 0 means auto-detect` — this is informative and acceptable. No finding.**

---

**[ERROR] BCS0401 line 430, 464, 504, 528: `local -- line` declared mid-body inside functions, after `readarray` — per BCS0401, declarations mid-body are permitted ("between logical sections"), only prohibited inside loops. These are after `readarray` and before a `for` loop. Acceptable. No finding.**

---

**[WARN] BCS0703 line 77: `debug()` uses `$DEBUG` as a counter/timestamp field in the format string**
```bash
>&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
DEBUG+=1
```
`DEBUG` is declared as `declare -i DEBUG=0` (an integer flag). Using it as both a boolean enable flag and an incrementing sequence counter is a dual-purpose anti-pattern. When `DEBUG=1` is set by the user, the first message shows `.1`, subsequent ones `.2`, `.3`, etc. This is an intentional design (a call counter), but it means `DEBUG` is not a pure boolean flag as BCS0208 recommends. The `#bcscheck disable=BCS0703` suppresses the messaging-function-pattern rule but not BCS0208.
*Fix:* Use a separate `declare -i DEBUG_COUNT=0` counter, keep `DEBUG` as a pure 0/1 flag. Or document this intentional dual-use with a comment.

---

**[WARN] BCS0208 line 41: `DEBUG` used as both a boolean and a call counter (see above)**
The `((DEBUG)) || return 0` test at line 74 correctly gates on non-zero, so the counter doubling as a flag works (any non-zero integer is true). However, this violates the intent of BCS0208 which calls for `declare -i` flags to be 0/1.
*Fix:* Separate the counter from the flag as noted above.

---

**[WARN] BCS1213 line 77: Uses `%(%T)T` builtin — correct and preferred. No finding.**

---

**[WARN] BCS0502 line 561: `((OPTIONS[syntax_highlight] == 0))` — BCS0501 recommends testing `((flag))` or `((! flag))` rather than explicit `== 0` comparison**
```bash
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```
The idiomatic form is `(( ! OPTIONS[syntax_highlight] ))`.
*Fix:* `if (( ! OPTIONS[syntax_highlight] )) || [[ -z $lang ]]; then`

---

**[WARN] BCS0503 line 793: `((${#cells[@]} <= max_cols)) || max_cols=${#cells[@]}` — inverted form, correct, no `||:` needed since RHS is an assignment. No finding.**

---

**[ERROR] BCS0604 line 1401: `declare -p OPTIONS | sed ...` — `PIPESTATUS` not checked after this pipeline**
```bash
debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"
```
Under `set -o pipefail`, if `declare -p` or `sed` fails this will propagate. However this is inside a `debug()` call which is gated on `((DEBUG))`. In practice `declare -p OPTIONS` on a declared associative array never fails. Low severity. No formal finding.

---

**[WARN] BCS0711 line 252 and others: Uses `<<<"$text"` here-strings — correct. Uses `>/dev/null` and `2>/dev/null` appropriately. However, line 8 sets `PS4` but this is only useful when `set -x` is active. Storing it globally is fine for a debug-capable script.**

---

**[ERROR] BCS0606 line 1394: `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` — this is the inverted `||` form; the RHS returns 0. No `||:` needed. No finding.**

---

**[WARN] BCS1202 line 1196: Comment block inside `parse_markdown()` loop**
```bash
# Remove matched part to find next
line=${line/${ref_match}/}
```
"Remove matched part to find next" paraphrases the substitution. The non-obvious part (that this is a loop to find *all* footnote references, consuming them one by one) is conveyed by the `while` structure, not this comment.
*Fix:* Remove the comment or replace with something that explains *why* `line` is modified instead of using a different regex approach.

---

Now let me compile only the genuine findings, removing any I retracted above:

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0102 | recommended | WARN | 1 | `#!/usr/bin/env bash` used; preferred form for Linux is `#!/usr/bin/bash` |
| BCS0105 | recommended | WARN | 41 | `DEBUG` declared after color block, separated from global variable section |
| BCS1204 | style | WARN | 39 | `## Utility Functions ##` uses `##` prefix/suffix decoration; must be single `#` |
| BCS1204 | style | WARN | 30+ locations | 80-dash `# ---` separators used for every subsection; BCS limits to 2–3 major divisions per file |
| BCS0208 | recommended | WARN | 41, 74, 77–79 | `DEBUG` used as both a boolean enable flag and an incrementing call counter; BCS0208 requires 0/1 semantics |
| BCS1201 | style | WARN | 17 | `$((10*1024*1024))` lacks spaces around operators; prefer `$((10 * 1024 * 1024))` |
| BCS0501 | core | WARN | 561 | `((OPTIONS[syntax_highlight] == 0))` should be `(( ! OPTIONS[syntax_highlight] ))` per idiomatic integer-flag testing |
| BCS1202 | style | WARN | 133, 136, 1006–1010, 1390, 1393 | Comments paraphrase the immediately following statements without adding information |
bcs: ◉ Tokens: in=45581 out=4346
bcs: ◉ Elapsed: 83s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
