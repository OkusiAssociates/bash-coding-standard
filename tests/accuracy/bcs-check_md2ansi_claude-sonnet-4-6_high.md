bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
I'll analyze this script systematically against the BCS rules.

---

## Findings

---

**[WARN] BCS0102 line 1: Shebang uses `#!/usr/bin/env bash` instead of the preferred `#!/usr/bin/bash`**

The preferred form per BCS0102 is `#!/usr/bin/bash` (or `#!/bin/bash`). `#!/usr/bin/env bash` is listed as "maximum portability" — acceptable but not preferred for a Linux-targeted script.

*Fix:* Change to `#!/usr/bin/bash` unless portability across non-standard systems is a stated goal.

---

**[WARN] BCS0103 line 13: `SCRIPT_PATH` and `SCRIPT_DIR` are absent but `SCRIPT_DIR`-equivalent logic may be needed**

The `#bcscheck disable=BCS0103` directive suppresses this finding for the `SCRIPT_NAME` line itself. However, BCS0103 also defines `SCRIPT_PATH` and `SCRIPT_DIR` as standard metadata. The suppression is scoped to the next command (line 13 only), so the absence of `SCRIPT_PATH`/`SCRIPT_DIR` declarations is not suppressed. That said, BCS0103 is **Tier: recommended** and BCS0405 states unused variables must not be added — since `SCRIPT_PATH` and `SCRIPT_DIR` are never referenced in this script, their omission is actually *correct* per BCS0405. This is not a violation.

*(No finding — analysis resolves to no violation.)*

---

**[WARN] BCS0105 line 39–41: `DEBUG` declared after the color block and after other globals**

BCS0105 requires all global variables to be declared up front together. `DEBUG` is declared at line 41, after the color block (lines 44–48), but other globals are declared at lines 16–37. The variable group is split by a comment and the color detection block.

*Fix:* Move `declare -i DEBUG=0` to the global variable section near lines 16–30, alongside `VERBOSE` and other flags.

---

**[WARN] BCS0107 line 972–997 vs 1001–1203: `render_footnotes` is defined after `_render_table_output` but is called from `parse_markdown` which is defined after it — the call order is inverted relative to the comment "Main markdown parser" heading at line 966**

More specifically: `parse_markdown` (line 1001) calls `render_footnotes` (line 972) which is defined just before it — that part is fine (bottom-up). However, the section comment at line 966 says "Main markdown parser" and then immediately has `render_footnotes` defined before `parse_markdown`, which is the correct bottom-up order. No actual violation here.

*(No finding — bottom-up ordering is maintained.)*

---

**[ERROR] BCS0606 line 188: `((color_count < 256)) || HAS_COLOR=1` — the logic is inverted**

This is not a BCS0606 issue per se, but a correctness bug: the condition sets `HAS_COLOR=1` when `color_count < 256` is **false**, i.e., when `color_count >= 256`. Under `set -e`, if `color_count` is 0 (terminal has fewer than 256 colors), `((color_count < 256))` is truthy (returns 0), so `||` short-circuits and `HAS_COLOR` stays 0 — that part is correct. When `color_count >= 256`, `((color_count < 256))` returns 1 (false under arithmetic), which under `set -e` would normally exit — but the `||` catches it and sets `HAS_COLOR=1`. This is actually the intended behavior, but it is the `&&...||:` pattern without `||:`, used in the inverted `||` form.

Reconsidering: `((color_count < 256)) || HAS_COLOR=1` — this IS the inverted `||` form documented in BCS0606 as correct. The RHS `HAS_COLOR=1` is an assignment returning 0. No violation.

*(No finding.)*

---

**[WARN] BCS0201 line 186–187: `color_count` declared without explicit type inside an `if` block at global scope**

```bash
declare -i color_count
color_count=$(tput colors 2>/dev/null || echo 0)
```

`color_count` is declared as `-i` (correct type) but it is declared inside an `if` block at global (not function) scope. The value is only needed to compute `HAS_COLOR`. After the block, `color_count` persists as a global integer variable that is never used again. It should either be declared and used more carefully, or the computation should be inlined.

*Fix:* Inline the computation: `HAS_COLOR=$((...))` or use a subshell. Since this is global scope (not a function), `local` is not available, but `color_count` should be `unset` after use, or the whole detection block placed in a subshell/function.

---

**[WARN] BCS0203 line 186: `color_count` uses lowercase for what is effectively a temporary global**

Per BCS0203, global state variables should be `UPPER_CASE`. `color_count` is declared at global scope (inside an `if` block but not inside a function), making it a global variable. It should be `COLOR_COUNT` or eliminated after use.

