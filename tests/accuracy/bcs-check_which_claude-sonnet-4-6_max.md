bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll perform an exhaustive line-by-line audit of this script against the BCS.

---

**Preliminary: Script Structure**

This is a dual-purpose script (sourceable function + direct execution). The source fence is at line 104. Strict mode (`set -euo pipefail`) is in the execution block, not at the top — this is the correct pattern for dual-purpose scripts per BCS0106.

---

**Findings**

**[WARN] BCS0103 line 1–11:** Standard metadata variables (`VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`) are absent. The script uses a hardcoded version string `'which 2.0'` at lines 15 and 35 instead of a `VERSION` variable. While not all metadata is required, the version string duplication is the concrete problem here — a `declare -r VERSION=2.0` would centralize it and satisfy the metadata recommendation.

*Fix:* Add `declare -r VERSION=2.0` after the source fence guard (or at top of the execution block), then reference `$VERSION` in the help text and version output.

---

**[WARN] BCS0201 line 11:** `local target path full_path resolved` declares four string variables without the `--` type separator. Per BCS0201, string variables should use `declare --` / `local --` to signal conscious type choice.

```bash
# wrong
local target path full_path resolved

# correct
local -- target='' path='' full_path='' resolved=''
```

*Fix:* Change to `local -- target='' path='' full_path='' resolved=''`.

---

**[WARN] BCS0201 line 49:** `local _path=${PATH:-}` is missing the `--` type separator for a string variable.

*Fix:* Change to `local -- _path=${PATH:-}`.

---

**[WARN] BCS0203 line 49:** The variable `_path` uses a leading underscore, which BCS0203 reserves for *private functions*, not variables. Variable naming convention is `lower_case` without underscore prefix.

*Fix:* Rename to `local -- path_str=${PATH:-}` (or similar) and update references on lines 50–51.

---

**[WARN] BCS0301 line 35:** `printf 'which 2.0\n'` uses a single-quoted format string — that part is correct — but the version string `which 2.0` is hardcoded rather than derived from a `VERSION` variable. This is a secondary consequence of the BCS0103 finding. As a standalone style note: `printf '%s\n' "which $VERSION"` would be the correct form once `VERSION` is declared.

*Fix:* Declare `declare -r VERSION=2.0` and change line 35 to `printf '%s %s\n' 'which' "$VERSION"; return 0`.

---

**[WARN] BCS0704 line 15:** The help text at line 15 hardcodes `which 2.0` rather than referencing `$SCRIPT_NAME` and `$VERSION`. BCS0704 shows the reference pattern using `$SCRIPT_NAME $VERSION` in help output. Since this is a sourced function (no `SCRIPT_NAME` available in source context), using a hardcoded name is understandable — however the version string should still be derived from a `$VERSION` variable to avoid duplication.

*Fix:* Use a non-quoted heredoc delimiter and reference `$VERSION`: `cat <<HELP` with `which $VERSION - Locate executables in PATH`.

---

**[WARN] BCS0802 line 35:** Version output format. BCS0802 specifies format `scriptname X.Y.Z` — the output `which 2.0` is compliant in content but uses `printf 'which 2.0\n'` with a hardcoded string. No structural format violation, but the hardcoding compounds the BCS0103 issue. *(This is covered under BCS0103/BCS0301 findings above — no separate entry needed.)*

---

**[ERROR] BCS0606 lines 60, 66, 82, 88, 91:** Multiple arithmetic conditional chains missing `||:`.

- Line 60: `((silent)) || printf '%s\n' "$resolved"` — this is the **inverted** `||` form. Under `set -e`, if `((silent))` is true (silent=1), the `||` short-circuits and the `printf` is skipped — return value of `((silent))` is 0 (true), so no problem. ✓ This is safe.
- Line 63: `((silent)) || >&2 printf ...` — same inverted form. ✓ Safe.
- Line 66: `((silent)) || printf '%s\n' "$target"` — same. ✓ Safe.
- Line 70: `((found)) || allret=1` — inverted form, assignment always returns 0. ✓ Safe.
- Line 82: `((silent)) || printf '%s\n' "$resolved"` — ✓ Safe.
- Line 85: `((silent)) || >&2 printf ...` — ✓ Safe.
- Line 88: `((silent)) || printf '%s\n' "$full_path"` — ✓ Safe.
- Line 91: `((allmatches)) || break` — inverted form, `break` returns 0. ✓ Safe.
- Line 95: `((found)) || allret=1` — ✓ Safe.

All arithmetic conditionals use the inverted `||` form correctly. No BCS0606 violations.

*(Retracted — no finding.)*

---

