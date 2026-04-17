bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll analyze the `which` script against the BCS standard systematically.

`★ Insight ─────────────────────────────────────`
The `which` script is a dual-purpose script (BCS0406): its `which()` function is defined above the source fence with `declare -fx`, making it both sourceable as a library and directly executable. This pattern is architecturally important — it means strict mode must NOT appear above the fence (it would alter the sourcing shell's environment), only below it.
`─────────────────────────────────────────────────`

---

## BCS Compliance Analysis: `which`

### BCS0101 — Strict Mode (core)
**PASS.** Strict mode (`set -euo pipefail` + `shopt -s inherit_errexit`) correctly appears below the source fence at lines 107–108, not in the function body. Correct dual-purpose pattern.

### BCS0102 — Shebang (recommended)
**PASS.** Line 1: `#!/usr/bin/bash` — preferred form.

### BCS0103 — Script Metadata (recommended)
**PASS (marginal).** No `VERSION` variable declared; version string `which 2.0` is duplicated at line 15 (help text) and line 35 (`printf`). However, BCS0103 says "Not all scripts need all four" metavars, and a `VERSION` global would pollute the sourcing shell's namespace — so the trade-off is defensible for a sourceable function. No violation reported.

### BCS0106 — Dual-Purpose Script / Source Fence (core)
**PASS.** Lines 103–109 use the `return 0 2>/dev/null || { ... }` form. BCS0106 lists `return 0 2>/dev/null ||:` as correct; the `|| { block }` variant combines fence and execution — functionally equivalent and still valid.

### BCS0109 — End Marker (style)
**PASS.** Line 111: `#end` — acceptable. BCS0109 permits `#end` or `#fin`.

---

### BCS0201 — Type-Specific Declarations (style) → **[WARN]**

**Line 11:**
```bash
local target path full_path resolved
```
No explicit type specifier. BCS0201 requires `--` to signal a conscious string-type choice.

**Fix:**
```bash
local -- target path full_path resolved
```

---

### BCS0201 — Type-Specific Declarations (style) → **[WARN]**

**Line 49:**
```bash
local _path=${PATH:-}
```
Missing `--` type specifier.

**Fix:**
```bash
local -- _path=${PATH:-}
```

---

### BCS0202 — Variable Scoping (core)
**PASS.** All variables inside `which()` use `local`. ✓

### BCS0203 / BCS0402 — Naming Conventions
**PASS.** `which()` (lowercase), `_which_help()` (underscore-prefixed private). `which` is not a bash built-in — it's an external command being replaced, so no built-in override issue.

### BCS0206 — Arrays (core)
**PASS.** `local -a targets=() path_dirs=()` with `readarray`-equivalent `IFS=':' read -ra` here-string form. Arrays properly quoted throughout: `"${targets[@]}"`, `"${path_dirs[@]}"`.

### BCS0208 — Boolean Flags (recommended)
**PASS.** `local -i allmatches=0 canonical=0 silent=0 allret=0 found=0` — integer flags throughout. ✓

### BCS0301 — Quoting Fundamentals (style)
**PASS.** Single quotes for static strings, double quotes only when expansion needed. ✓

### BCS0303 — Quoting in Conditionals (core)
**PASS.** All `[[ ]]` tests use unquoted variables correctly. ✓

### BCS0304 — Here Documents (recommended)
**PASS.** Line 14: `cat <<'HELP'` — quoted delimiter for literal content. ✓

### BCS0501 — Conditionals (core)
**PASS.** `while (($#))`, `((${#targets[@]})) || return 1`, `if [[ -f $target && -x $target ]]` — all correct forms. ✓

### BCS0502 — Case Statements (recommended)
**PASS.** No quotes on the case expression `case $1 in`, no quotes on literal patterns, `*)` default catches positional args. ✓

### BCS0503 — Loops (core)
**PASS.** Loop variables `target` and `path` declared at lines 11 before loops at lines 53 and 74. Arrays quoted in `for` iteration. ✓

### BCS0504 — Process Substitution (core)
**PASS.** No pipe-to-while. Uses here-string `<<< "$_path"` for `read -ra`. ✓

### BCS0601 — Exit on Error (core)
**PASS.** `if resolved=$(realpath -- ...)` correctly captures a potentially-failing command substitution. ✓

### BCS0606 — Conditional Declarations (core)
**PASS.** All flag-guarded actions use the inverted `||` form (e.g., `((silent)) || printf ...`, `((allmatches)) || break`, `((found)) || allret=1`) — no `||:` needed with inverted form. ✓

### BCS0702 — STDOUT vs STDERR (core)
**PASS.** `>&2` placed at the beginning for all error output (lines 40, 64, 85). Data output (`printf '%s\n'`) goes to stdout. ✓

### BCS0801 — Standard Parsing Pattern (core)
**PASS.** `while (($#)); do case $1 in ... esac; shift; done` — canonical form. `continue` after disaggregation, `break` for `--`, mandatory `shift` at line 45. ✓

### BCS0802 — Version Output (style)
**PASS.** Line 35: `printf 'which 2.0\n'` — format is `name X.Y` without the word "version". ✓

### BCS0805 — Short Option Bundling (recommended)
**PASS.** Line 39: `-[acsVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;` — canonical disaggregation pattern listing only valid short options. ✓

### BCS0806 — Standard Options (recommended)
**PASS.** `-V`/`--version` and `-h`/`--help` both present. ✓

---

## Summary Table

| BCS Code | Tier  | Severity | Line(s) | Description |
|----------|-------|----------|---------|-------------|
| BCS0201  | style | [WARN]   | 11      | `local target path full_path resolved` — missing `--` type specifier; use `local -- target path full_path resolved` |
| BCS0201  | style | [WARN]   | 49      | `local _path=${PATH:-}` — missing `--` type specifier; use `local -- _path=${PATH:-}` |

---

**Overall: 2 warnings, 0 errors.** The script is a high-quality BCS exemplar. Both findings are cosmetic style-tier omissions of the `--` type specifier on string `local` declarations — the only two places where `local` is used without an explicit type qualifier.
bcs: ◉ Elapsed: 225s