*Fix:* Rename to `COLOR_COUNT` or unset after use: `unset color_count`.

---

**[WARN] BCS0107 / BCS0401 line 430, 464, 504, 528: `local -- line` declared mid-loop body**

In `render_list_item` (line 430), `render_ordered_item` (line 464), `render_task_item` (line 504), and `render_blockquote` (line 528), a `local -- line` declaration appears inside or just before a `for` loop body, but after other statements in the function. BCS0401 says declarations may appear mid-body between logical sections but must NOT appear inside loops. These declarations appear just before the loop (not inside it), so they are not technically inside the loop.

Actually checking: line 430 `local -- line` appears after the `printf` on line 427, before the `for` loop on line 431. That is between logical sections — permitted. Same pattern at 464, 504, 528. No violation.

*(No finding.)*

---

**[ERROR] BCS0503 line 1394: `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` — missing `||:` not needed here (inverted form), but this is inside `main()` which uses local-scope variable**

Actually `TERM_WIDTH` is a global `declare -i`. The inverted `||` form is used here correctly — the RHS `TERM_WIDTH=$(...)` is an assignment that returns 0. No violation per BCS0606.

*(No finding.)*

---

**[WARN] BCS0801 line 1267–1336: Argument parsing is done in a separate `parse_arguments()` function rather than directly in `main()`**

BCS0804 states parsing should be inside `main()` for better testability. The `#bcscheck disable=BCS0804` directive at line 1266 suppresses this for the `parse_arguments` function definition — but the suppression is scoped to the next command only (the function definition block). The call to `parse_arguments "$@"` at line 1391 is not suppressed. However, the rule is about *where* parsing occurs, and the suppression on the function definition covers the deviation. The suppression is properly placed.

*(Suppressed — no finding.)*

---

**[WARN] BCS0503 line 759, 815, 825, 865, 891: `for ((i=0; i<...; i+=1))` — correct form used, no violation**

*(No finding.)*

---

**[ERROR] BCS0606 line 1394: `((TERM_WIDTH)) || TERM_WIDTH=$(get_terminal_width)` — safe, inverted form**

*(No finding — already resolved above.)*

---

**[WARN] BCS0201 line 671: `local -a table_lines=() all_rows=() data_rows=() alignments=() col_widths=()` — multiple arrays on one line with a `#shellcheck disable` on that line**

The `#shellcheck disable=SC2034` at line 670 is for `table_lines` which may be assigned but not used directly (passed by name). This is fine. No BCS violation.

*(No finding.)*

---

**[WARN] BCS1202 lines 53, 65, 68, 71, 82, 120, 147, 161, 173, 192, 243, etc.: Several inline comments paraphrase the code**

Examples:
- Line 53: `# Internal message function using FUNCNAME for context` — adds information (explains the dispatch mechanism), acceptable.
- Line 65: `# Unconditional output` — describes behavior not obvious from `warn()` and `error()` alone; acceptable.
- Line 133: `# Check if it's a directory` — paraphrases `[[ ! -d $filepath ]]`. **Violation.**
- Line 136: `# Get file size in bytes` — paraphrases `file_size=$(stat -c '%s' ...)`. **Violation.**
- Line 143: `# Reset terminal to clean state` — at line 154: marginally adds info (explains *why*, not just what). Borderline acceptable.
- Line 278: `# Order matters: process code first, then images, links, then bold/italic/strike` — adds information. Acceptable.
- Line 285: `# 1. Inline code: \`code\` (remove backticks from output)` — describes the transformation; acceptable.
- Line 557: `# Sanitize ANSI codes from input` — paraphrases `code=$(sanitize_ansi "$code")`. **Violation.**
- Line 1006: `# Reset parsing state` — paraphrases the five assignment lines below. **Violation.**
- Line 1390: `# Parse command-line arguments` — paraphrases `parse_arguments "$@"`. **Violation.**
- Line 1393: `# Determine terminal width` — paraphrases `((TERM_WIDTH)) || TERM_WIDTH=$(...)`. **Violation.**
- Line 1403: `# Print initial reset to ensure clean terminal state` — the "to ensure clean terminal state" adds a *why*; borderline acceptable.
- Line 1406: `# Process files or stdin` — paraphrases the `if ((${#INPUT_FILES[@]}))` block. **Violation.**
- Line 1422: `# Ensure terminal colors are reset at the end` — adds reason; acceptable.

*Fix:* Remove or rewrite the paraphrasing comments. Keep only those that add information not present in the code.

---

