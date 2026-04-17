bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
`★ Insight ─────────────────────────────────────`
This script is a dual-purpose design: a sourceable function AND a standalone executable. The source fence (`return 0 2>/dev/null || { ... }`) separates the two modes — when sourced, `return` succeeds and the block is skipped; when executed directly, `return` fails and the block runs. BCS requires strict mode ONLY in the direct-execution block to avoid polluting the calling shell's environment.
`─────────────────────────────────────────────────`

Here is the full compliance analysis of `/ai/scripts/Okusi/BCS/examples/which`:

---

## Findings

### [ERROR] BCS0409 — Bash Version Detection (core) — Lines 104–108

**Problem:** The direct-execution block sets strict mode but never calls `require_bash 5 2`. The script uses Bash 5.2+ features (`${var@Q}`, `local -i` in parameter expansion, `realpath`). Per BCS0409, `require_bash` must be called after strict mode and before any feature-dependent code.

**Current:**
```bash
return 0 2>/dev/null || {
  set -euo pipefail
  shopt -s inherit_errexit
  which "$@"
}
```

**Fix:** Define `bash_at_least` / `require_bash` (or source them from a library) and call `require_bash 5 2`:
```bash
bash_at_least() {
  local -i major=${1:-0} minor=${2:-0} patch=${3:-0}
  (( BASH_VERSINFO[0] != major )) && return $(( BASH_VERSINFO[0] < major ))
  (( BASH_VERSINFO[1] != minor )) && return $(( BASH_VERSINFO[1] < minor ))
  (( BASH_VERSINFO[2] >= patch ))
}
require_bash() {
  bash_at_least "$@" && return 0
  local want="${1:-0}.${2:-0}.${3:-0}" have="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
  >&2 printf 'which: requires Bash >= %s (have %s)\n' "$want" "$have"; exit 2
}
declare -fx bash_at_least require_bash

# --- source fence ---
return 0 2>/dev/null || {
  set -euo pipefail
  shopt -s inherit_errexit
  require_bash 5 2
  which "$@"
}
```

---

### [WARN] BCS0103 — Script Metadata (recommended) — Lines 16, 35

**Problem:** No `VERSION` constant is declared. The version string `2.0` is hardcoded in two places: the help text heredoc (line 16) and the version output printf (line 35). A single `declare -r VERSION=2.0` eliminates duplication and enables consistent version management.

**Fix:**
```bash
declare -r VERSION=2.0
```
Then change the heredoc delimiter from `<<'HELP'` to `<<HELP` so `$VERSION` expands inside it, and use `$VERSION` in the version printf.

---

### [WARN] BCS0201 — Type-Specific Declarations (style) — Line 11

**Problem:** String local variables are declared without the `--` type separator. BCS0201 requires `local --` for strings to make intent explicit and complete the type-declaration pattern alongside `-i`, `-a`, `-A`.

**Current:** `local target path full_path resolved`

**Fix:** `local -- target path full_path resolved`

---

### [WARN] BCS0201 — Type-Specific Declarations (style) — Line 50

**Problem:** Same issue — `local _path` omits `--`.

**Current:** `local _path=${PATH:-}`

**Fix:** `local -- _path=${PATH:-}`

---

### [WARN] BCS0406 — Dual-Purpose Scripts (core) — Lines 103–108

**Problem:** The source fence uses a `|| { ... }` compound block rather than the canonical BCS-documented form (`||:` with script execution code on subsequent lines). Both are semantically equivalent, but the BCS0406 examples explicitly document the `||:` form with code below:

```bash
# BCS canonical form:
# --- source fence ---
return 0 2>/dev/null ||:

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit
which "$@"
```

**Current (non-canonical):**
```bash
return 0 2>/dev/null || {
  set -euo pipefail
  shopt -s inherit_errexit
  which "$@"
}
```

The behaviour is identical, but the inline block form deviates from the documented pattern.

---

### [WARN] BCS0802 — Version Output (style) — Line 35

**Problem:** The version printf hardcodes `'which 2.0'` rather than using `$SCRIPT_NAME $VERSION`. BCS0802 mandates the `scriptname X.Y.Z` format via variables, not literals. This finding is downstream of BCS0103 (no VERSION constant).

**Current:** `printf 'which 2.0\n'`

**Fix** (after adding VERSION and SCRIPT_NAME): `printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"`

---

`★ Insight ─────────────────────────────────────`
BCS0201's `--` separator on `local` and `declare` is purely semantic — Bash treats `local -- x` and `local x` identically at runtime. Its value is as a machine-readable signal: an LLM or linter can instantly distinguish "this is intentionally a string" from "the author forgot to declare a type." That's why BCS mandates it even though it has zero runtime cost.
`─────────────────────────────────────────────────`

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0409 | core | [ERROR] | 104–108 | Direct-execution block missing `require_bash 5 2` after strict mode |
| BCS0103 | recommended | [WARN] | 16, 35 | No `VERSION` constant; version `2.0` hardcoded in two places |
| BCS0201 | style | [WARN] | 11 | `local target path full_path resolved` missing `--` type declaration |
| BCS0201 | style | [WARN] | 50 | `local _path=${PATH:-}` missing `--` type declaration |
| BCS0406 | core | [WARN] | 103–108 | Source fence uses `|| { }` block form; canonical BCS form is `||:` with code below |
| BCS0802 | style | [WARN] | 35 | Version output hardcodes `'which 2.0'`; should use `$SCRIPT_NAME $VERSION` |

**Result: 1 ERROR, 5 WARNs.** The script is structurally sound and demonstrates many BCS best practices correctly (quoting discipline, `@Q` for error messages, process substitution, arithmetic flags, option bundling, `#end` marker). The critical gap is the missing Bash version guard in execution mode.
bcs: ◉ Elapsed: 280s
bcs: ◉ Exit: 1
