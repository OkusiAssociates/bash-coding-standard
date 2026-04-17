bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
I'll perform an exhaustive line-by-line audit against the BCS rules.

---

**Line 2:** `#shellcheck disable=SC2015` — This disables SC2015 which warns about `A && B || C` patterns. The script correctly uses `||:` throughout, so this is appropriate.

**Line 8:** `shopt -s inherit_errexit shift_verbose extglob nullglob` — All valid per BCS0101. `nullglob` is noted as appropriate for strict scripts that want unmatched globs to expand to nothing; acceptable.

**Line 10:** PATH set early, before any commands that depend on it. ✓

**Lines 12–15:** Metadata declarations. ✓

**Line 18:** `declare -a DELETE_FILES=...` — global array with type declaration. ✓

**Lines 22–28:** Flags and colors declared. `VERBOSE=1 PROMPT=1` — integer flags. Colors defined conditionally on `[[ -t 1 && -t 2 ]]`. ✓ Colors declared match what's used (`RED`, `YELLOW`, `CYAN`, `NC`). `GREEN` absent — correct per BCS0405. ✓

**Lines 30–50:** `_msg()`, `info()`, `warn()`, `error()`, `die()`, `yn()` — review against BCS0703.

- `_msg()` dispatches on `FUNCNAME[1]`. Handles `info`, `warn`, `error`. No `success` or `debug` — consistent with BCS0405 (not used). ✓
- `info()` respects VERBOSE ✓; redirects to stderr ✓
- `warn()` unconditional ✓; stderr ✓
- `error()` unconditional ✓; stderr ✓
- `die()` ✓
- `yn()` — compare to BCS0709 reference: uses `printf` instead of `echo -n` — functionally equivalent, acceptable. ✓

**Line 46:** `>&2 printf '%s ' "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n"` — The format string contains variable expansions (`$SCRIPT_NAME`, `$YELLOW`, etc.), so double quotes are appropriate. However, the first argument to `printf` should be a pure format string. This mixes literal text and variable content into the format string — a `%s` injection risk if `$SCRIPT_NAME` or `$1` contains `%`. The safe form is: `>&2 printf '%s: %s▲%s %s y/n ' "$SCRIPT_NAME" "$YELLOW" "$NC" "${1:-Continue?}"`. This is a mild issue.

[WARN] BCS0305 line 46: Variables embedded directly in `printf` format string — if `$SCRIPT_NAME` or `${1:-Continue?}` contains `%`, output will be malformed or cause errors. Use `printf '%s ...' "$var"` form with all variables as arguments, not embedded in the format string.
**Fix:** `>&2 printf '%s: %b %s y/n ' "$SCRIPT_NAME" "${YELLOW}▲${NC}" "${1:-Continue?}"`

**Lines 52–56:** `noarg()`, `decp()`, `s()` — utility functions. All appear used in the script. ✓

**Lines 58–108:** `show_help()` — uses `cat <<HELP` heredoc with variable expansion. ✓ Note on line 68: help text lists config file search order as: XDG first, then `/etc/cln/cln.conf`, `/etc/cln.conf`, `/etc/default/cln`, `/usr/local/etc/cln/cln.conf`.

**Lines 111–127:** `read_conf()` — First-match-wins semantics (returns on first found file). The BCS0111 reference pattern uses cascade (all files sourced, later overrides earlier). This is a documented intentional deviation — the help text at lines 68–73 explicitly states "first found wins," so this is documented. ✓ However, the search order in `read_conf` differs from BCS0111's canonical cascade order AND from what the help text lists:

- Help text order (lines 69–73): XDG → `/etc/cln/cln.conf` → `/etc/cln.conf` → `/etc/default/cln` → `/usr/local/etc/cln/cln.conf`
- Code order (lines 114–118): XDG → `/etc/cln/cln.conf` → `/etc/cln.conf` → `/etc/default/cln` → `/usr/local/etc/cln/cln.conf`

These match. ✓

BCS0111 also notes the function should return success when at least one file loaded. The function does `return 0` on first found, `return 1` if none found — correct. ✓

