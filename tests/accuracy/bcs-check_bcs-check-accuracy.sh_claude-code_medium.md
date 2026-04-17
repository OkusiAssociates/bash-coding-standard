bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
`★ Insight ─────────────────────────────────────`
BCS compliance analysis works section-by-section: structure/metadata first, then argument parsing (a common source of core violations), then variable naming and layout. Many scripts pass the "obvious" rules but fail on the standard arg-parsing pattern (BCS0801) and global variable naming (BCS0203).
`─────────────────────────────────────────────────`

---

## BCS Compliance Report: `bcs-check-accuracy.sh`

---

### [ERROR] BCS0801 — Standard Parsing Pattern (core) — Lines 34–61

**What's wrong:** Argument handling uses a non-standard `if (($#)); then if [[ ... ]] / elif / else` structure instead of the mandatory `while (($#)); do case $1 in ... esac; shift; done` pattern.

Current code:
```bash
if (($#)); then
  if [[ $1 == @(-V|--version) ]]; then
    printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
  elif [[ $1 == @(-h|--help) ]]; then
    cat <<HELP
...
HELP
  else
    >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
    exit 1
  fi
  exit 0
fi
```

**Fix:** Rewrite with the standard pattern:
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -*)           die 22 "Invalid argument ${1@Q}" ;;
esac; shift; done
```

---

### [WARN] BCS0602 — Exit Codes (recommended) — Lines 58–59

**What's wrong:** Invalid argument condition uses a bare `>&2 printf` + `exit 1` instead of the standard `die()` function, and uses exit code 1 (General error) rather than 22 (Invalid argument).

Current code:
```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
exit 1
```

**Fix:** Define and use `die()`:
```bash
die() { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
# then in argument handling:
die 22 "Invalid argument ${1@Q}"
```

---

### [WARN] BCS0203 — Naming Conventions (style) — Lines 12, 32, 66, 68

**What's wrong:** Eight global variables use `lower_case` names. Per BCS0203, global state must be `UPPER_CASE`.

| Line | Variable | Should be |
|------|----------|-----------|
| 12 | `script` | `SCRIPT` |
| 12 | `scriptname` | `SCRIPTNAME` |
| 12 | `scriptdir` | `SCRIPTDIR` |
| 32 | `model` | `MODEL` |
| 32 | `effort` | `EFFORT` |
| 32 | `modelname` | `MODELNAME` |
| 66 | `output_to` | `OUTPUT_TO` |
| 68 | `start_time` | `START_TIME` |

**Fix:** Rename all eight globals and update all their references throughout the script.

---

### [WARN] BCS0105 — Global Variables Up Front (recommended) — Lines 66, 68

**What's wrong:** `output_to` (line 66) and `start_time` (line 68) are declared after the argument-handling block (lines 34–62) and a `cd` call (line 64). BCS0105 requires all globals declared up front with explicit types.

Current code (out of place):
```bash
cd "$SCRIPT_DIR" # anchor to script's dir path

declare -- output_to           # line 66 — should be with globals above

declare -i start_time=$EPOCHSECONDS  # line 68 — same
```

**Fix:** Move both declarations into the global variable section (after line 12):
```bash
declare -- script scriptname scriptdir
declare -- output_to                    # ← move here
declare -i start_time                   # ← move here (assign later in script body)
```

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0801 | core | [ERROR] | 34–61 | Non-standard argument parsing; must use `while (($#)); do case $1 in … esac; shift; done` |
| BCS0602 | recommended | [WARN] | 58–59 | Invalid arg error uses `exit 1` instead of `die 22`; no `die()` defined |
| BCS0203 | style | [WARN] | 12, 32, 66, 68 | 8 global variables use `lowercase` names; must be `UPPER_CASE` |
| BCS0105 | recommended | [WARN] | 66, 68 | `output_to` and `start_time` declared mid-script; must be up front with other globals |

`★ Insight ─────────────────────────────────────`
The script's core logic is solid — strict mode, `inherit_errexit`, `realpath` metadata, `#fin` marker, `||:` on the potentially-failing `bcs check` call, and `&>` combined redirection all comply cleanly. The violations cluster in argument handling (BCS0801 is the only ERROR) and naming hygiene. Fixing BCS0801 subsumes the BCS0602 fix naturally, since the standard `case` pattern puts `die 22` directly in the `-*)` branch.
`─────────────────────────────────────────────────`
bcs: ◉ Elapsed: 142s
bcs: ◉ Exit: 1
