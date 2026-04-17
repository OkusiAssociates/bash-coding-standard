bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
`★ Insight ─────────────────────────────────────`
The `((!OPTIONS[tables] == 0))` vs `((!OPTIONS[tables]))` distinction matters because BCS0208 treats `OPTIONS` values as arithmetic booleans — any non-zero value is true. Using `== 0` makes the code harder to reason about when a flag could hypothetically take values other than 0/1, and it contradicts the consistent `((FLAG))` / `((!FLAG))` idiom used everywhere else in the script.
`─────────────────────────────────────────────────`

---

**ShellCheck: 0 findings. No `[ERROR]` (core) violations. 5 `[WARN]` findings total.**

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0107 | style | [WARN] | 666–929 | `render_table` defined before its private helpers |
| BCS0107 | style | [WARN] | 1210 | `show_help` after business logic (should be layer 2) |
| BCS0208 | recommended | [WARN] | 561 | `== 0` flag comparison — use `((!OPTIONS[syntax_highlight]))` |
| BCS0208 | recommended | [WARN] | 1073 | `== 0` flag comparison — use `((!OPTIONS[tables]))` |
| BCS0102 | recommended | [WARN] | 239, 251, 850, 852 | Undocumented `#shellcheck disable` directives |

**Score: 9.2/10.** Full report saved to `/tmp/bcs-yyfWe/AUDIT-BASH.md`.
bcs: ◉ Elapsed: 824s
bcs: ◉ Exit: 1
