bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
`bcscheck` backend unavailable; proceeding with full manual BCS analysis against the standard.

`★ Insight ─────────────────────────────────────`
ShellCheck found **zero issues** — a strong signal the script is well-hardened at the syntactic/portability level. BCS compliance is a higher-level structural and style concern that ShellCheck cannot assess.
`─────────────────────────────────────────────────`

---

## BCS Compliance Audit — `md2ansi`

### Positive Findings (✓ Compliant)

| Area | Status |
|------|--------|
| BCS0101 – Strict mode (`set -euo pipefail` + `inherit_errexit`) | ✓ |
| BCS0102 – Shebang (`#!/usr/bin/env bash`) | ✓ |
| BCS0103 – Metadata (`SCRIPT_NAME`) | ✓ (suppressed) |
| BCS0105/0706 – Colors defined conditionally, both branches match | ✓ |
| BCS0108 – `main()` exists, `readonly` after parse, `main "$@"` | ✓ |
| BCS0109 – `#fin` end marker | ✓ |
| BCS0110 – `cleanup()` + trap before any resource creation | ✓ |
| BCS0201 – Typed declarations (`declare -i/-a/-A/--`) throughout | ✓ |
| BCS0202 – All function-local vars declared `local` | ✓ |
| BCS0206 – `readarray -t` + quoted `"${arr[@]}"` consistently | ✓ |
| BCS0208 – Integer booleans (`declare -i FLAG=0`), tested via `((FLAG))` | ✓ |
| BCS0302 – No backticks; `$()` only | ✓ |
| BCS0303 – `[[ ]]` throughout; no `[ ]` | ✓ |
| BCS0306 – `${var@Q}` in all user-facing error messages | ✓ |
| BCS0503 – `i+=1` in all C-style loops; no `i++` | ✓ |
| BCS0504 – `< <(cmd)` process substitution; no `cmd \| while` | ✓ |
| BCS0601 – `set -e` with expected-failure patterns (`\|\|:`, inverted form) | ✓ |
| BCS0602 – Standard exit codes (3, 4, 8, 9, 13, 22) | ✓ |
| BCS0603 – Trap uses single quotes; cleanup disables own trap | ✓ |
| BCS0606 – Inverted `\|\|` forms throughout; no bare `((bool)) &&` | ✓ |
| BCS0702 – `>&2` at beginning of redirect; stderr/stdout separation | ✓ |
| BCS0711 – `&>` combined redirections (no verbose `>/dev/null 2>&1`) | ✓ |
| BCS0801 – `while (($#)); do case $1 in` parsing pattern | ✓ |
| BCS0803 – `noarg "$@"` before shift for value-taking options | ✓ |
| BCS0805 – Short-option bundling via `set -- "${1:0:2}" "-${1:2}"` | ✓ |
| BCS1002 – PATH locked: `declare -rx PATH=/usr/local/bin:/usr/bin:/bin` | ✓ |

---

### Violations

#### Finding 1 — BCS0107 [WARN]: `render_code_line()` calls helpers defined after it

**Tier:** style | **Severity:** [WARN]  
**Lines:** 552–590 (caller) vs 594, 619, 639 (callees)

`render_code_line()` dispatches to `highlight_python()` (L594), `highlight_javascript()` (L619), and `highlight_bash()` (L639), but all three are defined **after** it. BCS0107 requires bottom-up organisation — every function must appear **before** functions that call it.

**Fix:** Move `highlight_python()`, `highlight_javascript()`, `highlight_bash()` to immediately before `render_code_line()`.

---

#### Finding 2 — BCS0107 [WARN]: `render_table()` calls table sub-functions defined after it

**Tier:** style | **Severity:** [WARN]  
**Lines:** 666–726 (caller) vs 733, 805, 848 (callees)

`render_table()` calls:
- `_parse_table_structure()` — defined at L733  
- `_calculate_column_widths()` — defined at L805  
- `_render_table_output()` — defined at L848

All three callees are below their caller, violating bottom-up ordering.

**Fix:** Reorder so the sequence is: `_parse_table_structure` → `_calculate_column_widths` → `_align_cell` → `_render_table_output` → `render_table`.

