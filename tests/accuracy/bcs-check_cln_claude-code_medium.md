bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
Now I have the full standard. Let me compile the complete compliance report.

---

## BCS Compliance Report: `cln`

`★ Insight ─────────────────────────────────────`
`cln` is an exemplary BCS script — it uses `readarray -t < <(...)` correctly throughout (BCS0504/BCS0903), applies `||:` on every `((flag)) && action` chain (BCS0606), declares all locals with explicit types (BCS0201/BCS0202), and correctly documents its first-match config deviation from the BCS0111 cascade pattern. The standard explicitly permits this with documentation.
`─────────────────────────────────────────────────`

---

### Findings

#### [ERROR] BCS0702 · core · Line 48

**Rule:** `>&2` must appear at the **beginning** of a redirection — placing it at the end is a BCS0702 violation.

**Affected line:**
```bash
echo >&2
```

**Problem:** `echo >&2` has the redirection at the end. BCS0702 is explicit:
> correct — place `>&2` at the **BEGINNING**  
> wrong — `>&2` at end (works but harder to spot)

**Fix:**
```bash
>&2 echo
```

---

### Clean / Verified

The following rules were checked and the script is **compliant**:

| Rule | What was verified |
|------|-------------------|
| BCS0101 | `set -euo pipefail` + `shopt -s inherit_errexit` present and correctly ordered |
| BCS0102 | Shebang `#!/usr/bin/env bash` acceptable |
| BCS0103 | `VERSION`, `SCRIPT_PATH`, `SCRIPT_NAME` declared with `declare -r`; `SCRIPT_DIR` omitted (unused — correct per BCS0405) |
| BCS0105/BCS0706 | Colors gated on `[[ -t 1 && -t 2 ]]`; both branches declare same set; `GREEN` omitted (no `success()` — correct per BCS0405) |
| BCS0106 | No extension on PATH-installed binary |
| BCS0107 | Bottom-up function order: `_msg` → `info/warn/error/die` → `yn/noarg/decp/s` → `show_help` → `read_conf` → `main` |
| BCS0108/BCS0403 | `main()` used; `main "$@"` at bottom; `readonly VERBOSE PROMPT` after parsing |
| BCS0109 | `#fin` present |
| BCS0111 | First-match-wins with `readarray` deviation from cascade is **documented** in `show_help` ("first found wins") — explicitly permitted by BCS0111 |
| BCS0201 | All variables: `-i`, `-a`, `-A`, `-r`, `-rx`, `--` types used correctly |
| BCS0202 | All function-local variables declared `local` |
| BCS0203 | UPPER_CASE globals, lower_case functions, `_msg` private prefix |
| BCS0208 | `VERBOSE`, `PROMPT` as `declare -i` |
| BCS0301 | Static strings use single quotes; double quotes reserved for expansion |
| BCS0503 | `while (($#))` pattern; all loop variables (`spec`, `path`, `file`) declared `local` before their loops |
| BCS0504/BCS0903 | `readarray -t < <(...)` used throughout — no pipe-to-while |
| BCS0505 | No `++` anywhere; `VERBOSE+=1` used |
| BCS0601/BCS0606 | All `((flag)) && action` chains end with `||:` |
| BCS0602 | `die()` standard implementation; exit code 22 for invalid args |
| BCS0702 | All `>&2` placements correct **except line 48** (see above) |
| BCS0703 | `_msg()` uses `FUNCNAME[1]` dispatch; only used message levels defined |
| BCS0704 | `show_help()` uses `cat <<HELP` heredoc, not messaging functions |
| BCS0709 | `yn()` structure correct (REPLY local, prompt to stderr, single-char read) — except line 48 redirect order |
| BCS0801 | `while (($#)); do case $1 in` standard pattern |
| BCS0802 | `echo "$SCRIPT_NAME $VERSION"` — no word "version" |
| BCS0803 | `noarg "$@"` called before `shift` for all argument-taking options |
| BCS0805 | Bundling pattern `-[LaSmpPNnvqVh]?*` covers all valid short options |
| BCS0806 | `-p|-n` non-standard reuse suppressed with `#bcscheck disable=BCS0806` |
| BCS0901 | `[[ -d $path ]]` / `[[ -f $conf_file && -r $conf_file ]]` — correct file tests |
| BCS0906 | `readarray -t found_files < <(find ...)` — no pipe-to-while antipattern |
| BCS1002 | `declare -rx PATH=/usr/local/bin:/usr/bin:/bin` — secure PATH at top |
| BCS1003 | `IFS=',' read -ra` inline IFS set per-command; never global mutation |
| BCS1004 | No `eval` |
| BCS1005 | `rm ... --` before file arguments |
| BCS1202 | Comments add non-obvious context (readarray quirk, BCS0111 note, option disable reasons) |
| BCS1206 | `#shellcheck disable` and `#bcscheck disable` directives used correctly |

---

### Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0702 | core | **[ERROR]** | 48 | `echo >&2` — redirection must precede the command: use `>&2 echo` |

**Overall: 1 violation, 0 warnings.** The script is highly BCS-compliant; the single defect is a trivial one-character reorder in `yn()`.
bcs: ◉ Elapsed: 313s
bcs: ◉ Exit: 1
