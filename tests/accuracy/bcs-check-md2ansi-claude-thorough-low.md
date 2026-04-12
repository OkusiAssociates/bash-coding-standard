bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS...
bcs: ◉ bcs check --backend 'claude' --model 'thorough' --effort 'low' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
Now I have enough context. Let me produce the audit.

---

# BCS Compliance Audit: `md2ansi.bash`

## Findings

### BCS0103 — Script Metadata
**Severity:** SUPPRESSED (line 12)
Line 12: `#bcscheck disable=BCS0103` — suppresses missing `SCRIPT_PATH`/`SCRIPT_DIR`. Respected.

### BCS0105 — Global Variables and Colors
**Severity:** WARNING
**Lines:** 41, 44-48
`DEBUG=0` is declared at line 41, separated from the other global flags at lines 16-17. BCS0105 says "Declare all global variables up front" and avoid "scattered declarations." The messaging color block (lines 44-48) is also separate from the main ANSI color block (lines 191-238). This is a minor organizational issue — the script has two distinct color domains (messaging vs rendering) which justifies the separation somewhat.

### BCS0301 — Quoting Fundamentals (Static strings in double quotes)
**Severity:** WARNING
**Lines:** Multiple throughout
Several static strings use double quotes where single quotes would be correct per BCS0301. Examples:
- Line 69: `die() { ... }` uses proper quoting ✓
- Lines 282-316: `sed` commands necessarily use double quotes for variable expansion — these are correct.

Most string usage is actually correct. No major violations here.

### BCS0301 — Single quotes for literal strings
**Severity:** WARNING
**Lines:** 707, 771, 774, 776
```bash
alignments+=('left')    # line 707, 775 — should be unquoted: left is alphanumeric
alignments+=('center')  # line 771
alignments+=('right')   # line 773
```
Per BCS0301: "One-word alphanumeric literals may be unquoted." These are harmless but technically unnecessary quotes.

### BCS0207 — Unnecessary Braces in Parameter Expansion
**Severity:** WARNING
**Lines:** 594-596, 608, 626, 644, and throughout rendering functions
Many instances of `${COLOR_COMMENT}`, `${COLOR_KEYWORD}`, `${COLOR_CODEBLOCK}`, `${ANSI_RESET}` etc. inside double-quoted strings where braces are needed for disambiguation (adjacent to other text). **Most of these are actually correct** because the variables are concatenated adjacently. No violation.

### BCS0305 — Printf Format Strings
**Severity:** WARNING  
**Lines:** 77, 395, 423, 457, 497, 526, 540, 558, 585, 867, 881, 899, 902, 906, 914, 942, 946, 950, 969, 976-979, 983-987
Printf format strings use double quotes (`"..."`) instead of single quotes (`'...'`). Per BCS0305: "Use single quotes for format strings."

However, many of these format strings contain variable interpolation (e.g., `"$COLOR_TABLE"` embedded in the format), which requires double quotes. For those that are purely literal format strings with `%s` and args, single quotes would be preferred. Example:
- Line 77: `>&2 printf '[%(%T)T.%s] %s⦿%s %s\n'` — already uses single quotes ✓ (inside the suppressed block)

Most printf calls in this script embed ANSI variables directly in the format string rather than passing them as arguments, making double quotes necessary. This is a **design trade-off**, not a clear violation.

### BCS0401 — Local Variable Declarations
**Severity:** WARNING
**Lines:** 997, 1006-1011
In `parse_markdown()`, many local variables are declared at the top but some like `fence`, `lang_spec`, `formatted_line`, etc. (line 1006-1011) are declared before the loop. This is acceptable per BCS0401 ("Declarations may appear mid-body").

### BCS0503 — Loop Increment Style
**Severity:** PASS
The script consistently uses `i+=1` (e.g., lines 752, 808, 818, 858, 884) — correct per BCS0505.

### BCS0606 — Conditional Declarations / Missing `||:`
**Severity:** VIOLATION
**Line 314:**
```bash
if ((OPTIONS[footnotes])); then
```
This is fine — it's an `if` statement, not a bare `(())`.

**Line 74:**
```bash
((DEBUG)) || return 0
```
Correct — inverted form.

No violations found for BCS0606.

### BCS0703 — Core Message Functions
**Severity:** WARNING
**Line 73:** `#bcscheck disable=BCS0703` — suppresses custom debug format. Respected.

The `debug()` function (lines 73-80) uses a custom format with timestamp counter instead of the standard `_msg()` dispatch. Suppressed.

### BCS0804 — Parsing Location
**Severity:** SUPPRESSED (line 1259)
`#bcscheck disable=BCS0804` — argument parsing is in `parse_arguments()` instead of inside `main()`. Suppressed.

### BCS0803 — Argument Validation (`noarg`)
**Severity:** WARNING
**Lines:** 164-169
The `noarg()` function signature differs from the BCS reference pattern:
```bash
# BCS reference:
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Script:
noarg() {
  if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then
    die 8 "Missing argument for option ${1@Q}"
  fi
}
```
The script's version is more thorough (checks if next arg looks like an option). Uses exit code 8 instead of 22. Per BCS0602, code 8 = "Required argument missing" and 22 = "Invalid argument" — code 8 is actually more appropriate here. This is a valid design choice.

