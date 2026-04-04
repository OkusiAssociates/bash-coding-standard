# AUDIT-BASH.md — BCS Compliance Audit

**Script:** `/ai/scripts/Okusi/BCS/bcs`
**Standard:** `/usr/local/share/yatti/BCS/data/BASH-CODING-STANDARD.md`
**Date:** 2026-04-04
**ShellCheck:** PASS (zero findings)
**Inline suppressions respected:** `#bcscheck disable=BCS0603` (line 474), `#bcscheck disable=BCS0806` (line 554)

---

## Findings

### F1 · BCS0606 · VIOLATION · Line 630

**Pattern:** `[[ -n ${1:-} ]] && { script_file=$1; shift; }` — missing `||:`

**Location:** `cmd_check()` — the `--` end-of-options handler

```bash
# current (line 630)
--)  shift; [[ -n ${1:-} ]] && { script_file=$1; shift; }; break ;;
```

**What is wrong:**
Under `set -e`, a `cmd1 && cmd2` expression that evaluates to false (because `cmd1` returns non-zero) is itself a command that exits non-zero. When `bcs check --` is run without a script argument after `--`, `shift` consumes `--`, `${1:-}` is empty, `[[ -n ]]` returns 1, and the `&&` expression evaluates to 1. Because this appears as a bare statement in the `case` body, `set -e` exits the script instead of reaching `break`.

**How to fix:**
```bash
--)  shift; [[ -n ${1:-} ]] && { script_file=$1; shift; } ||:; break ;;
```

Adding `||:` makes the overall expression always return 0, matching every other guarded action in the script.

---

### F2 · BCS0111 · WARNING · Lines 76–89

**Pattern:** `read_conf()` search path list is shorter than the BCS0111 canonical 6-path order.

**Location:** `read_conf()` function body

```bash
# current — 4 paths
local -a search_paths=(
  "${XDG_CONFIG_HOME:-$HOME/.config}"/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /etc/"$SCRIPT_NAME".conf
  /usr/local/etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
)
```

**What is wrong:**
BCS0111 specifies 6 paths. The two missing entries are:
- `/usr/share/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf` (package-provided defaults)
- `/usr/lib/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf` (library-provided defaults)

For a system-installed tool like `bcs`, omitting the `/usr/share/` path means a package maintainer cannot ship a default config alongside the binary.

**How to fix:**
```bash
local -a search_paths=(
  "${XDG_CONFIG_HOME:-$HOME/.config}"/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /etc/"$SCRIPT_NAME".conf
  /usr/local/etc/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /usr/share/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
  /usr/lib/"$SCRIPT_NAME"/"$SCRIPT_NAME".conf
)
```

---

### F3 · BCS0502 · WARNING · Lines 703–708

**Pattern:** `case $backend in` has no default `*)` case.

**Location:** `cmd_check()` — the backend dispatch block

```bash
case $backend in
  anthropic) result=$(_llm_anthropic ...) || exit_code=$? ;;
  google)    result=$(_llm_google    ...) || exit_code=$? ;;
  ollama)    result=$(_llm_ollama    ...) || exit_code=$? ;;
  openai)    result=$(_llm_openai    ...) || exit_code=$? ;;
esac
```

**What is wrong:**
BCS0502 states: "Always include default case `*)` to handle unexpected values." Although `$backend` is validated against `VALID_BACKENDS` at line 617 and resolved from `auto` at line 644, a defensive `*)` catch is still recommended for maintainability — future values could slip through if validation logic changes.

**How to fix:**
```bash
  *)         die 1 "Internal error: unhandled backend ${backend@Q}" ;;
esac
```

---

### F4 · BCS0108 · WARNING · Lines 852–896 (main)

**Pattern:** `VERBOSE` is not made `readonly` after argument parsing completes.

**Location:** `main()` — end of the `while` loop

**What is wrong:**
BCS0108 states: "Parse arguments within `main()`, then make configuration variables readonly after parsing." The `main()` loop parses `-v`/`-q` but never calls `readonly -- VERBOSE` once done.

**Mitigation — likely intentional:** Each subcommand (`cmd_check`, `cmd_template`, etc.) also accepts `-v`/`-q` and modifies `VERBOSE` directly. Making `VERBOSE` readonly in `main()` would silently break subcommand verbose control. This is architecturally correct for a multi-subcommand dispatcher but is a documented deviation from BCS0108.

**Advisory fix** (if subcommand local scoping is preferred over shared global):
Pass `VERBOSE` as a parameter or use a local override within each subcommand rather than relying on mutable global state.

---

### F5 · BCS0604 · WARNING · Line 477

**Pattern:** `cd "$check_dir"` return value unchecked.

**Location:** `_llm_claude_cli()`

```bash
check_dir=$(mktemp -d -t 'bcs-XXXXX') || die 1 'Failed to create temp dir'
# ...
cd "$check_dir"       # ← unchecked
```

**What is wrong:**
BCS0604 states: "Always check return values of critical operations." `cd` can fail if the directory was removed by another process between `mktemp` and the `cd`. While the window is tiny, a failure here would leave the function executing in the original directory, defeating the CLAUDE.md isolation purpose.

**How to fix:**
```bash
cd "$check_dir" || die 1 "Failed to cd into temp dir ${check_dir@Q}"
```

---

## Inline Suppressions — Reviewed

| Line | Directive | Reason | Valid? |
|------|-----------|--------|--------|
| 474 | `#bcscheck disable=BCS0603` | Trap uses double-quotes intentionally — `$PWD` and `$check_dir` must expand at trap-set time so the RETURN handler restores the correct original directory | ✓ Yes |
| 554 | `#bcscheck disable=BCS0806` | `-V` is repurposed for template version string, not the standard "print version and exit" | ✓ Yes |

---

## ShellCheck Results

```
shellcheck -x /ai/scripts/Okusi/BCS/bcs
(no output — zero findings)
```

---

## Summary Table

| BCS Code | Severity  | Line(s)  | Description |
|----------|-----------|----------|-------------|
| BCS0606  | VIOLATION | 630      | `&&` without `||:` — `set -e` exits when `--` passed without trailing argument |
| BCS0111  | WARNING   | 76–89    | `read_conf()` missing 2 of 6 standard search paths |
| BCS0502  | WARNING   | 703–708  | `case $backend in` has no default `*)` catch-all |
| BCS0108  | WARNING   | 852–896  | `VERBOSE` not made readonly post-parse (intentional, architectural) |
| BCS0604  | WARNING   | 477      | `cd "$check_dir"` return value unchecked |

---

## Overall Health Score: 9.2 / 10

The script is an excellent example of BCS compliance — it self-documents the standard it enforces. The sole VIOLATION (BCS0606, line 630) is a genuine `set -e` correctness bug, not a style issue, and has a one-token fix (`||:`). All other findings are low-severity warnings. ShellCheck reports zero issues. All inline suppressions are valid and well-placed.

**Top priority fix:** Line 630 — add `||:` to the `--` handler.
