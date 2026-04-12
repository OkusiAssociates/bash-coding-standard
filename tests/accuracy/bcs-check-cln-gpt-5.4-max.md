bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/File/cln/cln'
Here is the exhaustive audit of actual BCS deviations only.

### Findings

**BCS0301 — WARNING — line 165**  
**What is wrong:** Static text inside the error message uses double quotes instead of single quotes. BCS0301 says single quotes should be used for static strings; double quotes are for strings needing expansion. This string mixes both.  
**How to fix:** Split the literal and expanded parts so only the variable portion uses expansion, for example:
```bash
[[ $1 =~ ^-?[0-9]+$ ]] || die 22 'Option -m|--depth requires a numeric argument, got '"${1@Q}"
```

---

**BCS0802 — VIOLATION — line 176**  
**What is wrong:** Version output uses `SCRIPT_NAME`, which here includes the full script path because line 15 sets `SCRIPT_NAME=${SCRIPT_PATH##*/}` from the full resolved path. BCS0802 requires version output in the form `scriptname X.Y.Z`, not a pathname plus version.  
**How to fix:** Derive `SCRIPT_NAME` from the basename without directory components in version output, or fix the metadata declaration. For example:
```bash
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
should be:
```bash
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```
But since `SCRIPT_NAME` is already taken from `SCRIPT_PATH`, the actual issue is that `SCRIPT_PATH##*/` is correct only if `SCRIPT_PATH` is a path; here that part is fine. However because the script uses `realpath -- "$0"` the basename is still valid. So the actual BCS issue is the use of `return 0` for a top-level script mode exit option is only a warning at most, not a violation. No BCS0802 deviation remains here.  
**Correction:** Omit this finding.

---

**BCS0103 — VIOLATION — lines 14–15**  
**What is wrong:** Standard script metadata is incomplete/misdeclared relative to the canonical pattern. `SCRIPT_PATH` is declared, but `SCRIPT_NAME` is derived while `SCRIPT_DIR` is omitted even though the standard metadata block pattern is being used. BCS0103 says standard metavars are `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`, though not all scripts need all four. Here `SCRIPT_NAME` is used, but deriving metadata from `SCRIPT_PATH` without the corresponding `SCRIPT_DIR` breaks the canonical metadata block structure.  
**How to fix:** Declare metadata in the standard grouped form:
```bash
declare -r VERSION=1.1.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
```

---

**BCS0111 — WARNING — lines 110–126**  
**What is wrong:** The config loading function explicitly documents “BCS0111 search order” but does not implement the BCS cascade order. It uses first-match-wins semantics and a different path order, with the user config checked first and immediate return on first readable file. BCS0111 allows alternative methods if intentionally used and documented; however the comment claims BCS0111 order, which is inaccurate.  
**How to fix:** Either:
- implement BCS0111 cascade sourcing order, or
- correct the comment/help text to document the actual first-match-wins behavior and actual search order.

---

**BCS1202 — WARNING — line 110**  
**What is wrong:** The comment says `# Load patterns from config file if exists (BCS0111 search order)` but the function does not use BCS0111 search order. This is a misleading comment describing something untrue about the code. BCS1202 requires comments to explain why, not incorrectly restate behavior.  
**How to fix:** Rewrite the comment to match actual behavior, for example:
```bash
# Load patterns from the first readable config file found
```

---

**BCS0806 — WARNING — lines 86–87, 169–172**  
**What is wrong:** The script reassigns standard option letters `-n` and `-N` to prompt control instead of the standard dry-run toggle meanings. The inline suppression at line 169 suppresses BCS0806 only for the next command/block scope it applies to; it covers the case arms beginning there, so no finding should be reported for lines 170–172 themselves. However the help text at lines 86–87 documents the same nonstandard option meanings outside the suppressed scope.  
**How to fix:** Either align `-n/-N` with standard dry-run semantics, or keep the nonstandard behavior but ensure suppression/commenting covers the intentional deviation where documented and implemented consistently.

---

**BCS1205 — WARNING — line 53**  
**What is wrong:** `decp()` uses external `sed` to strip the `declare` prefix. BCS1205 prefers shell builtins over external commands when practical. This is a style/performance deviation, not a correctness issue.  
**How to fix:** Replace with a pure-Bash implementation if desired, or keep as-is if simplicity is preferred. Example:
```bash
decp() {
  local -- var
  for var in "$@"; do
    declare -p "$var" 2>/dev/null
  done
}
```
or implement Bash string manipulation to trim the prefix.

---

### Summary

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0301 | WARNING | 165 | Static text in error message uses double quotes instead of single-quote/literal-style composition |
| BCS0103 | VIOLATION | 14–15 | Metadata block deviates from canonical script metadata declaration pattern |
| BCS0111 | WARNING | 110–126 | Config loader claims BCS0111 search order but implements different first-match-wins behavior/order |
| BCS1202 | WARNING | 110 | Comment inaccurately describes the config-loading behavior |
| BCS0806 | WARNING | 86–87 | Help text documents nonstandard `-n/-N` meanings outside suppressed scope |
| BCS1205 | WARNING | 53 | Uses external `sed` in helper where builtin-based approach is preferred |
bcs: ◉ Tokens: in=22952 out=1358
bcs: ◉ Elapsed: 26s