**[WARN] BCS0106 line 104:** The source fence uses `return 0 2>/dev/null || { ... }`. BCS0106 documents two acceptable fence patterns:

1. `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0`
2. `return 0 2>/dev/null ||:`

The pattern used here — `return 0 2>/dev/null || { execution block }` — is a functional variant that *embeds the script-mode code in the else-branch of the fence*. This is not one of the two documented patterns. The documented `return 0 2>/dev/null ||:` fence puts strict mode and execution *after* the fence unconditionally (because `||:` always succeeds and terminates the chain). Using `|| { ... }` inverts this: the block only runs if `return` fails (i.e., not sourced). Functionally correct, but structurally non-standard.

*Fix:* Use the documented form:
```bash
return 0 2>/dev/null ||:

set -euo pipefail
shopt -s inherit_errexit
which "$@"
#end
```

---

**[WARN] BCS0109 line 111:** `#end` is used as the end marker, which is one of the two acceptable forms (`#fin` or `#end`). ✓ No violation.

*(Retracted — no finding.)*

---

**[WARN] BCS1202 line 100:** `# Export function to subshells` is a comment that paraphrases line 101 (`declare -fx which`). Per BCS1202, comments must not mechanically restate the next statement. A reader can see `declare -fx` means "export function."

*Fix:* Remove the comment, or replace with something non-obvious if warranted (e.g., a note about why export is needed in this context).

---

**[WARN] BCS1202 line 103:** `# --- source fence ---` and `# --- direct execution ---` (line 105) are structural section markers using `---` dash separators. BCS1204 states 80-dash separators are for "major script divisions only — typically no more than two or three per file." Three-dash markers (`---`) are not the BCS1204 standard form (which is `#` followed by 2-4 words). However, these serve as fence labels rather than section headers, and BCS0106 examples use exactly this notation for fence comments. No violation.

*(Retracted — no finding.)*

---

**[WARN] BCS0201 / BCS0401 line 11 (initialization):** String variables `target`, `path`, `full_path`, `resolved` are declared without initializers. BCS best practice is to initialize variables at declaration.

*Fix:* `local -- target='' path='' full_path='' resolved=''`

*(Merged with BCS0201 finding above.)*

---

**Re-examining line 51 — IFS inline:**

```bash
IFS=':' read -ra path_dirs <<< "$_path"
```

Per the Compliance Checking Reference: "Inline IFS is already scoped — The `IFS=value command` form modifies IFS only for the duration of that command. This is NOT an unlocalized IFS modification." ✓ No violation.

---

**Re-examining line 13 — nested function `_which_help`:**

BCS0401 notes nested functions are permissible within other functions in some cases. The underscore prefix is used for private functions (BCS0203), and this is indeed a private helper. ✓ Acceptable.

---

**Re-examining line 39 — option bundling:**

`-[acsVh]?*` correctly lists the valid short options. ✓ Compliant with BCS0805.

---

**Re-examining line 46:**

`((${#targets[@]})) || return 1` — inverted form, `return 1` itself can return non-zero but that's the intent (propagating failure). Under `set -e` this is inside the `which()` function body, and strict mode isn't active during source. In execution mode, `which` is called at line 108 where its return value propagates. The `|| return 1` form is safe. ✓ No violation.

---

**[WARN] BCS0103 / BCS1208 (dry-run) — N/A for this script.**

No dry-run pattern expected for a `which` replacement. ✓ N/A.

---

**Summary Table**

| BCS Code | Tier | Severity | Line(s) | Description |
|---|---|---|---|---|
| BCS0103 | recommended | WARN | 1–11, 35 | Missing `VERSION` metadata variable; version string `'which 2.0'` hardcoded in two places |
| BCS0201 | style | WARN | 11 | `local target path full_path resolved` missing `--` type separator and initializers |
| BCS0201 | style | WARN | 49 | `local _path=...` missing `--` type separator |
| BCS0203 | style | WARN | 49 | Variable `_path` uses underscore prefix; reserved for private functions, not variables |
| BCS0704 | style | WARN | 15 | Help text hardcodes `which 2.0`; should reference `$VERSION` variable |
| BCS0106 | core | WARN | 104 | Source fence uses non-standard `return 0 2>/dev/null \|\| { block }` form; documented patterns are `[[ BASH_SOURCE[0] == "$0" ]] \|\| return 0` or `return 0 2>/dev/null \|\|:` with code after |
| BCS1202 | style | WARN | 100 | Comment `# Export function to subshells` mechanically paraphrases `declare -fx which` |
bcs: ◉ Tokens: in=28685 out=2811
bcs: ◉ Elapsed: 55s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
