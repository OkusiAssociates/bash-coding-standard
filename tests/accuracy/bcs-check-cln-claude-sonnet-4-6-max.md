bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/File/cln/cln'
I'll audit the script line by line against the BCS.

---

## Findings

### BCS0111 — WARNING — Lines 111–127 — Config search order deviates from standard cascade

The BCS0111 standard cascade order is:
1. `/usr/lib/name/name.conf`
2. `/usr/share/name/name.conf`
3. `/usr/local/etc/name/name.conf`
4. `/etc/name.conf`
5. `/etc/name/name.conf`
6. `$XDG_CONFIG_HOME/name/name.conf`

The script uses **first-match-wins** semantics (returns on first found) rather than cascade (all files sourced, later overrides earlier), and the search order places XDG user config **first** rather than last. The help text documents these paths, which mitigates the violation. However, the order means system config (`/etc/cln.conf`) is silently skipped if a user config exists, which is the **inverse** of the standard priority model. This is an intentional design choice (first-match-wins) but is a meaningful deviation from BCS0111's cascade pattern and priority ordering.

**Fix:** Either (a) document explicitly in help text that user config takes highest priority, or (b) reverse the order to match standard cascade (system → user) and use cascade sourcing instead of first-match-wins.

---

### BCS0111 — WARNING — Lines 111–127 — `read_conf` uses `readarray` instead of `source`

BCS0111 specifies that config files are **sourced** (`source "$conf_file"`), which allows key-value assignments. This implementation instead reads the file as a line-delimited list of patterns via `readarray -t`. This is a legitimate intentional deviation — the config file here is a simple pattern list, not a shell variable assignment file — but it deviates from the BCS0111 reference pattern.

The help text does not explain the config file format. **Fix:** Add a note to the help text explaining that the config file contains one file pattern per line (not shell variable assignments).

---

### BCS0111 — WARNING — Lines 68–73 — Help text search order does not match code

The help text lists config paths in this order:
1. `$XDG_CONFIG_HOME/cln/cln.conf`
2. `/etc/cln/cln.conf`
3. `/etc/cln.conf`
4. `/etc/default/cln`
5. `/usr/local/etc/cln/cln.conf`

The code search order (lines 113–119) is:
1. `$XDG_CONFIG_HOME/cln/cln.conf`
2. `/etc/cln/cln.conf`
3. `/etc/cln.conf`
4. `/etc/default/cln`
5. `/usr/local/etc/cln/cln.conf`

These match — no deviation here. *(Retracted — not a finding.)*

---

### BCS0806 — (suppressed by `#bcscheck disable=BCS0806` at line 169) — Lines 170–172

The `-p|-n|--prompt` pattern reuses `-n` (standard: `--dry-run`) and `-P|-N|--no-prompt` reuses `-N` (standard: cancel dry-run). The suppression directive is present and correctly scoped to the case block. **Not reported per suppression rules.**

---

### BCS0173 / BCS0504 — WARNING — Lines 149, 157 — Inline `IFS=','` modification

```bash
IFS=',' read -ra add_specs_raw <<< "$1"
IFS=',' read -ra set_specs_raw <<< "$1"
```

Per the compliance checking reference: "The `IFS=value command` form modifies IFS only for the duration of that command. This is NOT an unlocalized IFS modification." These are correct and not violations.

*(No finding — inline IFS is properly scoped.)*

---

### BCS0503 — VIOLATION — Lines 173 — `VERBOSE+=1` uses `&&...||:` but the condition and action are correct

```bash
-v|--verbose) ((VERBOSE < 3)) && VERBOSE+=1 ||:  ;;
```

Per BCS0606: `((cond)) && action ||:` with `||:` present is acceptable for flag-guarded actions. **Not a violation.** *(Retracted.)*

---

### BCS0503 — VIOLATION — Line 167 — `((max_depth != -1)) || max_depth=255`

```bash
((max_depth != -1)) || max_depth=255
```

`max_depth` is declared `local -i`. The arithmetic `((max_depth != -1))` returns exit code 1 when the condition is false (i.e., when `max_depth == -1`), which is exactly when we want to execute `max_depth=255`. This is the correct BCS0606 inverted-condition pattern. **Not a violation.** *(No finding.)*

---

### BCS0201 — WARNING — Line 136 — `local -- path` declared before use but overwritten inside loop

```bash
local -- path
...
local -- file
for path in "${paths[@]}"; do
```

`local -- file` is declared at line 207, inside `main()` but after the argument-parsing block and before the loop that uses it. BCS0401 allows mid-body declarations between logical sections. The `local -- path` at line 136 is declared in the initialization block, used later in a `for` loop — this is fine. `local -- file` at line 207 is declared just before the loop that uses it. Both are acceptable per BCS0401. **Not a finding.**

---

