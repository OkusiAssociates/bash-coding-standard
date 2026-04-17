bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
I'll perform an exhaustive line-by-line audit of this script against the BCS.

---

## Findings

**[WARN] BCS0102 line 1:** Shebang uses `#!/usr/bin/env bash`. This is the least-preferred form per BCS0102 ("Preferred for Linux systems" is `#!/usr/bin/bash`). All three forms are acceptable, so this is a style note only.
*Fix:* Change to `#!/usr/bin/bash` (preferred) or `#!/bin/bash`.

---

**[WARN] BCS0103 line 13:** `SCRIPT_PATH` and `SCRIPT_DIR` are omitted. BCS0103 notes "Not all scripts will require all four," and the script does use `SCRIPT_NAME` correctly, so this is not a violation. However, `SCRIPT_NAME` is derived as `${0##*/}` rather than from `realpath`-derived `SCRIPT_PATH`. This is a weaker form — if invoked through a symlink, `$0` gives the symlink name rather than the canonical name.
*Fix:* Either suppress with `#bcscheck disable=BCS0103` on the `SCRIPT_NAME` line (already suppressed via line 12), or derive via `realpath`. The suppression on line 12 covers this — **no reportable violation**.

---

**[WARN] BCS0105 line 41:** `DEBUG` is declared after the color block and after `## Utility Functions ##` comment, not with the other global variables at the top. BCS0105 requires all global variables declared up front together.
*Fix:* Move `declare -i DEBUG=0` to the global variable declaration section (around lines 16–37).

---

**[WARN] BCS0105 line 182:** `HAS_COLOR` is declared (`declare -i HAS_COLOR=0`) deep in the script body (line 182), separated from the other global declarations by ~140 lines of function definitions. BCS0105 requires global variables declared up front.
*Fix:* Move `declare -i HAS_COLOR=0` to the global variable section at the top.

---

**[WARN] BCS0107 line 39:** The comment `## Utility Functions ##` uses double `##` delimiters. BCS0107/BCS1204 specifies section comments use a single `#`. Double `##` is not the standard form.
*Fix:* Change to `# Utility Functions` (single `#`).

---

**[WARN] BCS0107 / BCS1204 line 39:** Beyond the `##` formatting, the section comment does not follow the bottom-up organization rule. Messaging functions are defined starting at line 54, but `debug()` at line 73 is defined after `warn()`, `error()`, and `die()` at lines 66–69. While `debug` is a messaging function at the same layer, `get_terminal_width()` (line 87) calls `debug()` (line 95), which is fine since `debug` is already defined. The ordering is acceptable. **No violation.**

---

**[WARN] BCS0107 line 972:** `render_footnotes()` is defined at line 972 but is called by `parse_markdown()` at line 1201. `parse_markdown()` is defined starting at line 1001. The call occurs inside `parse_markdown`, after `render_footnotes` is defined — this is fine. However, `render_footnotes` appears *after* the comment block at line 966 says "Main markdown parser" suggesting it's part of that section, yet it's actually a rendering function. This is a minor organizational issue but not a strict BCS0107 violation since `render_footnotes` is defined before it is called.

---

**[WARN] BCS0108 line 1266:** Argument parsing is done in a standalone `parse_arguments()` function rather than inside `main()`. BCS0804 recommends parsing inside `main()` for testability, but the script has `#bcscheck disable=BCS0804` on line 1266, which suppresses this finding. **No reportable violation.**

---

**[WARN] BCS0201 line 186:** `color_count` is declared `declare -i color_count` inside an `if` block at script top level (not inside a function). BCS0201 and BCS0105 expect global variables to be declared with explicit types, and this is correctly typed. However, it is a temporary variable used only within the block — it leaks into the global scope. It should not persist.
*Fix:* This is inside a top-level conditional, not a function, so `local` is not available. Use a subshell or unset after use: `unset color_count`. Alternatively, restructure the detection into a function. This is a [WARN] since the variable is effectively dead after the block.

---

**[WARN] BCS0201 line 187:** `color_count=$(tput colors 2>/dev/null || echo 0)` — the SC2155 pattern (declare and assign in one line) applies here without a `#shellcheck disable=SC2155`. However, this is not a `declare` statement — it's a plain assignment to an already-declared variable, so SC2155 does not apply. **No violation.**