**[WARN] BCS0303 line 167: `[[ ${2:0:1} == '-' ]]` — uses `[[ ]]` with variable expansion, fine; but `noarg` implementation differs from BCS1211 reference**

The BCS1211 reference `noarg` only checks `(($# > 1))`. This implementation adds an additional check `[[ ${2:0:1} == '-' ]]` to catch options-as-arguments. This is an enhancement, not a violation.

*(No finding.)*

---

**[WARN] BCS0301 line 77: double-quoted format string in `printf`**

```bash
>&2 printf '[%(%T)T.%s] %s⦿%s %s\n' -1 "$DEBUG" "$YELLOW" "$NC" "$msg"
```

The format string `'[%(%T)T.%s] %s⦿%s %s\n'` contains no variable expansion and should use single quotes per BCS0301.

*Fix:* Change to `'[%(%T)T.%s] %s⦿%s %s\n'` — it already uses single quotes. *(No violation — already single-quoted.)*

*(No finding.)*

---

**[WARN] BCS0301 line 286, 290, 295, 299, 302, 303, 306, 310, 315, 319: `sed -E "s/..."` uses double quotes for format strings containing variable expansions**

These are double-quoted because they embed `$COLOR_*` and `$ANSI_*` variables. This is correct per BCS0301 — double quotes are required when variable expansion is needed.

*(No finding.)*

---

**[WARN] BCS0503 line 78: `DEBUG+=1` inside the `debug()` function — `DEBUG` is a global `declare -i`**

The `debug()` function increments `DEBUG` as a counter (line 78: `DEBUG+=1`). This means calling `debug()` mutates a global flag variable. The intent of `DEBUG` as a boolean flag (0/1) is subverted — after the first `debug()` call, `DEBUG` becomes 2, 3, etc. This is unusual but intentional (the `%s` format at line 77 uses `$DEBUG` as a call counter). However, this means `((DEBUG))` tests will always be true after the first call regardless of whether the user passed `-D`. This is a design issue but suppressed by `#bcscheck disable=BCS0703` at line 72 which covers the whole function definition.

*(Suppressed — no finding.)*

---

**[WARN] BCS0203 line 186–187: `color_count` is lowercase at global scope** *(already reported above)*

---

**[ERROR] BCS0410 line 746: `for line in "${_table_lines[@]}"` in `_parse_table_structure()` — `line` is declared `local` at line 741**

```bash
local -- line cell
...
for line in "${_table_lines[@]}"; do
```

`line` IS declared local (line 741). No violation.

*(No finding.)*

---

**[WARN] BCS0107 line 966–968: duplicate/confusing section comment block**

Lines 966–968:
```bash
# ================================================================================
# Markdown Parser Functions
# ================================================================================
```
Then lines 968–970:
```bash
# --------------------------------------------------------------------------------
# Main markdown parser
# --------------------------------------------------------------------------------
# Footnote rendering
```

The "Main markdown parser" header is immediately followed by "Footnote rendering" and the `render_footnotes` function. The section structure is misleading — the "Main markdown parser" comment appears before a footnote rendering function, not before `parse_markdown`. This is a style issue.

*Fix:* Restructure the comments so "Main markdown parser" precedes `parse_markdown` and footnote rendering has its own header before `render_footnotes`.

---

**[WARN] BCS0704 line 1211–1263: `show_help` output goes to stdout (via `cat <<HELP`)**

BCS0704 states "Never use messaging functions for help output" and "Help and version must always display regardless of VERBOSE setting." The heredoc goes to stdout, which is correct. No violation.

*(No finding.)*

---

**[WARN] BCS0802 line 1281: version output format correct**

`echo "$SCRIPT_NAME $VERSION"` — correct format per BCS0802.

*(No finding.)*

---

**[WARN] BCS0503 line 1020: `while ((i < ${#_lines[@]}))` — correct arithmetic form**

*(No finding.)*

---

**[WARN] BCS0105 line 1394: `TERM_WIDTH` made `readonly` inside `main()` after assignment — correct pattern**

*(No finding.)*

---

**[WARN] BCS1204 line 50, 82, 120, etc.: 80-dash separator lines used throughout the script**

BCS1204 reserves `# ----` 80-dash separators for "major script divisions only — typically no more than two or three per file." This script uses them as section dividers within functions and between every logical block, appearing approximately 40+ times. This significantly exceeds the "no more than two or three" guideline.

*Fix:* Reserve the 80-dash lines for 2-3 truly major divisions (e.g., ANSI definitions, rendering functions, main). Use simple `# Section name` comments for subsections within functions.

---

