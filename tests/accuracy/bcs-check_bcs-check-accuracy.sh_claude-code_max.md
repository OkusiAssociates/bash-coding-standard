bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
Analyzing the script against BCS rules now.

`★ Insight ─────────────────────────────────────`
Compliance analysis examines structure (BCS01xx), variables (BCS02xx), I/O (BCS07xx), and argument parsing (BCS08xx) — the sections most scripts violate. Core-tier rules are language-correctness issues; style/recommended are convention issues.
`─────────────────────────────────────────────────`

---

## BCS Compliance Report: `bcs-check-accuracy.sh`

### PASS — Correct

- **BCS0101** Strict mode order (`set -euo pipefail` + `shopt -s inherit_errexit`) ✓
- **BCS0102** `#!/bin/bash` shebang (acceptable form) ✓
- **BCS0103** Metadata (`VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`) with `realpath` and `#shellcheck disable=SC2155` ✓
- **BCS0109** `#fin` end marker ✓
- **BCS0201** Explicit type declarations throughout ✓
- **BCS0206** Array expansions quoted with `"${array[@]}"` ✓
- **BCS0301** Single-quotes for static strings; double-quotes where expansion needed ✓
- **BCS0304** Unquoted heredoc delimiter (`<<HELP`) for variable expansion ✓
- **BCS0305** Single-quoted printf format strings ✓
- **BCS0306** `${1@Q}` used in error output ✓
- **BCS0606** `||:` on the `bcs check` command (expected failures correctly suppressed) ✓
- **BCS0702** All status messages go to stderr via `>&2`; elapsed time to stdout ✓
- **BCS0711** `&>` combined redirection ✓
- **BCS0802** Version output format `"$SCRIPT_NAME $VERSION"` ✓
- **BCS0806** `-V`/`--version` and `-h`/`--help` standard options present ✓

---

### FAIL — Findings

---

#### [ERROR] BCS0801 — Standard Argument Parsing Pattern *(Tier: core)*

**Lines 35–63**

The script uses `if (($#)); then if/elif` for argument parsing. BCS0801 requires the canonical `while (($#)); do case $1 in … esac; shift; done` pattern.

```bash
# current — non-standard
if (($#)); then
  if [[ $1 == @(-V|--version) ]]; then
    ...
  elif [[ $1 == @(-h|--help) ]]; then
    ...
  else
    >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
    exit 1
  fi
  exit 0
fi

# correct — BCS standard
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  *)            die 22 "Invalid argument ${1@Q}" ;;
esac; shift; done
```

---

#### [ERROR] BCS0604 — Unchecked Return Values on `cd` *(Tier: core)*

**Lines 65, 76**

Both `cd` calls lack explicit error handling. Under `set -e` the script will exit silently if `cd` fails — no diagnostic message is produced. Critical operations must use `|| die …` (or equivalent) to provide context on failure.

```bash
# current — line 65
cd "$SCRIPT_DIR" # anchor to script's dir path

# current — line 76
cd "$scriptdir"

# correct
cd "$SCRIPT_DIR" || { >&2 printf '%s: cannot cd to %s\n' "$SCRIPT_NAME" "${SCRIPT_DIR@Q}"; exit 1; }
cd "$scriptdir"  || { >&2 printf '%s: cannot cd to %s\n' "$SCRIPT_NAME" "${scriptdir@Q}"; exit 1; }
```

If `die()` were defined (see BCS0602 below), these become one-liners:
```bash
cd "$SCRIPT_DIR" || die 1 "Cannot cd to ${SCRIPT_DIR@Q}"
cd "$scriptdir"  || die 1 "Cannot cd to ${scriptdir@Q}"
```

---

#### [WARN] BCS0502 — `if/elif` Instead of `case` for Multi-Way Branch *(Tier: recommended)*

**Lines 36–62**

BCS0502 requires `case` for multi-way branching on a single variable. Lines 36–62 test `$1` across multiple conditions via `if/elif` — the exact pattern `case` is prescribed for. This finding is structurally linked to BCS0801; fixing the parsing loop resolves both.

---

