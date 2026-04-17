bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
`★ Insight ─────────────────────────────────────`
`find -print` + `readarray -t` is a common pattern that looks safe but isn't: any filename containing a literal newline (legal on Linux filesystems) splits across two array slots. The null-delimiter pair (`-print0` + `readarray -d ''`) is the only fully correct form. In a cleanup script that runs `rm` on the collected names, a split entry could silently skip or mis-target a file.
`─────────────────────────────────────────────────`

---

**ShellCheck:** clean (exit 0, zero findings).
**bcscheck:** 3 findings across 1 ERROR and 2 WARNs.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0702 | core | **[ERROR]** | 49 | `echo >&2` — `>&2` must be at the **beginning**: `>&2 echo` |
| BCS0806 | recommended | [WARN] | 171–172 | `-P`/`-N` non-standard assignment; `#bcscheck disable=BCS0806` on line 169 covers line 170 only — a second disable is needed before line 171 |
| BCS0906 | recommended | [WARN] | 216–223 | `find -print` + `readarray -t` splits on newlines; switch to `-print0` + `readarray -d '' -t` |

**Score: 9/10.** Report saved to `AUDIT-BASH.md`.
bcs: ◉ Elapsed: 681s
bcs: ◉ Exit: 1
