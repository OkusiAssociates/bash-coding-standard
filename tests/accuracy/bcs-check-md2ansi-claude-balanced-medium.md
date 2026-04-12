bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS...
bcs: ◉ bcs check --backend 'claude' --model 'balanced' --effort 'medium' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
`★ Insight ─────────────────────────────────────`
The suppression mechanism (`#bcscheck disable=BCSxxxx`) applies to the **next line only** — so `#bcscheck disable=BCS0103` on L12 exempts L13 (`SCRIPT_NAME=${0##*/}`), but doesn't exempt any missing metadata variables. The BCS also notes "not all scripts require all metadata variables", so the absence of `SCRIPT_PATH`/`SCRIPT_DIR` is acceptable here.
`─────────────────────────────────────────────────`

---

## BCS Compliance Report — `md2ansi`

---

### VIOLATION: BCS0107 — Function Organization (Bottom-Up)

**Severity:** VIOLATION
**Rule:** Functions must be defined bottom-up; each function may only call previously-defined functions.

**Instance 1 — `render_code_line()` calls helpers defined after it**

| Caller | Defined at | Called function | Defined at |
|--------|-----------|-----------------|-----------|
| `render_code_line()` | L548 | `highlight_python()` | L590 |
| `render_code_line()` | L548 | `highlight_javascript()` | L615 |
| `render_code_line()` | L548 | `highlight_bash()` | L633 |

The three language highlighters are defined *after* `render_code_line()`, which calls them at L574–577. They must be moved above `render_code_line()`.

**Instance 2 — `render_table()` calls internal helpers defined after it**

| Caller | Defined at | Called function | Defined at |
|--------|-----------|-----------------|-----------|
| `render_table()` | L659 | `_parse_table_structure()` | L726 |
| `render_table()` | L659 | `_calculate_column_widths()` | L798 |
| `render_table()` | L659 | `_render_table_output()` | L841 |
| `_render_table_output()` | L841 | `_align_cell()` | L922 |

**Fix:** Reorder the table section to: `_align_cell` → `_render_table_output` → `_calculate_column_widths` → `_parse_table_structure` → `render_table`.

**Instance 3 — `usage()` placement**

`usage()` is a layer-2 documentation function (per BCS0107 classification), but it is defined at L1202 — after rendering functions (layer 5) and business logic. It should appear after the messaging functions and before the utility/helper functions.

---

### VIOLATION: BCS0207 — Unnecessary Braces in Variable Expansions

**Severity:** WARNING (style; pervasive throughout `colorize_line()` and highlight functions)
**Rule:** Use braces only when syntactically required.

The following lines use `${VAR}` where `$VAR` is sufficient because the adjacent character (`\1`, `▲`, `[`, etc.) is not a valid variable-name character:

| Line | Pattern | Problem |
|------|---------|---------|
| 57 | `prefix+=" ${YELLOW}▲${NC}"` | `▲` and `"` are not var chars; `$YELLOW▲$NC` works |
| 58 | `prefix+=" ${RED}✗${NC}"` | same |
| 282 | `.../${COLOR_CODEBLOCK}\1${ANSI_RESET}${COLOR_TEXT}/g` | `\1` not a var char; `$COLOR_CODEBLOCK` would be unambiguous |
| 286 | `.../${ANSI_BOLD}[IMG: \1]${ANSI_RESET}${COLOR_TEXT}/g` | `[` not a var char |
| 291, 295, 298, 299, 302, 306, 311, 315 | same pattern in `colorize_line()` | same |
| 485, 487 | `"${COLOR_LIST}[..."` | `[` not a var char |
| 595, 601 | `"${COLOR_COMMENT}${code}..."` | adjacent variables — `${COLOR_COMMENT}${code}` — **this form IS required** ✓ |
| 608, 626, 644 | `.../${COLOR_KEYWORD}\\1${COLOR_CODEBLOCK}/g` | `\\1` not a var char |
| 1069, 1185 | `"${COLOR_TEXT}${formatted_line}"` | adjacent variables — **required** ✓ |

**Note:** `${VAR1}${VAR2}` (adjacent variables like `${ANSI_BOLD}${ANSI_ITALIC}` at L295) are *required* per BCS0207 and are correct. The violations are only where the following character cannot be part of a variable name.

**Fix example** (L282):
```bash
# wrong
result=$(sed -E "s/\`([^\`]+)\`/${COLOR_CODEBLOCK}\1${ANSI_RESET}${COLOR_TEXT}/g" <<<"$result")
# correct
result=$(sed -E "s/\`([^\`]+)\`/$COLOR_CODEBLOCK\1${ANSI_RESET}${COLOR_TEXT}/g" <<<"$result")
# (${ANSI_RESET}${COLOR_TEXT} is still required — adjacent vars)
```