---

**[ERROR] BCS0501 line 561:** `((OPTIONS[syntax_highlight] == 0))` — BCS0501 states "use `((count))` instead" of `((count > 0))` and similarly discourages explicit `== 0` comparisons when an integer truthiness test suffices. More precisely, the comparison `((OPTIONS[syntax_highlight] == 0))` should be `((!OPTIONS[syntax_highlight]))` for consistency with the BCS arithmetic truthiness convention.
*Fix:* Change to `((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]`.

---

**[WARN] BCS0503 line 759:** `for ((i=0; i<${#cells[@]}; i+=1))` — the loop variable `i` is declared `local -i i` at line 743 before the loop, which is correct per BCS0401 ("Declare local variables before loops, not inside"). **No violation.**

---

**[WARN] BCS0503 line 1362:** `local -i byte_count=0` is declared inside `process_file()`, which is correct. However, it is declared mid-function after an `if` branch. BCS0401 says declarations "may appear mid-body (e.g., after early-return guards, inside conditionals, or between logical sections), but must not appear inside loops." This is inside an `if` block, not a loop — **no violation**.

---

**[WARN] BCS0503 line 430:** `local -- line` is declared inside the loop body:

```bash
# Print continuation lines if any
local -- line
for line in "${wrapped_lines[@]:1}"; do
```

Wait — line 430 shows `local -- line` *before* the `for` loop at line 431. Let me re-read: line 430 is `local -- line` and line 431 is `for line in "${wrapped_lines[@]:1}"; do`. The `local` is declared just before the loop, not inside it. **No violation.**

Similarly at lines 464, 504, 528 — all `local -- line` declarations appear immediately before their respective `for` loops, not inside them. **No violations.**

---

**[WARN] BCS0504 line 1394:** `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` — This is the inverted form, no `||:` needed. **No violation.**

---

**[ERROR] BCS0606 line 188:** 

```bash
((color_count < 256)) || HAS_COLOR=1
```

This is the inverted form — `||` is used, so no `||:` is required. Under `set -e`, `((color_count < 256))` returns exit code 1 when the condition is false (i.e., when `color_count >= 256`), which would trigger `HAS_COLOR=1` on the RHS. This is correct — the `||` catches the failure. **No violation.**

---

**[ERROR] BCS0606 line 1394:**

```bash
((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)
```

Inverted form, `||` on the RHS. **No violation.**

---

**[WARN] BCS0702 line 62:** Inside `_msg()`, `printf '%s %s\n' "$prefix" "$msg"` outputs to stdout, not stderr. The messaging function dispatches to stderr only at the `warn()`/`error()` wrapper level (`>&2 _msg "$@"`), but `_msg` itself writes to stdout. This means if `_msg` is ever called directly, output goes to stdout. The pattern is the same as the BCS reference implementation where `_msg` itself has no redirection and the callers add `>&2`. **No violation** — this matches the BCS0703 reference pattern exactly.

---

**[WARN] BCS0703 line 73–80:** The `debug()` function deviates from the BCS0703 reference pattern — it uses `printf` with a timestamp format and increments `DEBUG` as a counter. The `#bcscheck disable=BCS0703` on line 72 suppresses this finding. **No reportable violation.**

---

**[WARN] BCS0706 lines 44–48:** The script defines only `NC`, `RED`, and `YELLOW` in the early color block for messaging. These are used by `_msg()` (lines 57–58). The script also defines a full ANSI color set starting at line 194. Both blocks correctly check `[[ -t 1 && -t 2 ]]` and the HAS_COLOR condition respectively.

However, the early messaging color block (lines 44–48) only has 3 colors (`NC`, `RED`, `YELLOW`) and the else branch also correctly has 3 empty strings. Both branches declare the same variables. **No violation** per BCS0405 — only used colors need to be declared.

---

**[WARN] BCS0706 lines 194–241:** The ANSI color definitions use `if ((HAS_COLOR))` rather than `if [[ -t 1 && -t 2 ]]`. BCS0706 specifies `if [[ -t 1 && -t 2 ]]`. The script uses `HAS_COLOR` which incorporates terminal detection *and* 256-color support check. This is a more sophisticated check but deviates from the BCS0706 reference pattern.
*Fix:* This is an intentional design choice (the script needs 256-color support). Document the deviation. As written it is a [WARN] against the reference pattern.