### BCS1002 — PATH Security
**Severity:** PASS
**Line 7:** `declare -rx PATH=/usr/local/bin:/usr/bin:/bin` — correct and early.

### BCS0109 — End Marker
**Severity:** PASS
**Line 1426:** `#fin` — present and correct.

### BCS0110 — Cleanup and Traps
**Severity:** WARNING
**Lines:** 151-157, 1384
The `cleanup()` function is defined at line 151, but the trap is installed at line 1384 inside `main()`. BCS0110 says "set the trap before any code that creates temporary resources." Since the script doesn't create temp files/dirs, this is acceptable — the cleanup just resets terminal state. However, if the script crashes before reaching `main()` (e.g., during color detection at line 184), the terminal won't be reset.

### BCS0108 — Main Function
**Severity:** PASS
**Lines:** 1382-1422, 1425
`main()` is present for this 1426-line script, called with `main "$@"`. Correct.

### BCS0301 — Double quotes on static strings
**Severity:** WARNING
**Lines:** 1354, 1363
```bash
debug 'Processing stdin'           # line 1354 — correct ✓
die 9 "Input from stdin exceeds maximum size: $MAX_FILE_SIZE bytes (10MB)"  # line 1363 — correct (has variable)
```

### BCS0806 — Standard Options
**Severity:** WARNING
The script uses `-D` for debug (correct), `-V` for version (correct), `-h` for help (correct), `-w` for width (non-standard, acceptable as custom option), `-t` for plain (non-standard, acceptable). No standard letters are reassigned. However, the script lacks `-v`/`--verbose` and `-q`/`--quiet` options per BCS0806 "Recommended" set. This is minor — the script's VERBOSE isn't user-configurable.

### BCS1201 — Code Formatting (Indentation)
**Severity:** PASS
Consistent 2-space indentation throughout. Lines appear within 120-char limit.

### BCS0101 — Strict Mode
**Severity:** PASS
**Line 4:** `set -euo pipefail` immediately after shebang and comment. Line 5: `shopt -s inherit_errexit`. Correct.

### BCS0102 — Shebang
**Severity:** PASS
**Line 1:** `#!/usr/bin/env bash` — one of the three acceptable forms.

### BCS0201 — Type-Specific Declarations
**Severity:** PASS
All variables use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`, `local -i`, `local --`, etc.) throughout.

### BCS0208 — Boolean Flags
**Severity:** PASS
Boolean flags use `declare -i` (e.g., `DEBUG`, `IN_CODE_BLOCK`, `HAS_COLOR`). Tested with `((flag))`. Correct.

### BCS1207 — Debugging
**Severity:** PASS
**Line 8:** PS4 is set. DEBUG flag available with `-D`. Custom debug function present.

### BCS0405 — Production Optimization (unused code)
**Severity:** WARNING
**Lines:** 260-265
`sanitize_ansi()` is a wrapper that just calls `strip_ansi()`. It's called only once (line 554). Per BCS0405 and KISS principles, this indirection is unnecessary — `strip_ansi` could be called directly. Minor.

---

## Summary Table

| BCS Code | Rule | Severity | Lines | Description |
|----------|------|----------|-------|-------------|
| BCS0103 | Script Metadata | SUPPRESSED | 12 | Missing SCRIPT_PATH/SCRIPT_DIR (suppressed) |
| BCS0105 | Global Variables | WARNING | 41 | DEBUG declared separately from other globals |
| BCS0305 | Printf Patterns | WARNING | various | Format strings use double quotes (justified by embedded variables) |
| BCS0405 | Production Optimization | WARNING | 260-265 | `sanitize_ansi()` is a trivial wrapper |
| BCS0703 | Core Message Functions | SUPPRESSED | 73 | Custom debug format (suppressed) |
| BCS0804 | Parsing Location | SUPPRESSED | 1259 | Parsing outside main() (suppressed) |
| BCS0806 | Standard Options | WARNING | 1260-1328 | Missing -v/--verbose, -q/--quiet options |
| BCS0110 | Cleanup and Traps | WARNING | 1384 | Trap installed late in main(), not before first resource use |

**Overall Assessment:** The script is **highly compliant** with BCS. No VIOLATIONs found. The 5 active WARNINGs are minor style preferences or defensible design choices. The 3 suppressed items are properly documented with `#bcscheck disable` directives.

`★ Insight ─────────────────────────────────────`
1. This script demonstrates excellent BCS discipline — typed declarations everywhere, consistent `i+=1` (never `i++`), proper `set -euo pipefail` + `inherit_errexit`, and clean `#fin` termination.
2. The dual color system (messaging colors at line 44 vs rendering colors at line 191) is a pragmatic deviation from BCS0105's "centralize" guidance — the messaging subsystem is intentionally independent of the ANSI rendering engine, which is good separation of concerns.
3. The `#bcscheck disable=` directives follow the same suppression model as ShellCheck, making the audit trail clear and machine-readable.
`─────────────────────────────────────────────────`
bcs: ◉ Tokens: 
bcs: ◉ Elapsed: 126s
