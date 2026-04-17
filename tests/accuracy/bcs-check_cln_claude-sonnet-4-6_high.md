bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
I'll analyze the script systematically against the BCS rules.

---

**[WARN] BCS0111 line 111-127: `read_conf()` uses first-match-wins semantics instead of the BCS0111 cascade (all-files-sourced) pattern, and sources via `readarray` rather than `source`.**

The BCS0111 reference pattern sources *all* files in order so later entries override earlier ones. This implementation stops at the first match and reads the file as line-delimited patterns rather than sourcing it as Bash. Both deviations are intentional design choices (first-match-wins for config, line-oriented format for patterns), but they diverge from the reference pattern without a comment explaining the deviation.

Additionally, the search path order differs from BCS0111 (XDG is first here, system paths are in non-standard order, and `/etc/default/cln` is included which is not in the BCS0111 reference). The help text at lines 68-73 documents the actual paths used, which satisfies the BCS0111 note about documenting deviations — but the help text itself lists the paths in a different order than the code (help shows XDG first, then `/etc/cln/cln.conf`, `/etc/cln.conf`, `/etc/default/cln`, `/usr/local/etc/cln/cln.conf`; code matches that order). This is consistent.

*Fix recommendation:* Add a comment inside `read_conf()` explicitly noting the first-match-wins design choice and the line-oriented (non-Bash-source) format, e.g.:
```bash
# First-match-wins (not cascade): patterns file is line-oriented, not sourced as Bash
```

---

**[WARN] BCS0103 line 15: `SCRIPT_DIR` is absent.**

`SCRIPT_DIR` is a standard metadata variable (BCS0103). However, BCS0103 itself notes "Not all scripts will require all Script Metadata variables." The script never references `SCRIPT_DIR`, so per BCS0405 this is acceptable and should NOT be flagged. *(Retracted — not a violation.)*

---

**[WARN] BCS0301 line 46: Double-quoted static string fragment used where single quotes apply.**

Line 46:
```bash
>&2 printf '%s ' "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n"
```
The format string contains `${YELLOW}`, `${NC}`, and `${1:-}` — these require double quotes. This is correct. *(Not a violation.)*

---

**[WARN] BCS0503 line 200-202: Loop variable `spec` is declared `local` outside the loop (line 139), which is correct per BCS0401. No issue.**

*(Not a violation — declared before the loop body as required.)*

---

**[WARN] BCS0207 line 151, 160: Trim operations inline rather than using `trim()`.**

Lines 151 and 160 perform inline whitespace trimming:
```bash
spec="${spec#"${spec%%[![:blank:]]*}"}"; spec="${spec%"${spec##*[![:blank:]]}"}"
```
The script defines no `trim()` function, so this inline approach is correct per BCS0405. *(Not a violation.)*

---

**[WARN] BCS0107 line 207: `local -- file` declared mid-function body between logical sections.**

Line 207 declares `local -- file` after the argument-parsing block and after `all_specs`/`find_expr` are built, immediately before the `for path` loop. BCS0401 explicitly permits mid-body declarations "between logical sections." *(Not a violation.)*

---

**[ERROR] BCS0410 line 200-202: Loop variable `spec` in a non-recursive function — not applicable.**

The function is not recursive. BCS0410 only applies to recursive functions. *(Not applicable.)*

---

**[WARN] BCS0111 / BCS0104 line 111-127: Search path order is reversed from BCS0111.**

BCS0111 specifies: system paths load first, user paths load last, so user settings override system defaults. The BCS0111 reference order is:
1. `/usr/lib/...`
2. `/usr/share/...`
3. `/usr/local/etc/...`
4. `/etc/name.conf`
5. `/etc/name/name.conf`
6. `$XDG_CONFIG_HOME/...`

This script uses first-match-wins with XDG *first*, meaning user config takes priority. Under a cascade model this would be a deviation; under the documented first-match-wins model it is intentional. The help text documents the actual behavior. This is a WARNING-level deviation from BCS0111's cascade model.

*Fix recommendation:* Document in `read_conf()` that the search order is intentionally user-first (highest priority) rather than the BCS0111 cascade model, or invert the list and source all files for true cascade behavior.

---

**[WARN] BCS0806 line 170: `-n` assigned to `--prompt` conflicts with the BCS0806 standard assignment of `-n` to `--dry-run`.**

BCS0806 reserves `-n` for `--dry-run`. This script assigns `-n` as an alias for `--prompt`. A `#bcscheck disable=BCS0806` directive is present on line 169, suppressing this finding for the next block (lines 170-172).

Per the inline suppression rule, this finding is **suppressed** and must not be reported.

---

**[WARN] BCS0804 line 176-177: `return 0` used inside `main()` for `--version` and `--help` instead of `exit 0`.**