---

**[WARN] BCS0802 line 1281:** `echo "$SCRIPT_NAME $VERSION"` — correct format per BCS0802. **No violation.**

---

**[WARN] BCS0803 line 1271:** `noarg "$@"` is called correctly before `shift` and argument capture. **No violation.**

---

**[WARN] BCS0805 line 1321:** The bundled short option pattern is:

```bash
-[wDVht]?*) # Bundled short options
  set -- "${1:0:2}" "-${1:2}" "${@:2}"
  continue
  ;;
```

The character class `[wDVht]` includes `t` (`--plain`). The `-t` option takes no argument, which is correct for bundling. `-w` takes an argument (`--width WIDTH`) — BCS0805 notes "the user must place arg-taking options last in a bundle." The character class includes `w` which takes an argument. This is documented in BCS0805 as the user's responsibility, not a script defect. **No violation.**

---

**[WARN] BCS0901 line 130:** `die 3 "File not found ${filepath@Q}"` — uses `@Q` correctly. **No violation.**

---

**[WARN] BCS0901 line 134:** Exit code `4` is used for "is a directory." BCS0602 does not list code 4 as a standard code. The closest would be code 3 (file/directory not found) or 22 (invalid argument). This is a minor deviation from the standard exit code table.
*Fix:* Use `die 22 "${filepath@Q} is a directory, not a file"` or `die 3`.

---

**[WARN] BCS0901 line 140:** Exit code `9` is used for file-too-large. BCS0602 does not list code 9 as a standard code.
*Fix:* Use a standard code; `5` (I/O error) or `22` (invalid argument) would be more appropriate.

---

**[WARN] BCS1201 line 17:** `declare -i MAX_FILE_SIZE=$((10*1024*1024))` — the arithmetic in the initializer `$((10*1024*1024))` uses `*` without spaces. This is syntactically valid but style-wise could use spaces: `$((10 * 1024 * 1024))`. Minor style note.

---

**[WARN] BCS1202 line 133:** Comment `# Check if it's a directory` directly before `[[ ! -d $filepath ]]` — this is a paraphrasing comment per BCS1202. The comment restates what the test condition checks without adding information.
*Fix:* Remove the comment, or replace with something that adds context (e.g., `# Reject directories even if -f passed due to symlinks`).

---

**[WARN] BCS1202 line 136:** Comment `# Get file size in bytes` before `file_size=$(stat -c '%s' "$filepath" ...)` — paraphrases the code.
*Fix:* Remove, or note why `stat` is used instead of `wc -c` (no fork on file open, faster).

---

**[WARN] BCS1202 line 183:** Comment `# Check if we have a terminal` before `if [[ -t 1 && -t 2 ]] || ...` — paraphrases the condition.
*Fix:* Remove or replace with a note about the dual-condition rationale.

---

**[WARN] BCS1202 line 350:** Comment `# Build wrapped lines` before `current_line=${words[0]}` — describes what the next block does, which is visible from the code.
*Fix:* Remove.

---

**[WARN] BCS1202 line 372:** Comment `# Print last line` before `[[ -z $current_line ]] || echo "$current_line"` — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 415:** Comment `# Calculate indentation level (every 2 spaces = 1 level)` — this actually adds information (the algorithm: every 2 spaces = 1 level). **No violation** — this is a valid informational comment.

---

**[WARN] BCS1202 line 566:** Comment `# Normalize language name` before a `case` that normalizes language names — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 573:** Comment `# Apply simple syntax highlighting based on language` before a `case` that dispatches by language — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 1006:** Comment `# Reset parsing state` before assignments resetting parsing state — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 1390:** Comment `# Parse command-line arguments` before `parse_arguments "$@"` — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 1393:** Comment `# Determine terminal width` before the `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` line — paraphrases.
*Fix:* Remove.

---

**[WARN] BCS1202 line 1403:** Comment `# Print initial reset to ensure clean terminal state` before `printf '%s' "$ANSI_RESET"` — adds some rationale ("ensure clean terminal state") that isn't fully obvious. Borderline. The comment explains *why*, not just *what*. **No violation.**

---

**[WARN] BCS1202 line 1422:** Comment `# Ensure terminal colors are reset at the end` before `printf '%s' "$ANSI_RESET"` — similar to above, explains why. **No violation.**

