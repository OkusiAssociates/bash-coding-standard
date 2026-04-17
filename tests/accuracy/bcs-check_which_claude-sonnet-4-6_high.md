bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
I'll analyze this script systematically against the BCS rules.

---

**Structural overview:** This is a dual-purpose script (sourceable function + direct execution). The `which()` function is defined, exported, then a source fence separates library from script mode. The overall structure is sound; I'll check each applicable rule carefully.

---

## Findings

**[WARN] BCS0102 line 1:** The shebang is present and correct (`#!/usr/bin/bash`). However, this is a dual-purpose script where the shebang only applies during direct execution. No violation here — this is acceptable.
*(Retracted — passes.)*

**[WARN] BCS0103 line 1–111:** No `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, or `SCRIPT_NAME` metadata variables are declared. For a dual-purpose script this is a style judgment; the function embeds its version string directly (`which 2.0`). However, BCS0103 is **recommended** tier — worth noting the absence, but the script's use-pattern (it *is* the `which` command, replacing a system utility) makes `SCRIPT_NAME`/`SCRIPT_DIR` less meaningful. This is a marginal call.
*(Retracted — BCS0103 itself says "Not all scripts will need all four." Given the script's nature as a function-first utility, omission is defensible. Omitting.)*

---

**[ERROR] BCS0101 line 106:** `set -euo pipefail` appears inside the source-fence block, not as the first executable line after the shebang. BCS0101 states it must be the first executable command. In a dual-purpose script, BCS0106 explicitly documents that strict mode lives *below* the fence — so this placement is **correct by design**. No violation.
*(Retracted — BCS0106 explicitly permits this pattern.)*

---

**[WARN] BCS0201 line 11:** `local target path full_path resolved` declares four string variables without the `--` type separator. BCS0201 requires explicit type declarations (`local -- varname`).

**Fix:** Change to:
```bash
local -- target='' path='' full_path='' resolved=''
```

---

**[WARN] BCS0201 line 49:** `local _path=${PATH:-}` declares a string variable without the `--` type separator.

**Fix:**
```bash
local -- _path=${PATH:-}
```

---

**[WARN] BCS0203 line 49:** The variable `_path` uses an underscore prefix, which BCS0203 reserves for *private functions*, not variables. Variable names should use plain `lower_case`. The underscore prefix convention applies to function names only.

**Fix:** Rename to `path_raw` or `raw_path`:
```bash
local -- path_raw=${PATH:-}
```

---

**[WARN] BCS0301 line 35:** `printf 'which 2.0\n'` — this is correct (static string, single quotes). No violation.
*(Retracted — passes.)*

**[WARN] BCS0301 line 35:** Version output uses `printf 'which 2.0\n'` directly rather than a variable. BCS0802 specifies the format `scriptname X.Y.Z` via `echo "$SCRIPT_NAME $VERSION"`, but the script legitimately lacks `SCRIPT_NAME`/`VERSION` globals since it's function-first. The version string itself matches the format. This is a **recommended** tier concern only — marginal.
*(Retracted — no clear violation without the global variables.)*

---

**[WARN] BCS0203 line 13:** `_which_help` uses an underscore prefix (private function convention) and is a nested function inside `which()`. BCS0203 says underscore prefix is for private functions — this usage is actually *correct* by convention. No violation.
*(Retracted — passes.)*

---

**[ERROR] BCS0606 line 60:** `((silent)) || printf '%s\n' "$resolved"` — inverted form, no issue. Passes.

**[ERROR] BCS0606 line 70:** `((found)) || allret=1` — inverted form. Passes.

**[ERROR] BCS0606 line 91:** `((allmatches)) || break` — inverted form. Passes.

**[ERROR] BCS0606 line 95:** `((found)) || allret=1` — inverted form. Passes.

---

**[WARN] BCS1003 line 51:** `IFS=':' read -ra path_dirs <<< "$_path"` — this uses the inline `IFS=value command` form, which BCS1003's compliance note explicitly states is already scoped to the single command and is **not** a violation. Passes.

---

**[WARN] BCS0503 line 30:** The `while (($#))` loop correctly uses `shift` at line 43 as the loop-end mandatory shift, with `continue` on line 39 for the disaggregation case. No missing-shift issue. Passes.

---

**[WARN] BCS0801 line 39:** Option bundling pattern `-[acsVh]?*` — checks out. The listed characters match all defined short options (`-a`, `-c`, `-s`, `-V`, `-h`). No arg-taking options exist in this function, so no bundling hazard. Passes.

---

**[WARN] BCS0704 line 13–28:** The help text is inside a nested function `_which_help()` using a heredoc with quoted delimiter `<<'HELP'`. This is correct — no variable expansion needed in help text. The function is called at line 36. Passes.

---

**[WARN] BCS0702 line 40:** Error output uses `>&2 printf ...` with `>&2` at the **beginning** — correct per BCS0702. Passes.

Line 63 and 85: `((silent)) || >&2 printf ...` — `>&2` at beginning. Passes.

---

**[WARN] BCS0603 line 106–109:** The script mode block (below the fence) runs `which "$@"` with no cleanup trap. However, this is a pass-through wrapper — the function itself creates no temporary resources, so a cleanup trap is unnecessary. BCS0603 says "scripts requiring cleanup" must define traps. No violation.

---

**[WARN] BCS1202 line 38:** `# Split combined short options: -ac → -a -c` — this comment explains a non-obvious mechanism (disaggregation pattern). It adds information not immediately recoverable from the code alone. Passes.

Line 48: `# POSIX: trailing colon means current directory — guard for read -ra` — adds context (POSIX spec reference, guards against a real edge case). Passes.

Line 55: `# Paths containing / bypass PATH search` — adds semantic intent. Passes.

Line 75: `# POSIX: empty PATH element means current directory` — POSIX reference, adds information. Passes.

Line 100: `# Export function to subshells` — this paraphrases the next line (`declare -fx which`). The comment adds no information beyond what `declare -fx` already conveys.

**[WARN] BCS1202 line 100:** Comment `# Export function to subshells` mechanically paraphrases `declare -fx which`. No information is added that a competent reader cannot recover from the code. This is a violating comment per BCS1202.

**Fix:** Remove the comment, or replace with something non-obvious if there's a reason (there isn't here).

---

**[WARN] BCS0103 / BCS0105:** No global `declare -i` or `declare --` block exists at script level (all declarations are inside the function, which is correct for a function-first library). No global state variables are needed. No violation.

---

**[WARN] BCS0109 line 111:** Script ends with `#end` — BCS0109 explicitly allows either `#fin` or `#end`. Passes.

---

**[WARN] BCS1213 (non-issue):** No date/time operations. N/A.

---

## Summary

Two genuine findings after full analysis:

**[WARN] BCS0201 line 11:** `local target path full_path resolved` — string variables declared without `--` type separator.

**Fix:**
```bash
local -- target='' path='' full_path='' resolved=''
```

---

**[WARN] BCS0201 line 49:** `local _path=${PATH:-}` — string variable declared without `--` type separator.

**Fix:**
```bash
local -- _path=${PATH:-}
```

---

**[WARN] BCS0203 line 49:** Variable `_path` uses underscore prefix, which BCS0203 reserves for private *functions*, not variables.

**Fix:** Rename to `path_raw` or similar:
```bash
local -- path_raw=${PATH:-}
[[ $path_raw != *: ]] || path_raw+=':'
IFS=':' read -ra path_dirs <<< "$path_raw"
```

---

**[WARN] BCS1202 line 100:** Comment `# Export function to subshells` is a paraphrase violation — it restates what `declare -fx which` already clearly expresses.

**Fix:** Remove the comment entirely.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0201 | style | [WARN] | 11 | Four `local` string variables declared without `--` type separator |
| BCS0201 | style | [WARN] | 49 | `local _path` declared without `--` type separator |
| BCS0203 | style | [WARN] | 49 | Variable `_path` uses underscore prefix reserved for private functions |
| BCS1202 | style | [WARN] | 100 | Comment paraphrases `declare -fx which`; adds no information |
bcs: ◉ Tokens: in=28691 out=2444
bcs: ◉ Elapsed: 48s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