The function uses `readarray` from a grep rather than `source` — this is a deliberate alternative (reading patterns, not shell variables), documented deviation. The comment on line 110 references BCS0111. Acceptable per "scripts may adjust... provided the help text documents the actual paths used." ✓

**Lines 129 onward:** `main()` function.

**Line 131:** `read_conf ||:` — suppresses failure if no config found. ✓

**Lines 134–144:** Local variable declarations at top of `main()`. ✓

**Lines 146–186:** Argument parsing loop. `while (($#)); do case $1 in` — correct BCS0801 pattern. ✓

**Lines 169–170:**
```bash
#bcscheck disable=BCS0806
-p|-n|--prompt) PROMPT=1; VERBOSE=1 ;;
```
`-n` normally maps to `--dry-run` per BCS0806 standard options. The `#bcscheck disable=BCS0806` suppression is present — this finding is suppressed. ✓

**Line 173:** `((VERBOSE < 3)) && VERBOSE+=1 ||:` — `||:` present. ✓ per BCS0606.

**Line 176:** `echo "$SCRIPT_NAME $VERSION"; return 0` — version output format correct per BCS0802. Uses `return 0` instead of `exit 0` since this is inside `main()`. The script is not dual-purpose (no source fence), so `return 0` inside main causes the function to return but the script continues to the `main "$@"` call site — which then falls through to the end of script, effectively exiting 0. This is functionally correct but subtly differs from `exit 0`. For a non-sourced script, `return 0` from `main()` is fine. ✓

**Line 177:** `show_help; return 0` — same reasoning. ✓

**Line 181:** `-[LaSmpPNnvqVh]?*` — option bundling. Lists all valid short options. ✓

**Line 189:** `((${#paths[@]})) || paths=('.')` — sets default path. ✓

**Line 190:** `((PROMPT && !VERBOSE)) && VERBOSE=1 ||:` — `||:` present. ✓

**Line 191:** `readonly VERBOSE PROMPT` — made readonly after parsing. ✓

**Line 193:** `((VERBOSE)) && rm_opts+=(-v) ||:` — `||:` present. ✓

**Line 196:** `all_specs=("${DELETE_FILES[@]}" "${add_specs[@]}")` — combining arrays. ✓

**Line 200–202:** `for spec in "${all_specs[@]}"` — loop. `spec` is declared `local` at line 139 before the loop. ✓

**Line 207:** `local -- file` — declared before loop at line 207, inside function body. ✓ BCS0401 allows declarations mid-body between logical sections.

**Line 208:** `for path in "${paths[@]}"` — `path` is declared `local` at line 136. ✓

**Line 214:** `((VERBOSE > 1)) && info "$(decp find_expr)" ||:` — `||:` present. ✓

**Lines 216–223:** `readarray -t found_files < <(find ...)` — process substitution pattern. ✓ The `find` command uses `||:` at the end to handle permission errors gracefully. ✓

**Line 224:** `fnd=${#found_files[@]}` — `fnd` is declared `local -i` at line 142. Assignment to integer variable. ✓

**Line 226:** `((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0 ||:` — chain with `||:`. The comment above explains the readarray quirk. ✓

**Line 237:** `rm "${rm_opts[@]}" -- "${found_files[@]}"` — uses `--` before file arguments per BCS1005. ✓

**Line 244:** `main "$@"` — quoted. ✓

**Line 245:** `#fin` — end marker present. ✓

---

Now checking global structural concerns:

**Function organization (BCS0107):** Bottom-up order check:
1. `_msg()` (messaging) — line 30
2. `info()`, `warn()`, `error()`, `die()`, `yn()` (messaging wrappers) — lines 40–50
3. `noarg()`, `decp()`, `s()` (utility/helpers) — lines 52–56
4. `show_help()` (documentation) — line 58
5. `read_conf()` (helper/config) — line 111
6. `main()` (orchestration) — line 129

This order is valid. ✓

**BCS0103 — SCRIPT_DIR missing:** The script declares `SCRIPT_PATH` and `SCRIPT_NAME` but not `SCRIPT_DIR`. BCS0103 says "Not all scripts need all four" — no violation. ✓

