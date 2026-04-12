bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS...
bcs: ◉ bcs check --backend 'claude' --model 'balanced' --effort 'low' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
I now have sufficient information for a comprehensive audit. Here is the full report:

---

## BCS Compliance Audit: `md2ansi`

### Suppressions Honoured

| Line | Directive | Scope |
|------|-----------|-------|
| 12 | `#bcscheck disable=BCS0103` | Line 13 — `${0##*/}` instead of `realpath` |
| 72 | `#bcscheck disable=BCS0703` | `debug()` function body — non-standard counter pattern |
| 1259 | `#bcscheck disable=BCS0804` | `parse_arguments()` extracted from `main()` |

---

### Finding 1 — BCS0706 · VIOLATION · Lines 44–48 and 191–238

**Rule:** *"Never scatter inline color declarations across scripts. Centralize in a single declaration block."*

The script has **two** separate color conditional blocks:

**Block 1 (lines 44–48)** — messaging colours only, gated on `[[ -t 1 && -t 2 ]]`:
```bash
if [[ -t 1 && -t 2 ]]; then
  declare -r NC=$'\033[0m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m'
else
  declare -r NC='' RED='' YELLOW=''
fi
```

**Block 2 (lines 191–238)** — full ANSI rendering set, gated on `((HAS_COLOR))`:
```bash
if ((HAS_COLOR)); then
  declare -r ANSI_RESET=... COLOR_H1=... ...
else
  declare -r ANSI_RESET='' ...
fi
```

**Fix:** Merge into a single conditional block. Since `HAS_COLOR` is derived from a broader test that subsumes the TTY check, both sets can be unified under one guard:

```bash
if [[ -t 1 && -t 2 ]] && ((HAS_COLOR)); then
  declare -r NC=$'\033[0m' RED=$'\033[0;31m' YELLOW=$'\033[0;33m' \
             ANSI_RESET=$'\033[0m' ...
else
  declare -r NC='' RED='' YELLOW='' ANSI_RESET='' ...
fi
```

---

### Finding 2 — BCS0501 · VIOLATION · Line 557

**Rule:** *Avoid explicit `== 0` / `== 1` comparisons in arithmetic context — use truthiness directly.*

```bash
# line 557 — current (wrong)
if ((OPTIONS[syntax_highlight] == 0)) || [[ -z $lang ]]; then
```

BCS0501 explicitly marks `((VERBOSE == 1))` and `((count > 0))` as wrong. The `== 0` form is the same anti-pattern.

**Fix:**
```bash
if ((!OPTIONS[syntax_highlight])) || [[ -z $lang ]]; then
```

---

### Finding 3 — BCS0107 · WARNING · Line 1202

**Rule:** Organize functions bottom-up in 7 layers: messaging → **documentation** → helper → validation → business logic → orchestration → `main()`.

`usage()` (the documentation/help function) is defined at line 1202 — well after all the rendering and parsing functions (business logic). Per BCS0107, it belongs near the top, directly after the messaging cluster (`_msg`, `warn`, `error`, `die`, `debug`).

**Fix:** Move `usage()` to immediately after `noarg()` (line 169), before `get_terminal_width()`.

---

### Summary Table

| # | BCS Code | Severity | Lines | Issue |
|---|----------|----------|-------|-------|
| 1 | BCS0706 | **VIOLATION** | 44–48, 191–238 | Two scattered color declaration blocks; must be merged into one |
| 2 | BCS0501 | **VIOLATION** | 557 | `((OPTIONS[syntax_highlight] == 0))` — use `((!OPTIONS[syntax_highlight]))` |
| 3 | BCS0107 | WARNING | 1202 | `usage()` defined in wrong layer order (after business logic) |
| — | BCS0103 | suppressed | 13 | `${0##*/}` without `realpath` |
| — | BCS0703 | suppressed | 73–80 | Non-standard `debug()` with counter |
| — | BCS0804 | suppressed | 1260 | `parse_arguments()` extracted from `main()` |

**Violations: 2 · Warnings: 1 · Suppressions: 3**

---

`★ Insight ─────────────────────────────────────`
The BCS0501 `== 0` check is subtle — the script still works correctly, but the standard mandates using `((!var))` for "is-zero" tests to keep arithmetic idioms consistent with the `((flag))` truthiness pattern used everywhere else in the file. The BCS0706 split is architecturally motivated (messaging colors vs. rendering colors have different TTY requirements), but the standard gives no exception for this — the correct fix is a unified guard that satisfies both conditions.
`─────────────────────────────────────────────────`
bcs: ◉ Tokens: 
bcs: ◉ Elapsed: 382s