---

### WARNING: BCS0105 — Color Detection Extends Beyond Standard TTY Check

**Severity:** WARNING
**Lines:** 182–186
**Rule:** "Always check BOTH stdout AND stderr: `[[ -t 1 && -t 2 ]]`"

```bash
# current — extends with OR branch
if [[ -t 1 && -t 2 ]] || [[ -n ${TERM:-} && $TERM != dumb ]]; then
```

The `|| [[ -n ${TERM:-} && $TERM != dumb ]]` arm enables ANSI color even when stdout is piped (not a TTY), based on `$TERM`. This causes color codes to appear in piped output when the terminal is `xterm-256color` etc. — which is arguably the desired behaviour for a markdown-to-ANSI tool, but deviates from BCS0105.

**Fix (to comply):**
```bash
if [[ -t 1 && -t 2 ]]; then
```
Or, if the extended detection is intentional, add a `#bcscheck disable=BCS0105` suppression.

---

### WARNING: BCS0110 — Trap Installed Inside `main()` Rather Than at Script Level

**Severity:** WARNING
**Lines:** 151–157 (cleanup defined), 1384 (trap installed)
**Rule:** "Set the trap *before any code* that creates temporary resources."

The `cleanup()` function is defined at the global level (L151) but the trap is installed at L1384 inside `main()`. Between script start and `main()` being called, the script runs about 200 lines of color-setup code and function definitions with no resources to protect. This is therefore low-risk here but is non-standard. The BCS pattern is to install the trap at the global scope immediately after defining `cleanup()`.

**Fix:**
Move `trap 'cleanup $?' SIGINT SIGTERM EXIT` to just after the `cleanup()` function definition (after L157), and remove it from `main()` (L1384).

---

### SUPPRESSED (correctly exempted)

| Line | Suppression | What is exempted |
|------|------------|-----------------|
| 12 | `#bcscheck disable=BCS0103` | L13: `SCRIPT_NAME=${0##*/}` (uses parameter expansion instead of `realpath`) |
| 72 | `#bcscheck disable=BCS0703` | L73–80: `debug()` function uses non-standard `DEBUG+=1` counter increment |
| 1259 | `#bcscheck disable=BCS0804` | L1260: `parse_arguments()` defined as standalone function outside `main()` |

---

### PASSING (notable checks)

| BCS Code | Check | Result |
|----------|-------|--------|
| BCS0101 | `set -euo pipefail` + `shopt -s inherit_errexit` first | ✓ L4–5 |
| BCS0102 | Shebang `#!/usr/bin/env bash` | ✓ L1 |
| BCS0109 | `#fin` end marker | ✓ L1426 |
| BCS0201 | Explicit types on all globals (`declare -i`, `-A`, `-a`, `-r`) | ✓ |
| BCS0202 | All function variables declared `local` | ✓ |
| BCS0203 | UPPER_CASE globals, lower_snake functions, `_` prefix for private | ✓ |
| BCS0305 | `printf` format strings in single quotes | ✓ |
| BCS0503 | Loops use `i+=1` (no `i++`) | ✓ |
| BCS0601 | No `set +e` disabling | ✓ |
| BCS0602 | Standard `die()` with correct exit codes | ✓ |
| BCS0606 | Arithmetic guards use inverted `||` form (`((w >= 20)) \|\| w=20`) | ✓ |
| BCS0702 | `>&2` at the *beginning* of stderr lines | ✓ L66–67, 77 |
| BCS0711 | No `>/dev/null 2>&1` (uses `&>/dev/null` or `2>/dev/null`) | ✓ |
| BCS0801 | Argument parsing uses `while (($#)); do case $1 in` | ✓ |
| BCS1002 | PATH locked: `declare -rx PATH=/usr/local/bin:/usr/bin:/bin` | ✓ L7 |

---

### Summary Table

| Code | Severity | Lines | Description |
|------|----------|-------|-------------|
| **BCS0107** | **VIOLATION** | 548→590/615/633; 659→726/798/841; 841→922; 1202 | Functions call helpers defined after them; `usage()` misplaced |
| **BCS0207** | WARNING | 57–58, 282–315 (×8), 485, 487, 608, 626, 644 | Unnecessary `${VAR}` braces where `$VAR` is unambiguous |
| **BCS0105** | WARNING | 182–186 | Color detection uses OR-extended TTY check beyond BCS standard |
| **BCS0110** | WARNING | 1384 | Trap installed inside `main()` rather than at script-global level |
bcs: ◉ Tokens: 
bcs: ◉ Elapsed: 286s
