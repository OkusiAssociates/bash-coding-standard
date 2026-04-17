bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
Now I have the full standard. Here is the compliance analysis.

---

## BCS Compliance Report: `which`

`★ Insight ─────────────────────────────────────`
This script is a dual-purpose library/executable — a design pattern with specific BCS rules (BCS0106/BCS0406). Most violations found are style-tier issues around type specifiers; the only meaningful structural deviation is the source-fence variant.
`─────────────────────────────────────────────────`

---

### [ERROR] BCS0106 — Undocumented source-fence form (core)

**Lines 104–109:**
```bash
return 0 2>/dev/null || {
  # --- direct execution ---
  set -euo pipefail
  shopt -s inherit_errexit
  which "$@"
}
```

BCS0106 lists exactly two acceptable fence forms:
- `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0`
- `return 0 2>/dev/null ||:`

The script uses a **third form**: `return 0 2>/dev/null || { ... }`, bundling script-mode code inside the `||` block. Functionally equivalent, but not a documented acceptable pattern.

**Fix:** Use the standard `return 0 2>/dev/null ||:` fence, with script-mode code below it as sequential statements:
```bash
# --- source fence ---
return 0 2>/dev/null ||:

# --- direct execution ---
set -euo pipefail
shopt -s inherit_errexit
which "$@"
#end
```

---

### [WARN] BCS0103 — Missing VERSION metadata (recommended)

No `declare -r VERSION=` is present. The version is hard-coded as a bare string `'which 2.0'` in the `printf` at line 35 and in the help text at line 15. In script mode (after the fence), no metadata variables are declared after `shopt -s inherit_errexit`.

**Fix:** Add metadata to the script-mode section:
```bash
set -euo pipefail
shopt -s inherit_errexit
declare -r VERSION=2.0
```
Then replace `printf 'which 2.0\n'` (line 35) with `printf '%s %s\n' 'which' "$VERSION"` and update the help text delimiter to allow `$VERSION` expansion.

---

### [WARN] BCS0201 — String locals without `--` type specifier (style)

**Line 11:**
```bash
local target path full_path resolved
```

String variables must use `local --` to make the type choice explicit (BCS0201). The `-i`/`-a`/`-A` vars on lines 9–10 are correctly typed.

**Fix:**
```bash
local -- target path full_path resolved
```

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0106  | core | [ERROR]  | 104–109 | Source fence uses undocumented `\|\| { ... }` block form; only `\|\|:` (followed by sequential code) is specified as acceptable |
| BCS0103  | recommended | [WARN] | — (absent) | No `declare -r VERSION=` metadata; version hard-coded as literal string in `printf` and help text |
| BCS0201  | style | [WARN] | 11 | String locals `target path full_path resolved` declared without `--` type specifier |

`★ Insight ─────────────────────────────────────`
The `|| { }` vs `||:` distinction in BCS0106 is not just cosmetic — `||:` makes the fence a single line/statement, which matches how `#bcscheck disable` suppression scoping works (BCS1206 directive covers "the next command"). The block form changes the suppression surface and could interact unexpectedly with tooling.
`─────────────────────────────────────────────────`

**Overall:** 1 core [ERROR], 2 [WARN]. The script is otherwise well-written — correct strict-mode placement for a dual-purpose script, proper `declare -fx`, correct `[[ ]]` usage throughout, proper IFS-scoped `read -ra`, `||:` guarding for arithmetic conditionals, and `>&2` stderr placement at line start.
bcs: ◉ Elapsed: 302s
bcs: ◉ Exit: 1
