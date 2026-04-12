bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS...
bcs: ◉ bcs check --backend 'claude' --model 'fast' --effort 'low' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
## BCS Compliance Analysis Report

I've completed a comprehensive audit of `/ai/scripts/Markdown/md2ansi.bash/md2ansi` against the Bash Coding Standard. Here are the findings:

---

### VIOLATIONS (3)

| BCS Code | Lines | Issue | Fix |
|----------|-------|-------|-----|
| **BCS0803** | 164–169, 1264 | `noarg()` function signature incorrect. Currently uses `(($# < 2))` with exit code 8, should use `(($# > 1))` with exit code 22 per standard | Replace with canonical BCS0803 implementation: `noarg() { (($# > 1)) \|\| die 22 "Option ${1@Q} requires an argument"; }` |
| **BCS1201** | 237, 291, 315, 497, 608, 626, 644 | 7 lines exceed 120-character limit (range: 121–148 chars). Affects declare statements and sed expressions with embedded ANSI codes | Break lines using backslash continuation; separate long declare statements across multiple lines with proper indentation |
| **BCS0805** | 1314–1317 | Short option bundling pattern `-[wDVht]?*` incorrect: pattern includes non-argument-taking options (`-D`, `-V`, `-h`, `-t`) alongside argument-taking option (`-w`). BCS0805 requires correct option categorization | Change pattern to `-[w]?*` (only options that take arguments) or handle separately |

---

### WARNINGS (5)

| BCS Code | Lines | Issue | Recommendation |
|----------|-------|-------|---|
| **BCS0202** | 1260–1329 | Function parameter validation in `parse_arguments()` relies on full `"$@"` but could fail silently if signature changes | Document contract clearly; ensure `noarg` always called with full `"$@"` before `shift` |
| **BCS1202** | 12, 72, 236, 248 | Inline `#bcscheck` and `#shellcheck` directives lack explanatory comments. BCS1202 requires comments explain WHY, not WHAT | Add comments: `# BCS0103: SCRIPT_NAME is not a file path, so realpath not needed` |
| **BCS0105** | 180–187 | Global `HAS_COLOR` declared conditionally inside if-block and later set readonly. BCS0105 requires all globals declared upfront with explicit types | Declare `HAS_COLOR` once at top (with `-i`); set conditionally in if-block; make readonly after |
| **BCS0305** | 282–319, 608, 626, 644, 1397 | Excessive `sed` chaining (11+ sequential calls) in `colorize_line()`. While not a violation, BCS discourages external commands over parameter expansion | No action needed unless performance impact observed; maintainability concern noted |
| **BCS0804** | 1259–1329 | Argument parsing in separate `parse_arguments()` function. For scripts >200 lines (this is 1426), BCS0804 requires parsing loop inside `main()` | **Note:** Line 1259 has `#bcscheck disable=BCS0804` suppression ✓ (honored) |

---

### Summary Table

| Severity | Count | By Category |
|----------|-------|---|
| **VIOLATIONS** | 3 | Option validation (1), Line length (1), Option bundling (1) |
| **WARNINGS** | 5 | Documentation (2), Structure (2), Performance (1) |
| **TOTAL** | **8** | 3 violations require fixing; 5 warnings should be addressed |

---

### Inline Suppressions Honored ✓

The script includes these valid suppressions that were respected:
- `#bcscheck disable=BCS0103` (line 12)
- `#bcscheck disable=BCS0703` (line 72)  
- `#bcscheck disable=BCS0804` (line 1259)
- `#shellcheck disable=SC2034` (line 236)
- `#shellcheck disable=SC2001` (line 248)

---

**★ Insight ─────────────────────────────────────**
The BCS standard enforces consistency patterns across enterprise bash scripts: proper option validation using canonical `noarg()`, strict line-length limits for readability, and argument parsing placement for maintainability. This script's violations are fixable (noarg signature, line breaks, bundling pattern), while warnings suggest structural improvements without blocking functionality.
`─────────────────────────────────────────────────`
bcs: ◉ Tokens: 
bcs: ◉ Elapsed: 856s
