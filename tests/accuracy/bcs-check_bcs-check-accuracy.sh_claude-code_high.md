bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
`★ Insight ─────────────────────────────────────`
BCS0801 (core) mandates `while (($#)); do case $1 in` for ALL argument parsing — even for 2-option scripts. The while/case pattern handles edge cases (multiple args, bundling, `--` terminator) that if/elif cannot. A violation here is [ERROR] regardless of script simplicity.
`─────────────────────────────────────────────────`

Here is the full compliance report for `bcs-check-accuracy.sh`:

---

## BCS Compliance Report — `bcs-check-accuracy.sh`

---

### Finding 1 — BCS0801 [ERROR] Core: Non-standard argument parsing pattern

**Lines 35–63**

```bash
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
```

**Problem:** BCS0801 mandates the `while (($#)); do case $1 in ... esac; shift; done` pattern for all argument parsing. Using nested `if/elif` blocks violates this core rule regardless of how few options the script accepts.

**Fix:**
```bash
while (($#)); do case $1 in
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  -[Vh]?*)      set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid argument ${1@Q}" ;;
esac; shift; done
```

---

### Finding 2 — BCS0602 [WARN] Recommended: Wrong exit code and no `die()` function

**Lines 59–60**

```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"
exit 1
```

**Problem (two issues):**
1. Exit code `1` (general error) is used for an invalid argument. BCS0602 specifies exit code **22** for invalid arguments.
2. The `die()` function is the BCS standard exit function; `exit` should not be called directly for error paths.

**Fix:**
```bash
die() { (($# < 2)) || >&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "${*:2}"; exit "${1:-0}"; }
# ...
die 22 "Invalid argument ${1@Q}"
```

---

### Finding 3 — BCS0502 [WARN] Recommended: `if/elif` instead of `case` for multi-way branch

**Lines 36–62**

```bash
if [[ $1 == @(-V|--version) ]]; then
  ...
elif [[ $1 == @(-h|--help) ]]; then
  ...
else
  ...
fi
```

**Problem:** BCS0502 requires `case` for multi-way branching on a single variable. The nested `if/elif` pattern is also suboptimal because `case` supports the same `@()` extglob patterns (e.g., `@(-V|--version)`). This is additionally subsumed by the BCS0801 violation.

---

### Finding 4 — BCS0703 [WARN] Style: No messaging functions; raw `>&2 echo`/`>&2 printf`

**Lines 59, 83, 85**

```bash
>&2 printf '%s: ✗ %s\n' "$SCRIPT_NAME" "Invalid argument ${1@Q}"  # line 59
>&2 echo "bcs check --model $model --effort $effort ..."           # line 83
>&2 echo "    ${output_to@Q} already exists; skipping"             # line 85
```

**Problem:** The script performs both error output (line 59) and informational output (lines 83, 85) but implements no messaging functions. BCS0703 requires `_msg()` as the core dispatcher, with derived functions (`error()`, `info()`) for the output types actually used. Per BCS0405, only functions that are called need to be included — but those that *are* called should use the standard interface.

**Fix:** Implement at minimum:
```bash
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  case ${FUNCNAME[1]} in
    info)  prefix+=" $CYAN◉$NC" ;;
    error) prefix+=" $RED✗$NC" ;;
    *)     ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
info()  { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die()   { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
```

`★ Insight ─────────────────────────────────────`
BCS0703 and BCS0405 appear to be in tension, but they resolve cleanly: BCS0405 says *omit* unused functions; BCS0703 says *implement* the ones you do use. A script with error output that bypasses `error()` violates 0703 — it's not a case of "unused function."
`─────────────────────────────────────────────────`

---

### Finding 5 — BCS0203 [WARN] Style: Lowercase names for global-scope state variables

**Lines 12, 32, 67, 69**

```bash
declare -- script scriptname scriptdir        # line 12
declare -- model effort modelname             # line 32
declare -- output_to                          # line 67
declare -i start_time=$EPOCHSECONDS           # line 69
```

**Problem:** BCS0203 requires UPPER\_CASE for all global-scope state variables. These are declared at global scope (not inside any function) and are used throughout the main body. Lowercase naming is reserved for `local` variables inside functions.

**Fix:** Rename to `SCRIPT`, `SCRIPTNAME`, `SCRIPTDIR`, `MODEL`, `EFFORT`, `MODELNAME`, `OUTPUT_TO`, `START_TIME` (and update all references consistently).

> Note: `SCRIPTNAME`/`SCRIPTDIR` would shadow the pattern of `SCRIPT_NAME`/`SCRIPT_DIR`. Choose distinct names like `CUR_SCRIPT`, `CUR_SCRIPTNAME` etc. to avoid confusion with the metadata variables.

---

### Finding 6 — BCS0408 [WARN] Recommended: `bcs` dependency not verified before use

**Line 89**

```bash
bcs check --model "$model" --effort "$effort" "$script" &>"$output_to" ||:
```

**Problem:** `bcs` is a non-standard, separately-packaged tool. BCS0408 requires non-standard tools to be verified with `command -v` before use. Without this check, a missing `bcs` command will silently produce empty output files (the `||:` suppresses the `127 not found` exit code).

**Fix:** Add before the loop:
```bash
command -v bcs >/dev/null || die 18 'bcs required but not found'
```

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0801 | core | [ERROR] | 35–63 | `if/elif` used instead of mandatory `while (($#)); do case $1 in` parsing pattern |
| BCS0602 | recommended | [WARN] | 59–60 | Exit code `1` for invalid argument (should be `22`); no `die()` function implemented |
| BCS0502 | recommended | [WARN] | 36–62 | Multi-way branch on `$1` uses `if/elif` instead of `case` |
| BCS0703 | style | [WARN] | 59, 83, 85 | Error/info messaging bypasses `_msg()`/`error()`/`info()` functions; uses raw `>&2` directly |
| BCS0203 | style | [WARN] | 12, 32, 67, 69 | Global-scope variables `script`, `scriptname`, `scriptdir`, `model`, `effort`, `modelname`, `output_to`, `start_time` use lowercase (should be UPPER_CASE) |
| BCS0408 | recommended | [WARN] | 89 | `bcs` (non-standard tool) invoked without prior `command -v` dependency check |

**1 ERROR, 5 WARNINGs.** The script is otherwise structurally sound: strict mode, metadata, `#fin`, `@Q` quoting, `>&2` placement, `&>` combined redirection, `realpath`, and array handling all comply.
bcs: ◉ Elapsed: 261s
bcs: ◉ Exit: 1