Lines 176-177:
```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; return 0 ;;
-h|--help)      show_help; return 0 ;;
```
BCS0108 shows `exit 0` in the reference pattern for these options. Using `return 0` from `main()` is functionally equivalent for a non-sourced script (the caller of `main` is the script's global scope, so `return 0` propagates as exit code 0). This is a WARNING-level style deviation at most.

*Fix recommendation:* Use `exit 0` for consistency with BCS0108:
```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
-h|--help)      show_help; exit 0 ;;
```

---

**[WARN] BCS0503 line 167: `((max_depth != -1)) || max_depth=255` — inverted form without `||:`, which is safe here (RHS assignment returns 0). Not a violation.**

*(Not a violation — the inverted `||` form is explicitly listed as safe in BCS0606.)*

---

**[WARN] BCS0202 / BCS0401: `spec` used as loop variable in two separate `for` loops (lines 150-153 and 159-162) within `main()`, but declared once at line 139.**

A single `local -- spec` (line 139) covers both loops in the same function scope. This is correct — `local` in Bash applies to the function scope, not block scope. *(Not a violation.)*

---

**[WARN] BCS1202 lines 20-21: Comment at lines 20-21 partially paraphrases the code.**

```bash
# Messaging system - color-coded output with TTY detection
# _msg: base formatter; vecho/warn/error: level wrappers; die: fatal exit; yn: yes/no prompt
```
Line 21 lists function names and roles that are already evident from reading the function definitions. However, the comment provides a navigational index and summarizes the system's architecture in one line — this adds value as a section overview. Borderline, but not a clear violation per BCS1202's test ("a competent reader couldn't recover from the code alone").

*(Not a violation.)*

---

**[WARN] BCS0111 line 122: `read_conf()` does not `source` the config file; it reads it as line-delimited patterns.**

The BCS0111 standard approach uses `source "$conf_file"` so config files are executed as Bash. This implementation uses `readarray -t DELETE_FILES < <(grep ...)` to read pattern lines. This is a documented intentional deviation (the script's config format is a list of glob patterns, not Bash variable assignments). The help text describes the config files. This is a WARNING per BCS0111 ("scripts that intentionally use alternative methods... should document the deviation").

*Fix recommendation:* Add a comment explicitly stating the config file format is a newline-delimited list of glob patterns (not Bash syntax):
```bash
# Config file format: one glob pattern per line; '#' lines and blank lines ignored
```

---

**[WARN] BCS1204 line 17: Section comment is a full sentence rather than 2-4 words.**

Line 17:
```bash
# Default file patterns to remove (editor backups, crash files, temp files)
```
BCS1204 specifies section comments should be "2-4 words." This comment is descriptive and informative but exceeds the 2-4 word limit for a section comment. Under BCS1202, it adds information not in the code (explains *what kinds* of files the patterns target). It is functioning more as an explanatory comment than a section header.

*Fix recommendation:* Either shorten to a 2-4 word section comment and add inline comments on the declaration, or keep as-is and accept this as a minor style deviation:
```bash
# Default patterns
declare -a DELETE_FILES=('*~' '~*' '.~*' '.*~' DEADJOE dead.letter 'wget-log*')  # editor backups, crash files, temp files
```

---

**[WARN] BCS1204 line 20: Same issue — section comment exceeds 2-4 words.**

Line 20:
```bash
# Messaging system - color-coded output with TTY detection
```
This is 7+ words. Same recommendation as above.

*Fix recommendation:*
```bash
# Messaging system
```

---

**[WARN] BCS1204 line 110: Section comment is a full sentence.**

Line 110:
```bash
# Load patterns from config file if exists (BCS0111 search order)
```
This is a function-preceding comment rather than a section comment, and it provides useful context (BCS rule reference). Borderline. If treated as a section comment: too long. If treated as a function documentation comment: acceptable. Given BCS1202's test (adds information), this passes. *(Not flagged as a violation.)*

---

**[WARN] BCS1204 line 133: `# Default configurations` — acceptable 2-word section comment. Not a violation.**

---

**[WARN] BCS0503 line 189: `((${#paths[@]})) || paths=('.')` — inverted `||` form, safe. Not a violation.**

---

Now checking the `yn()` function against BCS0709:

**BCS0709 reference:**
```bash
yn() {
  local -- REPLY
  >&2 echo -n "$SCRIPT_NAME: $YELLOW▲$NC ${1:-Continue?} y/n"
  read -r -n 1
  >&2 echo
  [[ ${REPLY,,} == y ]]
}
```

**Script's implementation (lines 44-50):**
```bash
yn() {
  local -- REPLY
  >&2 printf '%s ' "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n"
  read -r -n 1
  echo >&2
  [[ ${REPLY,,} == y ]]
}
```

The script uses `printf '%s '` (which adds a trailing space correctly) and `echo >&2` (stderr redirect at end rather than beginning). The `>&2` placement on `echo` is a style deviation from BCS0702 which requires `>&2` at the **beginning**.

**[WARN] BCS0702 line 48: `echo >&2` has redirection at end instead of beginning.**

BCS0702 specifies: "place `>&2` at the BEGINNING."

*Fix recommendation:*
```bash
  >&2 echo
```

---

**[WARN] BCS0301 line 46: `printf` format string uses double quotes with variable expansion — correct. The argument `"$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n"` is passed as data, not format string.**

Wait — line 46 uses:
```bash
>&2 printf '%s ' "$SCRIPT_NAME: ${YELLOW}▲${NC} ${1:-Continue?} y/n"
```
The format is `'%s '` (single-quoted, correct). The argument uses double quotes because it contains variable expansions. This is correct per BCS0301. *(Not a violation.)*

---

**Checking BCS0409 (Bash version detection):** The script does not call `require_bash`. Given it uses Bash 5.2+ features (`shopt -s inherit_errexit`, `shift_verbose`, `${var@Q}`), a `require_bash 5 2` call would be appropriate.

**[WARN] BCS0409 line 7-8: No `require_bash` call after strict mode for a script using Bash 5.2+ features.**

BCS0409 says: "Call `require_bash` at script start, after strict mode and before any feature-dependent code." The script uses `${var@Q}` (Bash 5.0+) and `shift_verbose` (Bash 5.0+).

*Fix recommendation:* Define `require_bash` (or source a library that provides it) and call it after strict mode:
```bash
require_bash 5 2
```

---

**Checking BCS0106 (end marker):** Line 245 is `#fin`. ✓

**Checking BCS0101:** `set -euo pipefail` at line 7, `shopt -s inherit_errexit` at line 8. ✓

**Checking BCS0102:** Shebang `#!/usr/bin/env bash` at line 1. ✓

**Checking BCS0103:** `VERSION`, `SCRIPT_PATH`, `SCRIPT_NAME` declared. `SCRIPT_DIR` absent but unused — acceptable per BCS0405. ✓

**Checking BCS0108:** `main "$@"` at line 244. ✓

**Checking BCS0201 / BCS0202:** All variables use explicit types. ✓

**Checking BCS0602 `die()`:** Line 43 matches reference. ✓

**Checking BCS0606:** All `((cond)) && action ||:` patterns have `||:`. Lines 173, 190, 193, 214, 226. `#shellcheck disable=SC2015` covers these. ✓

**Checking BCS0703:** `_msg()` uses `FUNCNAME[1]` dispatch. Reference includes `success` and `debug` cases; script omits them. Per BCS0405, since `success()` and `debug()` are not defined, omitting those cases is correct. ✓

**Checking BCS0706:** Colors: `RED`, `YELLOW`, `CYAN`, `NC` defined in both branches. `GREEN` absent — no `success()` function exists, so correct per BCS0405. ✓

**Checking BCS0801:** Parsing pattern `while (($#)); do case $1 in ... esac; shift; done`. ✓

**Checking BCS0802:** Line 176: `echo "$SCRIPT_NAME $VERSION"`. ✓

**Checking BCS0805 (option bundling):** Line 181: `-[LaSmpPNnvqVh]?*` pattern with `set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue`. ✓

**Checking BCS1002:** `PATH` secured at line 10. ✓

---

## Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0111 | recommended | WARN | 111–127 | `read_conf()` uses first-match-wins + `readarray` instead of cascade + `source`; deviation from BCS0111 reference not documented in code (only in help text) |
| BCS0111 | recommended | WARN | 113–119 | Search path order is user-first (XDG at top), opposite of BCS0111 cascade priority; intentional but undocumented in function body |
| BCS0409 | recommended | WARN | 7–8 | No `require_bash 5 2` call; script uses Bash 5.0+ features (`${@Q}`, `shift_verbose`) |
| BCS0702 | core | ERROR | 48 | `echo >&2` places redirection at end; BCS0702 requires `>&2` at the beginning |
| BCS0804 | recommended | WARN | 176–177 | `return 0` used for `--version`/`--help` exits inside `main()`; BCS0108 reference uses `exit 0` |
| BCS1204 | style | WARN | 17 | Section comment exceeds 2-4 words: "Default file patterns to remove (editor backups, crash files, temp files)" |
| BCS1204 | style | WARN | 20 | Section comment exceeds 2-4 words: "Messaging system - color-coded output with TTY detection" |
bcs: ◉ Tokens: in=30974 out=4351
bcs: ◉ Elapsed: 86s
bcs: ◉ Exit: 1
bcs: ◉ Raw response: /home/sysadmin/.local/state/bcs/last-response.txt
