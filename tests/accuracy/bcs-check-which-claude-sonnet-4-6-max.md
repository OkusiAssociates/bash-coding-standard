bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll analyze this script line by line against the BCS.

---

## Analysis

**Line 11 — BCS0201 — WARNING**

```bash
local target path full_path resolved
```

Variables declared without explicit type. BCS0201 requires type-specific declarations with `--` for strings.

**Fix:** `local -- target path full_path resolved`

---

**Line 49 — BCS0201 — WARNING**

```bash
local _path=${PATH:-}
```

String variable declared without explicit type.

**Fix:** `local -- _path=${PATH:-}`

---

**Line 50 — BCS0606 — WARNING**

```bash
[[ $_path != *: ]] || _path+=':'
```

The logic here appears inverted. If `$_path` ends with a colon, appending another `:` makes it `...::`, which would introduce a spurious empty (current-directory) element — the opposite of the stated intent in the comment ("trailing colon means current directory — guard for read -ra"). The correct guard should strip or double the trailing colon to expose the implicit `.` entry, not add a second colon. If the intent is to make the trailing colon produce an empty field for `read -ra`, the condition should be `[[ $_path == *: ]] && _path+=':'` (or equivalently `[[ $_path != *: ]] || ...` — but then `_path+=':'` is the wrong action). This is a logic error regardless of which interpretation is correct.

This is a code-correctness issue, not a BCS style issue — flagging as VIOLATION under BCS0601 (safe error handling / correct logic).

**Fix:** Clarify intent. If the goal is to expose the trailing empty field to `read -ra`, replace with:
```bash
[[ $_path == *: ]] && _path+=':'
```
Or if the goal is to strip the trailing colon:
```bash
_path=${_path%:}
```

---

**Line 98 — BCS0201 / BCS0602 — WARNING**

```bash
return $allret
```

`$allret` should use braces only when necessary (it doesn't here, which is fine), but the return value of `1` is used generically for "not found." This is consistent with the documented exit codes at line 26 and is acceptable. No finding.

---

**Lines 104–109 — BCS0106 — WARNING**

```bash
return 0 2>/dev/null || {
  # --- direct execution ---
  set -euo pipefail
  shopt -s inherit_errexit
  which "$@"
}
```

BCS0106 documents two acceptable fence patterns. The `return 0 2>/dev/null ||:` form is one. This script uses `return 0 2>/dev/null || { ... }` — a block-on-failure variant not listed in BCS0106. The standard form places script-mode code *after* the fence, not inside the `||` branch. While functionally equivalent for direct execution, this inverts the conventional reading (the block executes when `return` fails, i.e., when not sourced) and differs from both documented patterns.

**Fix:** Use the standard pattern:
```bash
return 0 2>/dev/null ||:

set -euo pipefail
shopt -s inherit_errexit
which "$@"
```

---

**Lines 106–107 — BCS0101 — VIOLATION**

`set -euo pipefail` and `shopt -s inherit_errexit` appear inside the `||` block at lines 106–107, which only executes during direct execution. When the script is sourced, these lines are correctly skipped (BCS0106: "Never apply `set -euo pipefail` when sourced"). However, in direct-execution mode, `set -euo pipefail` is placed *after* `which "$@"` would be called — wait, no: `which "$@"` is at line 108, after strict mode is set at 106. The order within the block is correct for direct execution. This is only a structural style deviation covered by the BCS0106 finding above. No separate violation.

---

**No `#fin` / uses `#end` — BCS0109 — PASS**

Line 111 is `#end`. BCS0109 explicitly permits either `#fin` or `#end`. No finding.

---

**Lines 30–44 — BCS0801 — WARNING**

The argument parsing `while (($#)); do case...; shift` pattern is correct. The option bundling at line 39 lists `-[acsVh]?*` — this correctly includes all defined short options (`-a`, `-c`, `-s`, `-V`, `-h`). No finding.

---

**Line 46 — BCS0606 — WARNING**

```bash
((${#targets[@]})) || return 1
```

This is the inverted-condition pattern from BCS0606 and is correct. No finding.

---

**Lines 60, 66, 82, 88 — BCS0606 — check**

```bash
((silent)) || printf '%s\n' "$resolved"
```

Inverted condition, correct pattern. No finding.

---

**Line 91 — BCS0606 — check**

```bash
((allmatches)) || break
```

Inverted condition, correct pattern. No finding.

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0201 | WARNING | 11 | `local target path full_path resolved` — string variables declared without `--` type specifier |
| BCS0201 | WARNING | 49 | `local _path=...` — string variable declared without `--` type specifier |
| BCS0601 | VIOLATION | 50 | Logic error: `[[ $_path != *: ]] \|\| _path+=':'` appends a colon when one already exists, creating `...::` (double empty element) — contradicts the comment's intent |
| BCS0106 | WARNING | 104–109 | Source fence uses non-standard `return 0 2>/dev/null \|\| { ... }` block form; BCS0106 documents two patterns, neither of which places script-mode code inside the `\|\|` branch |
bcs: ◉ Tokens: in=24029 out=1519
bcs: ◉ Elapsed: 31s
