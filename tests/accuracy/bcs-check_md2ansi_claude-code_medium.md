bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
`★ Insight ─────────────────────────────────────`
The `((!FLAG))` vs `((FLAG == 0))` distinction is subtle but idiomatic: arithmetic `(())` treats any non-zero value as true, so `((!OPTIONS[tables]))` directly reads as "if tables is false" without the detour through an explicit equality test. It also aligns with how the same flag is tested positively (`((OPTIONS[tables]))` at line 1069), making the two branches of the if/elif visually symmetric.
`─────────────────────────────────────────────────`

---

## Audit Results

**ShellCheck:** CLEAN — zero findings.

**3 BCS findings:**

### [ERROR] BCS0409 (core) — Line: missing

No `require_bash 5 2` guard. The script uses `declare -n` namerefs (requires Bash 4.3), `${var@Q}` (4.4), and `shopt -s inherit_errexit` (4.4) with no version check. Fix: add `require_bash 5 2` after line 5.

### [WARN] BCS0107 (style) — Lines 666, 848

Bottom-up ordering violated in the table subsection. `render_table()` (line 666) calls three helpers defined 67–182 lines later. `_render_table_output()` (line 848) calls `_align_cell()` defined 81 lines later at 929. Correct order: `_align_cell` → `_parse_table_structure` → `_calculate_column_widths` → `_render_table_output` → `render_table`.

### [WARN] BCS0208 (recommended) — Lines 561, 1073

`((OPTIONS[...] == 0))` should be `((!OPTIONS[...]))`. Line 1069 adjacent to 1073 already uses the correct form, making the asymmetry visible.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0409 | core | **[ERROR]** | — | Missing `require_bash 5 2` |
| BCS0107 | style | [WARN] | 666, 848 | `render_table` + `_render_table_output` defined before their private helpers |
| BCS0208 | recommended | [WARN] | 561, 1073 | `((FLAG == 0))` instead of `((!FLAG))` |

Report saved to `AUDIT-BASH.md`.
bcs: ◉ Elapsed: 394s
bcs: ◉ Exit: 1
