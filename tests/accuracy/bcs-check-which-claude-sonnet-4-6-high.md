bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll analyze this script systematically against the BCS.

---

## Findings

---

### BCS0101 — WARNING — Line 106–107

**What is wrong:** `set -euo pipefail` and `shopt -s inherit_errexit` appear inside the `||` branch of the source fence (inside a compound command block), rather than as direct executable statements after the shebang. While this works correctly at runtime, BCS0101 states strict mode "must be the first executable command after shebang, comments, and shellcheck directives." The standard pattern places these unconditionally at the top of script mode, not nested inside a block.

**How to fix:** This is a dual-purpose script, so strict mode must not run when sourced — the placement is a deliberate and functionally correct consequence of the source fence. The BCS0106 dual-purpose pattern using `return 0 2>/dev/null ||:` followed by strict mode on the next line is slightly preferred:

```bash
return 0 2>/dev/null ||:
set -euo pipefail
shopt -s inherit_errexit
which "$@"
```

The current form is a minor structural deviation, not a safety issue.

---

### BCS0103 — WARNING — Lines 1–111

**What is wrong:** No script metadata variables are declared (`VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`). The script hardcodes the version string `'which 2.0'` in two places (line 15 inside the heredoc, line 35 in the version option handler) rather than using a `VERSION` constant. BCS0103 specifies standard metadata variables.

**How to fix:** Declare a `VERSION` constant and reference it. Since this is a function-centric dual-purpose script the full set may not be needed, but `VERSION` is clearly applicable given that it is already used:

```bash
declare -r VERSION='2.0'
```

Then reference `$VERSION` on line 35 (`printf 'which %s\n' "$VERSION"`) and in the heredoc (switching to an unquoted delimiter so `$VERSION` expands). This eliminates duplication and makes version bumps a single-line change.

---

### BCS0201 — WARNING — Line 11

**What is wrong:** `local target path full_path resolved` declares four string variables without explicit type (`--`). BCS0201 requires all variables to have explicit type declarations. The `local -a` and `local -i` lines above (lines 9–10) are correct; line 11 breaks the pattern.

**How to fix:**

```bash
local -- target='' path='' full_path='' resolved=''
```

---

### BCS0201 — WARNING — Line 49

**What is wrong:** `local _path=${PATH:-}` lacks the type specifier `--`. This is inside the function body after the argument parsing block.

**How to fix:**

```bash
local -- _path=${PATH:-}
```

---

### BCS0606 — VIOLATION — Lines 60, 66, 82, 88

**What is wrong:** Four arithmetic conditional expressions of the form `((silent)) || printf ...` are used to suppress output. These are safe and correct. However, lines 70 and 95 use:

```bash
((found)) || allret=1
```

These are safe (the assignment always returns 0). But the inverse issue arises on line 91:

```bash
((allmatches)) || break
```

Under `set -euo pipefail` (active in script mode), if `allmatches` is `0`, the arithmetic expression `((allmatches))` returns exit code 1, which — without `||` providing an alternative — would trigger `set -e` and abort the script. However, the `|| break` *is* present, so `break` handles the false case and the overall expression succeeds. This is safe.

Re-examining more carefully: all `((flag)) || action` forms have a right-hand side that succeeds (assignments return 0, `break` returns 0, `printf` returns 0). No bare `((cond))` without `||:` or an alternative is present. **No violation here — retracting this finding.**

*(Finding retracted — no violation on these lines.)*

---

### BCS0702 — WARNING — Line 35

**What is wrong:** `printf 'which 2.0\n'` outputs version information to **stdout**, which is correct for version output. However per BCS0705, version output uses `echo "$SCRIPT_NAME $VERSION"` to stdout — this is fine. No issue here.

*(Finding retracted — no violation.)*

---

### BCS0802 — WARNING — Line 35

**What is wrong:** The version output format is `'which 2.0\n'` — this embeds the name literally rather than following the BCS0802 format of `scriptname X.Y.Z`. It also doesn't use the `$VERSION` / `$SCRIPT_NAME` variables (see BCS0103). The format is close to correct but the version number follows the name with a space rather than appearing as a standalone version string in the recommended form.

**How to fix:** Once `VERSION` is declared, use:

```bash
-V|--version) printf 'which %s\n' "$VERSION"; return 0 ;;
```

This is a WARNING, not a VIOLATION, as the output is functionally equivalent.

---

### BCS0803 — VIOLATION — Line 46

**What is wrong:** No validation is performed for the case where targets are provided but empty strings are included, and more importantly, there is no error message when `targets` is empty — the function silently returns 1. BCS0803 states "validate required arguments after parsing" with clear error messages. A bare `return 1` with no message when no targets are provided is silent failure.

**How to fix:** Per BCS0803 and BCS0703 (error messaging):

```bash
((${#targets[@]})) || { >&2 printf 'which: no command specified\n'; return 2; }
```

Using exit code 2 (usage error) is more appropriate than 1 (not found) for the case of missing arguments.

---

### BCS1201 — WARNING — Line 50

**What is wrong:** The logic on line 50 appears to have a bug that is worth noting as a code quality issue even if it's not a strict BCS style violation. The comment says "trailing colon means current directory — guard for read -ra." The code `[[ $_path != *: ]] || _path+=':'` checks if `_path` *does not* end with `:`, and if it *does* end with `:`, appends another `:`. This doubles a trailing colon (e.g., `/usr/bin:` becomes `/usr/bin::`) rather than preventing the empty-element issue. The logic appears inverted — this is a functional bug.

**How to fix:** The intent is to ensure that a trailing `:` (which `read -ra` would silently drop, losing the implied `.`) is converted to `:.` so the empty element is preserved. The correct fix is:

```bash
[[ $_path != *: ]] || _path+='.'
```

This turns `/usr/bin:` into `/usr/bin:.`, which `read -ra` splits into `/usr/bin` and `.`, correctly representing the trailing current-directory element. This is a VIOLATION as the current code is logically incorrect.

---

### BCS0109 — ✓ PASS

`#end` on line 111 is present and correct.

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0101 | WARNING | 106–107 | `set -euo pipefail` / `shopt` nested inside `\|\|` block instead of following bare `return 0 2>/dev/null \|\|:` fence |
| BCS0103 | WARNING | 1, 15, 35 | No `VERSION` constant declared; version string `'which 2.0'` hardcoded in two separate places |
| BCS0201 | WARNING | 11 | `local target path full_path resolved` missing explicit type specifier `--` |
| BCS0201 | WARNING | 49 | `local _path=...` missing explicit type specifier `--` |
| BCS0803 | VIOLATION | 46 | Silent `return 1` when no targets given — missing error message and should return exit code 2 (usage error) |
| BCS1201 | VIOLATION | 50 | Logic bug: `_path+=':'` doubles a trailing colon instead of appending `.`; should be `_path+='.'` to correctly represent the POSIX trailing-colon current-directory semantics |
bcs: ◉ Tokens: in=24035 out=2096
bcs: ◉ Elapsed: 39s