**BCS0108 — main() for scripts over ~200 lines:** Script is ~245 lines. `main()` is present. ✓

**BCS0101 — strict mode placement:** `set -euo pipefail` at line 7 — correct, before any executable code. ✓

**BCS0102 — shebang:** `#!/usr/bin/env bash` — acceptable form. ✓

**BCS0109 — end marker:** `#fin` at line 245. ✓

**BCS0110 — cleanup/traps:** Script creates no temp files, so no cleanup trap is needed. ✓

**BCS0203 — naming:** Global constants `VERSION`, `SCRIPT_PATH`, `SCRIPT_NAME`, `PATH` — UPPER_CASE. ✓ Functions lowercase. ✓

**BCS0208 — boolean flags:** `VERBOSE`, `PROMPT` declared with `declare -i`. ✓

**Now re-examine `read_conf` search order against BCS0111:**

BCS0111 canonical order:
1. `/usr/lib/name/name.conf`
2. `/usr/share/name/name.conf`
3. `/usr/local/etc/name/name.conf`
4. `/etc/name.conf`
5. `/etc/name/name.conf`
6. `$XDG_CONFIG_HOME/name/name.conf`

Script's first-match-wins order: XDG first (most specific/user), then system configs. This is inverted from BCS0111's cascade (which goes from least specific to most specific, with user last to allow overrides). The help text documents this explicitly as "first found wins" with XDG first. BCS0111 says "scripts may adjust the search path order provided the help text documents the actual paths used." The help text does document it. No violation. ✓

**BCS0301 — quoting:** Review static strings.

- Line 3: comment ✓
- Line 17: comment, single-quote-style strings in array ✓
- Line 18: array elements with single quotes ✓
- Line 20–21: comments ✓
- Line 38: `'%s %s\n'` — single-quoted format string ✓
- Line 52: `"Option ${1@Q} requires an argument"` — double quotes needed for expansion ✓

Checking for double-quoted static strings...

- Line 40: `info()` function body — no string literals
- Line 46: format string in `yn()` — discussed above (BCS0305)
- Line 59: `cat <<HELP` — unquoted heredoc delimiter, needed for variable expansion ✓
- Line 197: `'No file patterns specified'` — single-quoted ✓
- Line 210: `" is not a directory. Skipping."` — wait, let me re-read:

Line 210: `warn "${path@Q} is not a directory. Skipping."` — double-quoted because it contains variable expansion. ✓

Line 213: `info "Searching directory ${path@Q}, depth $max_depth"` — double-quoted with expansion. ✓

Line 239: `info "No matching files found in ${path@Q}"` — ✓

Line 165: `die 22 "Option '-m|--depth' requires a numeric argument, got ${1@Q}"` — double-quoted with expansion. ✓

**BCS0707 / BCS0706:** Color definitions: `RED`, `YELLOW`, `CYAN`, `NC` — `GREEN` absent. Script has no `success()` function. Per BCS0405 this is correct. ✓

**BCS1201 — indentation:** Script uses 2-space indentation. ✓

**BCS1202 — comments:** Review comments:

- Line 17: `# Default file patterns to remove (editor backups, crash files, temp files)` — adds context about what the patterns are. ✓
- Line 20–21: `# Messaging system - color-coded output with TTY detection` and second line `# _msg: base formatter; vecho/warn/error: level wrappers; die: fatal exit; yn: yes/no prompt` — these describe the functions that follow, appropriate documentation comment. ✓
- Line 23: `# Enable colors only when both stdout and stderr are terminals` — somewhat paraphrases `[[ -t 1 && -t 2 ]]` but adds the rationale "both stdout AND stderr." Borderline, but adds info. ✓
- Line 52 trailing: `# Validate option has argument` — paraphrases `noarg()`. 

[WARN] BCS1202 line 52: Trailing comment `# Validate option has argument` mechanically paraphrases the function call — the function name `noarg` already communicates this.
**Fix:** Remove the comment, or replace with non-obvious context (e.g., `# must be called before shift`).