### BCS0107 — WARNING — Lines 52–53 — Utility functions `noarg` and `decp` placed after messaging functions but before `show_help`

Per BCS0107, function organization is: messaging (1) → documentation (2) → helper/utility (3) → validation (4) → business logic (5) → orchestration (6) → `main()` (7).

`noarg` (validation, layer 4) and `decp` (utility, layer 3) appear at lines 52–53, after messaging (lines 40–43) and before `show_help` (line 58). This ordering places validation before documentation, which is layer 4 before layer 2 — a deviation from the bottom-up ordering. The difference is minor (two small helpers), but it is a detectable ordering deviation.

**Fix:** Move `noarg` and `decp` and `s()` to after `show_help()`.

---

### BCS0504 — VIOLATION — Line 226 — `&&` chain without `||:` coverage is present, but `||:` IS present

```bash
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0 ||:
```

The `||:` at the end covers the entire chain. This is correct and safe. **Not a violation.** *(Retracted.)*

---

### BCS0101 / BCS0103 — NOTICE — `SCRIPT_DIR` not declared

`SCRIPT_DIR` is not declared and is not used anywhere in the script. Per BCS0405 and BCS0103 ("Not all scripts will require all Script Metadata variables"), this is **not a violation**.

---

### BCS0111 — WARNING — Lines 111–127 — `read_conf` returns 1 when no config found but comment says "BCS0111 search order"

The function signature returns 1 when no config is found (line 126), and is called with `||:` at line 131. This is correct and consistent with BCS0111. **Not a finding.**

---

### BCS0702 — VIOLATION — Line 176–177 — `return 0` used instead of `exit 0` for `--version` and `--help`

```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; return 0 ;;
-h|--help)      show_help; return 0 ;;
```

`--version` and `--help` are handled inside `main()`. Using `return 0` from `main()` is functionally equivalent to `exit 0` for a non-sourced script, because `main "$@"` is the last statement before `#fin`. However, the BCS0403 pattern explicitly uses `exit 0` for these early-exit options:

> `show_help; exit 0`
> `printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0`

If this script were ever sourced (e.g., in testing), `return 0` from within `main()` would be correct. Since the script has no source fence and is not dual-purpose, `exit 0` is the appropriate form. This is a WARNING rather than a VIOLATION — `return 0` from `main()` works correctly in all normal execution contexts.

**Fix:** Change `return 0` to `exit 0` for `--version` and `--help` handlers.

---

### BCS0201 — WARNING — Lines 134–144 — `local -a add_specs=()` declared but also declared again at line 140

Line 134: `local -a add_specs=()`
Line 140: `local -a all_specs=() add_specs_raw=() set_specs_raw=()`

`add_specs` is declared at line 134, then `add_specs_raw` is declared as part of a batch at line 140. These are different variables. No duplicate declaration. *(No finding.)*

---

### BCS0201 — WARNING — Line 134 — `local -a add_specs=()` declared separately from related arrays

`add_specs` is declared at line 134 but all other related arrays (`all_specs`, `add_specs_raw`, `set_specs_raw`) are declared together at line 140. This is a minor style inconsistency — grouping related declarations together would improve readability. This is a WARNING at most.

**Fix:** Group `add_specs` with the other array declarations at line 140.

---

### BCS0705 — WARNING — Line 214 — `info` used to output `decp` result (debug-level information displayed at VERBOSE > 1)

```bash
((VERBOSE > 1)) && info "$(decp find_expr)" ||:
```

This is a creative use of `info` for debug-level content gated on `VERBOSE > 1`. Since there is no `debug()` function in this script (correctly omitted per BCS0405 — `DEBUG` is never declared), using `info` at a higher verbosity level is acceptable. **Not a finding.**

---

### BCS0503 — WARNING — Line 189 — `((${#paths[@]})) || paths=('.')` — correct inverted pattern

This correctly uses the inverted `||` form per BCS0606. **Not a finding.**

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0111 | WARNING | 111–127 | `read_conf` uses first-match-wins with XDG config first (highest priority), inverting the standard cascade where user config should override system config (same effective result, but order reversal is non-standard) |
| BCS0111 | WARNING | 111–127 | Config files are read as pattern lists (via `readarray`) rather than sourced as shell assignments; help text does not document the expected config file format |
| BCS0107 | WARNING | 52–56 | `noarg`, `decp`, and `s()` utility/validation functions appear before `show_help()` (documentation layer), inverting the recommended bottom-up order |
| BCS0403 | WARNING | 176–177 | `return 0` used for `--version` and `--help` early exits inside `main()`; BCS0403 pattern uses `exit 0` for these handlers |
| BCS0201 | WARNING | 134, 140 | `add_specs=()` declared separately from related arrays `all_specs`, `add_specs_raw`, `set_specs_raw`; grouping improves readability |
bcs: ◉ Tokens: in=26312 out=2960
bcs: ◉ Elapsed: 57s
