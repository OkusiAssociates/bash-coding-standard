bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
## Analysis

### BCS0102 / BCS0101 — WARNING — Lines 1, 106
The shebang is present, but `set -euo pipefail` and `shopt -s inherit_errexit` appear **after the source fence** (lines 106–107), which is correct for a dual-purpose script. However, there is **no brief description comment** between the shebang and the function definition — lines 4–5 are comments but they precede the `#shellcheck` directive in the wrong order. Minor structural point only; not a clear violation.

*(Retracting — the description comment on line 4 is present and acceptable. No finding.)*

---

### BCS0103 — WARNING — Lines 1–11
This is a dual-purpose library script. No `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, or `SCRIPT_NAME` metadata variables are declared. For a pure library/function export script this is acceptable per BCS0103 ("Not all scripts will require all Script Metadata variables"), but `SCRIPT_NAME` is typically useful and the version string is hardcoded inline at line 15 and line 35 as `'which 2.0'` rather than referencing a `VERSION` variable. If the version ever changes, it must be updated in two places.

**Severity:** WARNING
**Fix:** Declare `declare -r VERSION='2.0'` and reference it in both the help text and the version print: `printf 'which %s\n' "$VERSION"` and in the heredoc use an unquoted delimiter to expand `$VERSION`.

---

### BCS0106 — WARNING — Line 104
The source fence uses `return 0 2>/dev/null || { ... }` — this is one of the two acceptable fence patterns per BCS0106. However, the standard `return 0 2>/dev/null ||:` form simply returns; wrapping the script-mode block in `|| { ... }` is a functional inversion of the pattern (the else-branch executes on direct run). This is a valid and known alternative, but it differs from both reference forms shown in BCS0106. Functionally correct.

**Severity:** WARNING (style deviation from reference patterns)
**Fix:** Either form shown in BCS0106 is acceptable. If the intent is to keep it as-is, add a comment explaining the inversion. Alternatively restructure as:

```bash
return 0 2>/dev/null ||:
set -euo pipefail
shopt -s inherit_errexit
which "$@"
```

---

### BCS0201 — WARNING — Line 11
```bash
local target path full_path resolved
```
Four string variables are declared without the `--` type separator. Per BCS0201, string variables must use `local --`.

**Severity:** WARNING
**Fix:**
```bash
local -- target='' path='' full_path='' resolved=''
```
Also initialize them to empty strings at declaration time.

---

### BCS0201 — WARNING — Line 49
```bash
local _path=${PATH:-}
```
Missing `--` type separator.

**Severity:** WARNING
**Fix:**
```bash
local -- _path=${PATH:-}
```

---

### BCS0606 — VIOLATION — Lines 60, 66, 82, 88, 91
Multiple arithmetic conditional expressions use `((cond)) || action` or `((cond)) && action` patterns **without** `||:` where needed:

- **Line 60:** `((silent)) || printf ...` — this is the inverted form (preferred per BCS0606, executes when silent=0). ✓ Correct.
- **Line 66:** `((silent)) || printf ...` — same. ✓ Correct.
- **Line 82:** `((silent)) || printf ...` — same. ✓ Correct.
- **Line 88:** `((silent)) || printf ...` — same. ✓ Correct.
- **Line 91:** `((allmatches)) || break` — inverted form. ✓ Correct.

*(Retracting — all `((cond)) || action` uses here are the preferred inverted form per BCS0606. No violation.)*

---

### BCS0606 — VIOLATION — Lines 70, 95
```bash
((found)) || allret=1
```
This is the inverted form: when `found` is 0 (false), set `allret=1`. Under `set -e`, a false `((...))` exits the script. However, this code is **inside the `which()` function**, which is defined *before* the source fence where `set -euo pipefail` is applied. When sourced, `set -e` is not active inside the function at definition time.

But when executed directly (lines 106–108 activate `set -e`), the function runs under `set -e`, making `((found)) || allret=1` safe because it is the inverted `||` form — the assignment on the right always returns 0, so the chain exits cleanly. ✓ Correct.

*(Retracting — the inverted `||` form is the preferred BCS0606 pattern. No violation.)*

---

### BCS0203 — WARNING — Lines 9–11
Variable names `allret`, `allmatches`, `found` are acceptable but the naming of `_path` (line 49) uses a leading underscore convention typically reserved for private *functions*, not local variables. Minor style point.

**Severity:** WARNING (minor)
**Fix:** Rename `_path` to `path_str` or `raw_path` to avoid convention collision.

---

### BCS0407 — WARNING — Lines 103–109
This script is structured as a dual-purpose script (BCS0406/BCS0407) — functions defined above the fence, exported with `declare -fx`, and executed below. However, it does **not** reject direct execution with a non-library guard, nor does it implement idempotent initialization (BCS0407 version guard). For a script explicitly designed to also be executed directly (line 108: `which "$@"`), rejection is not required. The missing version guard is a minor omission for the library use case.

**Severity:** WARNING
**Fix:** Add idempotent guard if this is intended to be sourced repeatedly:
```bash
[[ -v WHICH_VERSION ]] || declare -rx WHICH_VERSION='2.0'
```

---

### BCS0505 / BCS1205 — Observation (no finding)
No `++` increment operators used. All arithmetic is via `+=1` or direct assignment. ✓ Compliant.

---

### BCS0702 — WARNING — Lines 63, 85
```bash
((silent)) || >&2 printf 'Cannot resolve canonical path for %s\n' "${target@Q}"
((silent)) || >&2 printf 'Cannot resolve canonical path for %s\n' "${full_path@Q}"
```
These are error/warning messages going to stderr. The redirect `>&2` is correctly placed at the beginning of the command. ✓ Compliant per BCS0702.

However, these messages are generated inside the library function with raw `printf` rather than through a messaging function. Since this is a self-contained library with no messaging infrastructure, this is acceptable. No finding.

---

### BCS0109 — COMPLIANT — Line 111
`#end` is present as the final line. ✓

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0103 | WARNING | 15, 35 | Version string `'which 2.0'` hardcoded in two places; no `VERSION` variable declared |
| BCS0106 | WARNING | 104–109 | Source fence uses inverted `|| { ... }` block form rather than either reference pattern; functionally valid but deviates from BCS0106 examples |
| BCS0201 | WARNING | 11 | `local target path full_path resolved` — missing `--` type separator and missing initializers |
| BCS0201 | WARNING | 49 | `local _path=...` — missing `--` type separator |
| BCS0203 | WARNING | 49 | `_path` uses underscore prefix convention reserved for private functions, not local variables |
| BCS0407 | WARNING | 1–101 | No idempotent version guard for repeated-source protection when used as a library |
bcs: ◉ Tokens: in=24031 out=2024
bcs: ◉ Elapsed: 42s