- Line 53 trailing: `# Print variable as name=value (help display & debug)` — adds context about use cases beyond what the name conveys. ✓
- Line 55: `# Pluralization helper: returns 's' if count != 1` — adds value beyond `s()` name. ✓
- Line 110: `# Load patterns from config file if exists (BCS0111 search order)` — useful reference. ✓
- Line 130: `# Load config file if exists (user or system)` — somewhat paraphrases `read_conf ||:`.

[WARN] BCS1202 line 130: Comment `# Load config file if exists (user or system)` paraphrases the `read_conf` call below it — the function name is already clear. The comment adds minimal new information.
**Fix:** Remove, or note the intentional first-match-wins override: `# First-match-wins config load (XDG overrides system)`.

- Line 133: `# Default configurations` — section comment. ✓
- Line 188: `# Set default path if not provided` — borderline paraphrase of `((${#paths[@]})) || paths=('.')`.

[WARN] BCS1202 line 188: Comment `# Set default path if not provided` paraphrases the line below.
**Fix:** Remove, or fold into a short section comment like `# Defaults` covering lines 188–190.

- Line 195: `# Combine default and additional specs` — paraphrases `all_specs=("${DELETE_FILES[@]}" "${add_specs[@]}")`.

[WARN] BCS1202 line 195: Comment `# Combine default and additional specs` paraphrases the assignment below it.
**Fix:** Remove.

- Line 199: `# Build find criteria` — adds value (explains the loop builds a `-name X -o -name Y` expression). ✓
- Line 203: `# Remove the last -o` — explains `unset 'find_expr[-1]'`, non-obvious. ✓
- Line 206: `# Iterate over each path` — paraphrases the for loop.

[WARN] BCS1202 line 206: Comment `# Iterate over each path` paraphrases the `for path in "${paths[@]}"` loop below.
**Fix:** Remove.

- Line 215: `# First find matching files and store in array` — paraphrases `readarray -t found_files < <(find ...)`.

[WARN] BCS1202 line 215: Comment `# First find matching files and store in array` paraphrases the `readarray` call below.
**Fix:** Remove.

- Line 225: `# Handle readarray quirk: single empty element means no results` — non-obvious, explains the quirk. ✓
- Line 227: `# Only proceed if files were found` — paraphrases `if ((fnd))`.

[WARN] BCS1202 line 227: Comment `# Only proceed if files were found` paraphrases `if ((fnd))`.
**Fix:** Remove.

**BCS1213 — date/time:** No date/time operations in this script. N/A. ✓

**BCS0409 — bash version detection:** No version check in the script. The script uses features requiring Bash 5+ (`$'...'` escapes, `declare -r`, `[[ ]]`, etc.). BCS0409 is `recommended` tier — absence is a WARN.

[WARN] BCS0409 line 7 (after strict mode): No `require_bash` call to enforce minimum Bash version. Script uses Bash 5+ features (`declare -rx`, `shopt -s inherit_errexit`, etc.).
**Fix:** Add `require_bash 5 2` after `shopt -s inherit_errexit`, with the `bash_at_least`/`require_bash` functions defined before `main()`.

**BCS0302 — command substitution quoting:**

Line 214: `info "$(decp find_expr)"` — command substitution inside double-quoted string. ✓

**BCS0506 — floating-point:** No floating-point operations. N/A.

**BCS1002 — PATH security:** Line 10 sets PATH securely before any commands. ✓

**BCS1003 — IFS safety:** Lines 149, 157 use `IFS=',' read -ra ...` — inline IFS scoped to the read command. Per compliance checking reference: "The `IFS=value command` form modifies IFS only for the duration of that command. This is NOT an unlocalized IFS modification." ✓

**BCS1005 — input sanitization:** Line 237 uses `--` before file arguments. ✓ Line 165 validates numeric input with regex. ✓

**BCS0903/BCS0504 — process substitution:** Lines 122, 216 both use `< <(...)`. ✓

**BCS0905 — cat avoidance:** No unnecessary `cat` usage. ✓

**BCS0711 — combined redirection:** No `>file 2>&1` forms detected. ✓

**BCS0207 — parameter expansion braces:** Checking for unnecessary braces...