---

**[WARN] BCS1203 line 50:** `# --------------------------------------------------------------------------------` separator — the 80-dash separator is used extensively throughout this script (approximately 30 times). BCS1204 states "Reserve 80-dash separators for major script divisions only — typically no more than two or three per file." With ~30 occurrences, this is a clear overuse.
*Fix:* Replace section dividers within functions and between minor sections with blank lines or simple `# Section name` comments. Reserve `# ---` lines for the 2–3 major divisions (e.g., between major functional groups at the top level).

---

**[WARN] BCS1204 line 39:** `## Utility Functions ##` — double `##` prefix and suffix delimiters. BCS1204 specifies single `#` prefix, no decoration.
*Fix:* Change to `# Utility Functions`.

---

**[WARN] BCS1213 line 77:** 

```bash
>&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
```

Uses `printf '%(%T)T'` builtin — correct per BCS1213. **No violation.**

---

**[ERROR] BCS0503 line 362 / BCS1205:** Inside `wrap_text()`, the word-length accumulation:

```bash
current_len+=1
current_len+=$word_len
```

is done as two separate statements. While not wrong, the idiom `current_len+=$((1 + word_len))` or `((current_len += 1 + word_len))` would be more idiomatic. This is a minor style note, not a violation.

---

**[ERROR] BCS0410 line 746:** `_parse_table_structure()` contains a `for` loop at line 746 with loop variable `line`. Looking at line 741: `local -- line cell` is declared before the loop. However `row_str` at line 744 is declared `local -- row_str` before the loop. These are correct.

But at line 759: `for ((i=0; i<${#cells[@]}; i+=1))` — `i` is declared `local -i row_num=0 max_cols=0 i` at line 743. **No violation.**

The function is NOT recursive, so BCS0410 does not apply.

---

**[WARN] BCS0503 line 1268:** `parse_arguments()` uses `while (($#)); do case $1 in` — correct BCS0801 pattern. The mandatory `shift` at the end (line 1334) is present. **No violation.**

---

**[WARN] BCS0602 line 167–169:** `noarg()` uses `die 8` for missing argument. BCS0602 lists code 8 as "Required argument missing" — this is correct. **No violation.**

But the implementation differs from BCS1211:

```bash
# BCS reference
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Script implementation
noarg() {
  if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then
    die 8 "Missing argument for option ${1@Q}"
  fi
  return 0
}
```

The script's `noarg` additionally checks that the next argument doesn't start with `-`. This is a valid enhancement. Exit code is 8 vs 22 in the reference. Both are defensible; this is a design choice, not a violation. **No violation.**

---

**[WARN] BCS0705 line 1401:** 

```bash
debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"
```

The `debug` function is a messaging function, and this line uses it for status output. **No violation** — debug messages are status, not data.

---

**[WARN] BCS0903 line 1069–1073:** The table detection logic:

```bash
if [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables])); then
  render_table _lines i
  continue
elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```

The `elif` re-evaluates the same regex. Minor inefficiency; could use a flag variable. Not a BCS violation.

---

**[ERROR] BCS0606 line 1073:** `((OPTIONS[tables] == 0))` — should be `((!OPTIONS[tables]))` per BCS0501/BCS0208 arithmetic truthiness convention. This is the same issue as line 561.
*Fix:* Change to `((!OPTIONS[tables]))`.

---

**[WARN] BCS1201 line 4–5:** `set -euo pipefail` followed by `shopt -s inherit_errexit shift_verbose extglob nullglob` — this is correct and matches BCS0101. `nullglob` is noted as appropriate for strict scripts where unmatched globs should expand to nothing. **No violation.**

---

**[WARN] BCS0105 / BCS0204 lines 1396–1398:**

```bash
readonly TERM_WIDTH
readonly -A OPTIONS
readonly -a INPUT_FILES
```

These are made readonly after parsing, which follows the BCS0205 three-step workflow correctly. **No violation.**

---

**[WARN] BCS0410:** `parse_markdown()` at line 1001 contains a `while` loop that is NOT recursive and calls non-recursive render functions. `render_table` does call `_parse_table_structure`, `_calculate_column_widths`, and `_render_table_output`, none of which call back into `render_table`. No recursive functions are present. BCS0410 does not apply.

---