#### [WARN] BCS0602 — No `die()` Function; Bare `exit 1` *(Tier: recommended)*

**Line 60**

BCS0602 designates `die()` as the standard exit function. The script uses `exit 1` directly after manually printing an error — exactly what `die()` encapsulates. Without `die()`, explicit `|| die …` error handling elsewhere (BCS0604 fix) cannot be done cleanly.

```bash
# add near the top (after metadata, before business logic)
die() { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
```

---

#### [WARN] BCS0105 — Globals Declared Mid-Script *(Tier: recommended)*

**Lines 67, 69**

`output_to` and `start_time` are declared after the argument-handling block (lines 65–63) and after `cd "$SCRIPT_DIR"`. BCS0105 requires all global variables to be declared up front with explicit types, alongside the other globals at the top.

```bash
# should appear with the other declare lines near the top (e.g., after line 33)
declare -- output_to
declare -i start_time
```

`start_time` is then assigned at first use:
```bash
start_time=$EPOCHSECONDS
```

---

#### [WARN] BCS0203 — Lowercase Global Variables *(Tier: style)*

**Lines 12, 33, 67, 69**

BCS0203 requires `UPPER_CASE` for global state. The following globals use lowercase:

| Line | Declaration | Should be |
|------|-------------|-----------|
| 12 | `declare -- script scriptname scriptdir` | `SCRIPT SCRIPTNAME SCRIPTDIR` |
| 33 | `declare -- model effort modelname` | `MODEL EFFORT MODELNAME` |
| 67 | `declare -- output_to` | `OUTPUT_TO` |
| 69 | `declare -i start_time` | `START_TIME` |

Note: `SCRIPT_DIR` and `SCRIPT_NAME` on line 9 are already correct. The loop control variables being pre-declared at global scope puts them under this rule.

---

#### [WARN] BCS0703 — No Structured Messaging Functions *(Tier: style)*

**Lines 59, 83, 85**

BCS0703 prescribes `_msg()` / `error()` / `info()` / `warn()` as the standard messaging layer. The script uses ad-hoc `>&2 echo` and `>&2 printf` for all status output. With `die()` added (see BCS0602), the remaining status lines should use `error()` or `info()`.

```bash
# current — line 59
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"

# correct (with messaging functions defined)
error "Invalid argument ${1@Q}"

# current — lines 83, 85
>&2 echo "bcs check ..."
>&2 echo "    ... already exists; skipping"

# correct
info "bcs check ..."
info "    ... already exists; skipping"
```

Per BCS0405, messaging functions should only be defined if used — adding `error()`/`info()` without using them would itself be a violation.

---

`★ Insight ─────────────────────────────────────`
BCS0801 (core) and BCS0502 (recommended) are coupled: switching to `while/case` automatically satisfies the case-for-multi-branch rule. BCS0602 and BCS0604 are similarly coupled: defining `die()` is the prerequisite to satisfying the "check all critical operations" rule cleanly.
`─────────────────────────────────────────────────`

---

### Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0801 | core | **[ERROR]** | 35–63 | `if/elif` used instead of `while (($#)); do case … esac; shift; done` |
| BCS0604 | core | **[ERROR]** | 65, 76 | `cd` operations lack explicit error handling / diagnostic message |
| BCS0502 | recommended | [WARN] | 36–62 | Multi-way branch on `$1` uses `if/elif` instead of `case` |
| BCS0602 | recommended | [WARN] | 60 | No `die()` function defined; bare `exit 1` used |
| BCS0105 | recommended | [WARN] | 67, 69 | `output_to`, `start_time` declared mid-script, not at global declaration block |
| BCS0203 | style | [WARN] | 12, 33, 67, 69 | Eight global variables use lowercase names (`script`, `model`, `output_to`, etc.) |
| BCS0703 | style | [WARN] | 59, 83, 85 | Status output via raw `>&2 echo`/`printf` instead of messaging functions |

**2 errors, 5 warnings.** The two errors (argument parsing structure and unchecked `cd`) are the priority fixes; the rest are convention alignment.
bcs: ◉ Elapsed: 295s
bcs: ◉ Exit: 1
