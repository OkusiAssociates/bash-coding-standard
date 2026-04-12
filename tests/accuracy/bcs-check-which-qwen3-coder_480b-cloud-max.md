bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
Looking at this script, I need to perform an exhaustive line-by-line audit against the BCS rules.

## Analysis

**Script Structure**: This is a dual-purpose script (can be sourced or executed) that implements a `which` function.

**Key observations:**
- Lines 8-99: Function definition
- Lines 100-101: Export function (executed when sourced)
- Lines 103-109: Source fence with execution block
- Line 111: End marker `#end` ✓

**BCS0103 (Script Metadata)**: The script does not declare VERSION, SCRIPT_PATH, SCRIPT_DIR, or SCRIPT_NAME. While it prints "which 2.0" for --version, there's no VERSION variable. BCS0103 states "Not all scripts will require all Script Metadata variables" — this is a borderline case since the script does have version functionality.

**BCS0106 (Dual-Purpose Scripts)**: Uses `return 0 2>/dev/null || {` pattern correctly. Functions defined before fence, strict mode after.

**BCS0109 (End Marker)**: Line 111 has `#end` — correct.

**BCS0408 (Dependency Management)**: Uses `realpath` (coreutils) without checking. Per BCS0408, coreutils commands don't require checks — this is acceptable.

**BCS0606 (Conditional Declarations)**: Uses inverted `||` pattern throughout:
- Line 60, 66, 82, 88: `((silent)) || printf...` — correct inverted form
- Line 70, 95: `((found)) || allret=1` — correct inverted form
- Line 91: `((allmatches)) || break` — correct inverted form

All arithmetic conditions using inverted `||` are safe under `set -e` because the right-hand side always succeeds.

**BCS0802 (Version Output)**: Line 35 outputs `which 2.0` without the word "version" — correct.

**BCS0805 (Option Bundling)**: Line 39 correctly handles bundled options `-ac` → `-a -c`.

**BCS1003 (IFS Safety)**: Line 51 uses inline IFS modification (`IFS=':' read...`) which is scoped to that single command — acceptable per BCS guidance.

**BCS1206 (Static Analysis)**: Line 6 has valid shellcheck directive.

---

## Summary

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0103 | WARNING | — | No VERSION variable declared; script has --version but no metadata variable (borderline per "not all scripts require all variables") |
bcs: ◉ Tokens: in=20779 out=6910
bcs: ◉ Elapsed: 98s
