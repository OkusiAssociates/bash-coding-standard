bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS...
bcs: ◉ bcs check --backend 'claude' --model 'balanced' --effort 'high' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
`★ Insight ─────────────────────────────────────`
BCS0501 distinguishes between *boolean flags* (`((OPTIONS[x] == 0))` → wrong) and *specific index comparisons* (`((row_num == 1))` → correct). Only flag comparisons against 0/1 that test truthy/falsy state qualify as BCS0501 warnings.
`─────────────────────────────────────────────────`

---

## BCS Compliance Report — `md2ansi`

### Inline suppressions applied (respected, not reported):
| Line | Suppression | Reason |
|------|-------------|--------|
| 12 | `#bcscheck disable=BCS0103` | `SCRIPT_NAME` derived from `$0` instead of `realpath` |
| 72 | `#bcscheck disable=BCS0703` | Custom timestamp `debug()` instead of `_msg` dispatch |
| 1259 | `#bcscheck disable=BCS0804` | `parse_arguments()` factored out of `main()` |

---

### Findings

---

#### BCS0107 — WARNING — Function Organization
**Lines:** 1203–1256 (`usage()`)

**What is wrong:** BCS0107 mandates a 7-layer bottom-up ordering. Layer 2 (documentation/help functions) must appear **before** Layer 3 (helper/utility functions). `usage()` is defined at line 1203, far below helpers (`get_terminal_width`, `strip_ansi`, `colorize_line`, etc.) and all rendering functions.

**How to fix:** Move `usage()` to immediately after the messaging functions block (after `debug()`, around line 82), before `get_terminal_width`.

---

#### BCS0405 — WARNING — Unnecessary Thin Wrapper
**Lines:** 262–265 (`sanitize_ansi()`), called only at line 554

**What is wrong:** `sanitize_ansi()` is a one-line wrapper with no added logic:
```bash
sanitize_ansi() {
  local -- text=$1
  strip_ansi "$text"
}
```
It is called exactly once (`code=$(sanitize_ansi "$code")`). BCS0405 requires removing unnecessary abstractions — this function adds no value over a direct `strip_ansi` call.

**How to fix:** Remove `sanitize_ansi()` and replace the single call site with:
```bash
code=$(strip_ansi "$code")
```

---

#### BCS0501 — WARNING — Explicit Zero Comparison on Boolean Flags
**Lines:** 557, 1066

**What is wrong:** BCS0501 requires using arithmetic truthiness (`((!var))`) rather than explicit `== 0` comparisons for boolean flags:

```bash
# Line 557 — WRONG
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then

# Line 1066 — WRONG
elif [[ $line =~ ^[[:space:]]*\| ]] && ((OPTIONS[tables] == 0)); then
```

**How to fix:**
```bash
# Line 557
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then

# Line 1066
elif [[ $line =~ ^[[:space:]]*\| ]] && ((!OPTIONS[tables])); then
```

> Note: `((row_num == 1))`, `((row_num == 0 ...))`, and `((${#lines[@]} == 0))` are **not** flagged — they compare against specific index/count values, not boolean flags.

---

#### BCS0706 — WARNING — Scattered Color Declarations
**Lines:** 44–48 (first block), 191–238 (main block)

**What is wrong:** BCS0706 says "Never scatter inline color declarations across scripts." The script declares `NC`, `RED`, `YELLOW` in a separate block at lines 44–48 (needed early by messaging functions), then the main ANSI color set at lines 191–238 under a different conditional (`((HAS_COLOR))`). This results in two separate, disjoint color declaration blocks.

```bash
# Block 1 — lines 44-48 (messaging colors, [[ -t 1 && -t 2 ]])
declare -r NC RED YELLOW

# Block 2 — lines 191-238 (rendering colors, ((HAS_COLOR)))
declare -r ANSI_RESET ANSI_BOLD ... COLOR_H1 ... COLOR_KEYWORD ...
```

**How to fix:** Consolidate into a single conditional block, either merging the messaging colors into the `((HAS_COLOR))` block (preferred) or making messaging functions reference variables already defined in the main block. The `HAS_COLOR` detection can occur before the single consolidated block.

---

#### BCS1204 — WARNING — Excessive Section Separator Comments
**Lines:** 50, 82, 120, 147, 159, 189, 240, 271, 321, 372, 398, 506, 530, 543, 653, 721, 793, 836, 917, 959, 961 (and more)

**What is wrong:** BCS1204 states "Reserve 80-dash separators for major script divisions only" and prefers lightweight 2–4 word section labels. The script uses `# ----...` (80-char) dividers liberally within function bodies and between sub-functions — 31 separator lines total. The `# ====...` major division markers are correct; the `# ----...` sub-dividers within code blocks are excessive.

**How to fix:** Replace inline `# ----` separators within function bodies with lightweight comments (`# Header formatting`, `# Step 1: collect rows`, etc.). Retain `# ====` lines for top-level sections only.

---

### Summary Table

| BCS Code | Severity | Lines | Description |
|----------|----------|-------|-------------|
| BCS0107 | WARNING | 1203–1256 | `usage()` placed after helper/rendering functions; should be layer 2 |
| BCS0405 | WARNING | 262–265, 554 | `sanitize_ansi()` is a redundant one-liner wrapper called once |
| BCS0501 | WARNING | 557, 1066 | `((OPTIONS[x] == 0))` should be `((!OPTIONS[x]))` for boolean flags |
| BCS0706 | WARNING | 44–48, 191–238 | Color declarations split across two separate conditional blocks |
| BCS1204 | WARNING | 31 occurrences | 80-char `# ----` dividers overused in function bodies and sub-sections |

**Violations: 0 — Warnings: 5**

The script is structurally sound and well-written. No mandatory rule violations were found. The five warnings are style/organization issues — the most impactful fix would be consolidating the color declarations (BCS0706) to eliminate the architectural split.
bcs: ◉ Tokens: 
bcs: ◉ Elapsed: 524s