**[WARN] BCS0106 line 1429:** The script ends with `main "$@"` at line 1429 and `#fin` at line 1430. **No violation.**

---

**[WARN] BCS0110:** The `cleanup()` function is defined at line 151 and the trap installed at line 159, both before any resource creation. **No violation.**

---

**[WARN] BCS1002 line 7:** `declare -rx PATH=/usr/local/bin:/usr/bin:/bin` — correct and early. Does not include `.` or writable dirs. **No violation.**

---

**[WARN] BCS0408 line 252:** `sed` is a POSIX/coreutils command — no dependency check needed. **No violation.**

---

**[WARN] BCS0902:** No glob expansions without `./` prefix found in critical paths. The `for file in "${INPUT_FILES[@]}"` iterates an array. **No violation.**

---

**[WARN] BCS0905 line 1352, 1365:** 

```bash
while IFS= read -r line || [[ -n $line ]]; do
```

This is the correct pattern for reading files that may lack a trailing newline. **No violation.**

---

**[WARN] BCS1207 line 8:**

```bash
declare -rx PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
```

Correct debug trace format per BCS1207. **No violation.**

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0102 | style | WARN | 1 | `#!/usr/bin/env bash` is least-preferred shebang form; prefer `#!/usr/bin/bash` |
| BCS0105 | style | WARN | 41 | `DEBUG` global declared mid-script after function-section comment, not in the global declarations block |
| BCS0105 | style | WARN | 182 | `HAS_COLOR` global declared mid-script (inside a conditional), not in the global declarations block |
| BCS0501 | core | ERROR | 561 | `((OPTIONS[syntax_highlight] == 0))` — use arithmetic truthiness `((!OPTIONS[syntax_highlight]))` instead of explicit `== 0` comparison |
| BCS0501 | core | ERROR | 1073 | `((OPTIONS[tables] == 0))` — same issue; use `((!OPTIONS[tables]))` |
| BCS0602 | recommended | WARN | 134 | Exit code `4` (directory check) is not in the BCS standard exit code table; use `22` (invalid argument) |
| BCS0602 | recommended | WARN | 140, 1370 | Exit code `9` (file too large) is not in the BCS standard exit code table; use `5` (I/O error) or `22` (invalid argument) |
| BCS1202 | style | WARN | 133 | Comment "Check if it's a directory" paraphrases `[[ ! -d $filepath ]]` |
| BCS1202 | style | WARN | 136 | Comment "Get file size in bytes" paraphrases `stat -c '%s'` call |
| BCS1202 | style | WARN | 183 | Comment "Check if we have a terminal" paraphrases the `[[ -t 1 && -t 2 ]]` condition |
| BCS1202 | style | WARN | 350 | Comment "Build wrapped lines" paraphrases the initialization below it |
| BCS1202 | style | WARN | 372 | Comment "Print last line" paraphrases the `echo` statement |
| BCS1202 | style | WARN | 566 | Comment "Normalize language name" paraphrases the `case` block |
| BCS1202 | style | WARN | 573 | Comment "Apply simple syntax highlighting based on language" paraphrases the dispatch `case` |
| BCS1202 | style | WARN | 1006 | Comment "Reset parsing state" paraphrases the reset assignments |
| BCS1202 | style | WARN | 1390 | Comment "Parse command-line arguments" paraphrases `parse_arguments "$@"` |
| BCS1202 | style | WARN | 1393 | Comment "Determine terminal width" paraphrases the width-detection line |
| BCS1204 | style | WARN | ~30 occurrences | 80-dash `# ---` separators used ~30 times throughout; BCS1204 limits these to 2–3 per file for major divisions only |
| BCS1204 | style | WARN | 39 | `## Utility Functions ##` uses double `##` and suffix decoration; BCS1204 requires single `#` prefix only |
| BCS0706 | recommended | WARN | 194 | ANSI color block uses `if ((HAS_COLOR))` instead of `if [[ -t 1 && -t 2 ]]` per BCS0706 reference pattern (intentional design choice but deviates from standard) |
| BCS0201 | style | WARN | 186 | `declare -i color_count` inside a top-level `if` block leaks into global scope as a dead variable after the block; unset it or restructure into a function |
bcs: ◉ Tokens: in=45579 out=6833
bcs: ◉ Elapsed: 128s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