Line 151: `spec="${spec#"${spec%%[![:blank:]]*}"}"; spec="${spec%"${spec##*[![:blank:]]}"}"` — braces required for nested parameter expansion. ✓

Line 160: Same. ✓

No unnecessary braces found. ✓

**BCS0502 — case statements:** Line 146: `case $1 in` — no quotes on expression. ✓ Literal patterns unquoted. ✓ Default `*` case at line 184–185. ✓

**BCS0503 — loops:** `while (($#))` — correct. ✓ `i++` not used. ✓ Local variables declared before loops. ✓

**BCS0208:** `VERBOSE` and `PROMPT` as `declare -i`. ✓

**BCS0402 — function names:** All lowercase with underscores. ✓

**BCS0410 — recursive function state discipline:** No recursive functions. N/A.

**BCS0411 — subshell return patterns:** `readarray < <(find ...)` — correct pattern. ✓

**BCS1006 — temp files:** No temp files created. N/A.

**BCS0604 — checking return values:** `rm` at line 237 has `|| warn 'Some files could not be removed'` — handles failure. ✓

**BCS0605 — error suppression:** `2>/dev/null ||:` on find (line 222) — suppressed because permission-denied errors from `find` are expected and non-critical. ✓

**BCS0808 (not a real rule, checking BCS0803) — argument validation:** `noarg` called before each `shift` for options that take arguments. ✓

**One more check — BCS0106 end marker and `#fin`:**

Line 245: `#fin` ✓. No trailing blank line shown, but the end marker is present. ✓

**Checking BCS0107 ordering more carefully:**

`read_conf()` is a config loading function (helper), comes after `show_help()` (documentation). BCS0107 layer order: messaging (1), documentation (2), helper (3), validation (4), business logic (5), orchestration (6), main (7). `read_conf` is a helper — it should come before `show_help` in strict bottom-up order (helpers before documentation). However, BCS0107 allows documentation before helpers as both are low in the call hierarchy. `show_help` doesn't call `read_conf`, so there's no strict dependency. This is a minor ordering concern.

[WARN] BCS0107 line 111: `read_conf()` (layer 3: helper) is defined after `show_help()` (layer 2: documentation). In strict bottom-up order, helpers should precede documentation functions.
**Fix:** Move `read_conf()` to before `show_help()`, or reorder to: messaging → helpers/utilities → documentation → business logic → main.

**BCS0104 — FHS compliance:** Script doesn't install to FHS paths; it reads config from them. The config search path is documented. ✓

**BCS1208 — dry-run:** No dry-run option in this script. `-n` is repurposed (with suppression). No `-N`/`--dry-run`. Not every script needs dry-run. N/A.

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0305 | recommended | [WARN] | 46 | Variables embedded in `printf` format string — `%` in `$SCRIPT_NAME` or `$1` could corrupt output |
| BCS0409 | recommended | [WARN] | 7 | No `require_bash` call; script uses Bash 5+ features without enforcing a minimum version |
| BCS0107 | style | [WARN] | 111 | `read_conf()` (helper, layer 3) defined after `show_help()` (documentation, layer 2); breaks bottom-up ordering |
| BCS1202 | style | [WARN] | 52 | Trailing comment `# Validate option has argument` paraphrases the function name |
| BCS1202 | style | [WARN] | 130 | Comment `# Load config file if exists (user or system)` paraphrases `read_conf` call |
| BCS1202 | style | [WARN] | 188 | Comment `# Set default path if not provided` paraphrases the line below |
| BCS1202 | style | [WARN] | 195 | Comment `# Combine default and additional specs` paraphrases the assignment below |
| BCS1202 | style | [WARN] | 206 | Comment `# Iterate over each path` paraphrases the for loop below |
| BCS1202 | style | [WARN] | 215 | Comment `# First find matching files and store in array` paraphrases the `readarray` call |
| BCS1202 | style | [WARN] | 227 | Comment `# Only proceed if files were found` paraphrases `if ((fnd))` |
bcs: ◉ Tokens: in=30968 out=6189
bcs: ◉ Elapsed: 104s