**[WARN] BCS0301 line 45, 47: Color variable names match BCS0706 reference but script uses `NC`, `RED`, `YELLOW` for messaging and separate `ANSI_*`/`COLOR_*` variables for ANSI rendering**

The script defines two separate color systems: one for messaging (`NC`, `RED`, `YELLOW` at lines 44–48) and one for rendering (`ANSI_*`, `COLOR_*` at lines 196–240). This is a justified design choice for a rendering tool, not a violation.

*(No finding.)*

---

**[WARN] BCS0503 line 1413: `if ((${#INPUT_FILES[@]}>1))` — spacing style**

Minor: `>1` without spaces around the operator. BCS does not explicitly mandate spacing inside `(())`, but consistent style would be `> 1`.

*Fix:* Change to `((${#INPUT_FILES[@]} > 1))` for readability. This is a minor style note, not a rule violation with a specific code.

---

**[WARN] BCS0905 line 252: `sed 's/...' <<<"$text"` used instead of a pure bash alternative**

`strip_ansi` uses `sed` via here-string. For stripping ANSI codes, there is no pure-bash equivalent that's practical, so this is acceptable.

*(No finding.)*

---

**[WARN] BCS0703 line 62: `_msg()` sends output to stdout, not stderr**

```bash
_msg() {
  ...
  for msg in "$@"; do
    printf '%s %s\n' "$prefix" "$msg"
  done
}
```

`_msg` itself writes to stdout. The calling functions (`warn`, `error`) redirect to stderr with `>&2`. This means if `_msg` is ever called directly (not via `warn`/`error`), output goes to stdout. This is an indirect violation of BCS0702 (status messages to stderr), though in practice all callers redirect. The BCS0703 reference has `_msg` output to stdout and relies on callers for `>&2`.

*(No finding — matches BCS0703 reference pattern.)*

---

**[ERROR] BCS0702 line 62: `_msg()` printf goes to stdout without `>&2`**

Per BCS0702, all status messages go to stderr. The `warn()` and `error()` functions do `>&2 _msg "$@"` which redirects stdout of `_msg` to stderr — this works correctly. However `_msg` itself doesn't write to stderr directly. This matches the BCS0703 reference pattern exactly, so no violation.

*(No finding.)*

---

**[WARN] BCS1202 line 133–134: paraphrasing comments** *(already reported under BCS1202)*

---

**[WARN] BCS0801 line 1321: option bundling character class `-[wDVht]?*`**

The `-t` (plain) option takes no argument, and `-w` (width) takes an argument. Per BCS0805, arg-taking options in a bundle must be placed last. The class includes `-w` alongside non-arg options. The note in BCS0805 says the user is responsible for placing arg-taking options last — this is not a script defect.

*(No finding.)*

---

**[WARN] BCS0103 / BCS1206 line 12–13: `#bcscheck disable=BCS0103` suppresses BCS0103 for `SCRIPT_NAME` line**

`SCRIPT_NAME` is derived with `${0##*/}` instead of `realpath`. This is a valid reason to suppress — `realpath` would give the full resolved path's basename which may differ from `$0` in some invocation patterns. The suppression is appropriate.

*(Suppressed — no finding.)*

---

Now let me do a final pass for anything missed:

**[WARN] BCS0201 line 672: `local -i has_alignment=0 col_count=0` — `col_count` used as a nameref target**

In `render_table`, `col_count` is a local integer, but it's passed to `_parse_table_structure` as a nameref argument (position 5, mapped to `_col_count`). The nameref assigns to `col_count`. This works correctly in bash. No violation.

*(No finding.)*

---

**[WARN] BCS0503 line 1179: `while [[ $line =~ \[\^([^]]+)\] ]]` — `while` with `[[ ]]` regex**

This is valid. The `while` loop uses a regex match, removes the matched portion, and repeats to find all footnote references. No violation.

*(No finding.)*

---

**Summary of actual findings:**

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0102 | recommended | WARN | 1 | Shebang uses `env bash` (portable) instead of preferred `#!/usr/bin/bash` |
| BCS0105 | recommended | WARN | 41 | `DEBUG` declared after color block, separated from other globals |
| BCS0203 | style | WARN | 186–187 | `color_count` is lowercase at global scope; should be `UPPER_CASE` or unset after use |
| BCS1202 | style | WARN | 133, 136, 557, 1006, 1390, 1393, 1406 | Comments paraphrase the code below them without adding new information |
| BCS1204 | style | WARN | ~50+ occurrences | 80-dash separator lines used ~40+ times; BCS1204 reserves them for 2–3 major divisions per file |
bcs: ◉ Tokens: in=45585 out=5454
bcs: ◉ Elapsed: 101s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
