bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll analyze this script systematically against the BCS rules.

**Structure review:**
- Dual-purpose script with source fence at line 104
- `which()` function defined before the fence ✓
- `set -euo pipefail` only in script mode ✓
- Ends with `#end` ✓

**Checking each rule area:**

**BCS0101/BCS0106:** Source fence pattern used — `set -euo pipefail` after fence ✓. `shopt -s inherit_errexit` present ✓.

**BCS0103:** No `SCRIPT_NAME`/`SCRIPT_PATH` — but this is a minimal dual-purpose utility; those are unused, so BCS0405 applies. No violation.

**BCS0201 line 11:** `local target path full_path resolved` — missing explicit type declarations (`--`).

**BCS0203:** Function `_which_help` nested inside `which` — this is a valid nested function pattern permitted by BCS0401.

**BCS0301 line 15:** Help text contains `which 2.0` — this is inside a heredoc (literal content), not a string comparison or message. Not applicable.

**BCS0606 lines 60,63,66,82,85,88:** `((silent)) || printf ...` — inverted form, no `||:` needed. ✓. Lines 70, 91, 95: `((found)) || allret=1` and `((allmatches)) || break` — inverted form ✓.

**BCS0503 line 51:** `IFS=':' read -ra path_dirs <<< "$_path"` — inline IFS assignment is correctly scoped to the single command. Per the Compliance Checking Reference, this is NOT a violation.

**BCS0801:** Parsing inside `which()` function body (not `main()`), but this IS the function — it's a library function, not a script with `main()`. The function itself serves as the entry point. Acceptable.

**BCS0802:** Version output at line 35: `printf 'which 2.0\n'` — format is `name version` without the word "version". ✓

**BCS0103/BCS0106:** No `#fin` or `#end` — wait, line 111 has `#end`. ✓

**BCS0606 line 70:** `((found)) || allret=1` — inverted form, safe ✓.

**BCS0606 line 91:** `((allmatches)) || break` — inverted form ✓.

**BCS0606 lines 60, 66, 82, 88:** `((silent)) || printf '%s\n' "$resolved"` — these are inside nested `if` blocks with `set -euo pipefail` NOT active (function defined before fence). However, when called in script mode, `set -e` IS active. The `((silent))` when `silent=0` returns exit code 1 — but this is inside an `if` compound command's body... wait, let me re-examine. These are bare `((silent)) || printf` statements not inside an `if` condition. Under `set -e`, `((silent))` returning 1 (when silent=0) would... actually no — `||` chains: the overall expression succeeds if either side succeeds. Since `printf` returns 0, the `||` chain returns 0. This is fine.

Actually re-examining line 60: `((silent)) || printf '%s\n' "$resolved"` — when `silent=0`, `((silent))` is false (exits 1), then `printf` runs and returns 0, so overall exit is 0. When `silent=1`, `((silent))` is true (exits 0), short-circuits, overall exit 0. Safe either way. ✓

**BCS0201 line 11 — missing type declarations:** `local target path full_path resolved` uses no type specifier.

**BCS0104/BCS0105:** Not applicable for a library/dual-purpose function script of this nature.

**BCS0703:** No `die()` or messaging functions — but this script uses `printf` directly to stderr for errors and returns from a function. Given it's a library function, this is acceptable. Per BCS0405, unused messaging infrastructure should not be added.

**BCS0702 line 40:** `>&2 printf 'Illegal option %s\n' "${1@Q}"` — >&2 at beginning ✓.

**BCS0304:** Heredoc at lines 14-27 uses `<<'HELP'` (quoted delimiter) for literal content ✓.

**BCS0503 — for loop variable declarations:** Lines 53 and 74 use `for target in` and `for path in` — `target` and `path` are declared `local` at line 11, so they are properly scoped. ✓

**BCS0410:** The function is not recursive, so BCS0410 doesn't apply.

**BCS0201 line 11 detail:** `local target path full_path resolved` — four string variables without `--` type specifier. This is a style violation.

**BCS0306 line 40:** `"${1@Q}"` used correctly in error message ✓.

Now checking for anything I may have missed...

**BCS1202:** Comments at lines 38, 48, 55, 75, 100, 103, 105 — line 100 `# Export function to subshells` describes the next line `declare -fx which`. This is borderline but arguably just a section marker. Line 38 `# Split combined short options: -ac → -a -c` — adds information about what the pattern does (non-obvious). Line 48 explains POSIX semantics. Line 55 explains why the branch exists. These all add information not obvious from the code alone. Line 100 is the weakest case — `declare -fx which` is self-evident — but it's very brief and functions as a section divider, which is marginal at best.

**BCS0502:** No `*)` default case in the `case` statement... wait, line 41 `*) targets+=("$1") ;;` serves as the default for non-option arguments. And `-*) ... return 2 ;;` handles unknown options. ✓

**BCS0201 line 9:** `local -i allmatches=0 canonical=0 silent=0 allret=0 found=0` — integers properly declared ✓. Line 10: `local -a targets=() path_dirs=()` — arrays properly declared ✓.

**BCS1201 — line 50:** `[[ $_path != *: ]] || _path+=':'` — this logic seems inverted. If `$_path` ends with `:`, it appends another `:` making it `...::`? The comment says "trailing colon means current directory — guard for read -ra". Actually looking more carefully: `[[ $_path != *: ]] || _path+=':'` — if path DOES end with `:`, it adds another `:`. So `foo:` becomes `foo::`. This seems intentional to prevent `read -ra` from treating the trailing empty field as lost. This is a logic/algorithmic choice, not a BCS style matter — I won't flag it as it's domain logic.

**BCS0201 line 11:** The `local` declaration without `--` is a genuine style finding.

**BCS1202 line 100:** `# Export function to subshells` — paraphrases `declare -fx which`. Marginal but technically a violation.

Let me consolidate findings:

---

**[WARN] BCS0201 line 11:** `local target path full_path resolved` declares four string variables without the `--` type specifier. BCS0201 requires explicit type declarations for all variables.

**Fix:** `local -- target path full_path resolved` — or split into separate declarations for clarity.

---

**[WARN] BCS1202 line 100:** `# Export function to subshells` paraphrases the immediately following `declare -fx which`. A competent reader can see the export without the comment.

**Fix:** Remove the comment, or replace with a non-obvious note (e.g., explaining *why* the function is exported to subshells if there's a non-obvious reason).

---

Those are the only genuine findings. Everything else holds up well.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0201 | style | [WARN] | 11 | `local target path full_path resolved` — string variables declared without `--` type specifier |
| BCS1202 | style | [WARN] | 100 | Comment `# Export function to subshells` paraphrases the adjacent `declare -fx which` without adding information |
bcs: ◉ Tokens: in=28687 out=2131
bcs: ◉ Elapsed: 40s