---

#### Finding 3 — BCS0107 [WARN]: `_render_table_output()` calls `_align_cell()` defined after it

**Tier:** style | **Severity:** [WARN]  
**Lines:** 903 (call site inside L848 function) vs 929 (callee)

`_render_table_output()` calls `_align_cell()` at L903, but `_align_cell()` is defined at L929.

**Fix:** Move `_align_cell()` before `_render_table_output()` (resolved by the reorder in Finding 2).

---

#### Finding 4 — BCS0107 [WARN]: `show_help()` placed after business logic

**Tier:** style | **Severity:** [WARN]  
**Line:** 1210

BCS0107 mandates layer 2 (documentation functions) precedes layer 3 (helpers) and higher. `show_help()` is a documentation function but appears at L1210 — after ~1100 lines of rendering, parsing, and table logic.

**Fix:** Move `show_help()` to immediately after the messaging functions (`debug()` ends at L80), before `get_terminal_width()`.

---

#### Finding 5 — ShellCheck suppression without explanatory comment (×5)

**Tier:** style | **Severity:** [WARN]  
**Lines:** 239, 251, 671, 850, 851

The BCS standard shows `#shellcheck disable=SC…` directives alongside explanations. These five directives have no prose rationale:

| Line | Directive | What it suppresses | Why a comment is needed |
|------|-----------|--------------------|-------------------------|
| 239 | `SC2034` | `COLOR_KEYWORD` etc. flagged as unused | ShellCheck can't see the variable is referenced only in the initialiser block |
| 251 | `SC2001` | "Use `${var//…}` instead of `sed`" | Bash built-in can't match `\x1b` hex escapes; `sed` is intentional |
| 671 | `SC2034` | `table_lines` etc. flagged as unused | Variables are passed to namerefs in child functions, invisible to ShellCheck |
| 850 | `SC2178` | Nameref-to-array alias confusion | `local -n` for arrays triggers a ShellCheck false positive |
| 851 | `SC2178` | Same as above | Same reason |

**Fix example:**

```bash
# SC2034: vars passed as namerefs to _parse_table_structure; ShellCheck
# cannot track nameref-based usage across function calls
#shellcheck disable=SC2034
local -a table_lines=() all_rows=() data_rows=() alignments=() col_widths=()
```

---

### Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0107 | style | [WARN] | 552–590 vs 594–653 | `render_code_line()` calls `highlight_*()` functions defined after it |
| BCS0107 | style | [WARN] | 666–726 vs 733–848 | `render_table()` calls three table helpers defined after it |
| BCS0107 | style | [WARN] | 848–921 vs 929–960 | `_render_table_output()` calls `_align_cell()` defined after it |
| BCS0107 | style | [WARN] | 1210 | `show_help()` (doc layer 2) placed after all business logic |
| *(ShellCheck)* | style | [WARN] | 239, 251, 671, 850, 851 | `#shellcheck disable` directives have no explanatory comments |

---

### Executive Summary

**Overall Health Score: 9.2/10**

`★ Insight ─────────────────────────────────────`
All five findings are **[WARN] style-tier only** — zero core-tier [ERROR] violations. The script demonstrates exemplary BCS practice: strict mode, typed declarations, process substitution over pipe-to-while, locked PATH, `@Q` quoting in all error paths, and proper `||:` discipline throughout. The only structural weakness is that the table and code-highlighting sub-functions are grouped *below* the orchestrators that call them, inverting BCS0107's bottom-up rule. These are purely cosmetic reorganisations with no runtime impact.
`─────────────────────────────────────────────────`

- **No [ERROR] violations** found across all 12 BCS sections
- **4× [WARN] BCS0107** — function ordering only; move highlight and table helpers above their callers, and hoist `show_help()` to layer 2
- **5× [WARN] undocumented ShellCheck disables** — add one-line rationale comments
- **ShellCheck:** clean (zero findings)
- **BCS compliance:** ~97% — fully compliant on all structural, safety, and style rules except function ordering
bcs: ◉ Elapsed: 436s
bcs: ◉ Exit: 1
