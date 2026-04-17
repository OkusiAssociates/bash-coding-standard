bcs: ◉ Backend 'claude' inferred from model 'balanced'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=claude)...
bcs: ◉ bcs check --model 'balanced' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
ShellCheck passed clean. `bcscheck` unavailable (model offline). I'll do the full manual audit now.

`★ Insight ─────────────────────────────────────`
`echo >&2` and `>&2 echo` are semantically identical in bash — both redirect stdout to stderr. The BCS mandates `>&2` at the start as a *visual convention*: a reader scanning for stderr output can spot the `>&2` prefix without reading to line-end. The constraint is about code readability, not correctness.
`─────────────────────────────────────────────────`

---

## BCS Compliance Audit: `cln`

**ShellCheck:** Clean — zero findings.
**bcscheck:** Unavailable (Ollama model offline). Manual audit follows.

---

### [ERROR] Findings

---

**BCS0702 — STDOUT vs STDERR Separation**
**Tier:** core | **Severity:** [ERROR]
**Line:** 48

```bash
# current — wrong
echo >&2

# fix — >&2 must be at the beginning
>&2 echo
```

BCS0702 mandates `>&2` at the *beginning* of the statement so reviewers can spot stderr redirections by scanning the left margin. Placing it at the end is a core-tier violation. Every other stderr line in the script correctly uses the leading form (`>&2 printf`, `>&2 _msg`); this one breaks the pattern.

---

### [WARN] Findings

---

**BCS0109 + BCS1203 — End Marker / Blank Lines**
**Tier:** style | **Severity:** [WARN]
**Lines:** 246–247

```
245  #fin
246  ← blank
247  ← blank
```

BCS0109 requires `#fin` to be the **absolute final line**. BCS1203 prohibits multiple consecutive blank lines anywhere in the file. Both rules are violated by the two trailing blanks after `#fin`. Fix: delete lines 246–247.

---

**BCS1204 — Section Comment Length**
**Tier:** style | **Severity:** [WARN]
**Line:** 21

```bash
# current — exceeds 2-4 word limit
# Messaging system - color-coded output with TTY detection

# fix — 2-4 words only
# Messaging system
```

BCS1204 requires section comments to be a single line of 2–4 words. "Messaging system - color-coded output with TTY detection" is nine words. The elaboration after the dash belongs in a regular explanatory comment if needed, not in the section header.

---

**BCS1202 — Inaccurate WHAT Comment**
**Tier:** style | **Severity:** [WARN]
**Line:** 22

```bash
# current — references non-existent function 'vecho'
# _msg: base formatter; vecho/warn/error: level wrappers; die: fatal exit; yn: yes/no prompt

# fix — correct the function name (or drop the comment)
# _msg: base formatter; info/warn/error: level wrappers; die: fatal exit; yn: yes/no prompt
```

The comment names `vecho`, but no such function exists in the script. The actual function is `info`. This is a BCS1202 violation (inaccurate WHAT comment) and creates a reader mismatch with `_msg()`'s `FUNCNAME[1]` dispatch block (line 32–36), which dispatches on `info`, `warn`, and `error`. Either correct `vecho` → `info`, or remove the comment entirely.

---

**BCS1201 — Line Length**
**Tier:** style | **Severity:** [WARN]
**Line:** 53

```bash
# current — ~128 chars, exceeds 120-char limit
decp() { declare -p "$@" 2>/dev/null | sed 's/^declare -[a-zA-Z-]* //'; }  # Print variable as name=value (help display & debug)

# fix — split the comment or drop it (decp is defined in BCS1211; the name is self-documenting)
decp() { declare -p "$@" 2>/dev/null | sed 's/^declare -[a-zA-Z-]* //'; }
```

BCS1201 caps lines at 120 characters (excluding URLs/paths). This line runs to ≈128. The inline trailing comment describing WHAT the function does is also redundant with the function body and with BCS1211's reference definition of `decp()`.

---

`★ Insight ─────────────────────────────────────`
The `FUNCNAME[1]` trick in `_msg()` is elegant: rather than receiving a log-level string argument, it reads its own bash call stack to determine which wrapper called it. This means adding a new level (e.g., `trace()`) requires zero changes to `_msg()` — just define the wrapper and add a case arm. The tradeoff is that `_msg()` cannot be called from another intermediate function without breaking the dispatch.
`─────────────────────────────────────────────────`

---

### Suppressed Rules (correctly exempted)

- **BCS0806** — suppressed via `#bcscheck disable=BCS0806` at line 169. `-n`/`-N` would normally conflict with standard dry-run options; the disable is documented and intentional.
- **SC2015** — suppressed file-wide; correctly documents the `((cond)) && action ||:` BCS0606 pattern.
- **SC2155** — suppressed per-line for `SCRIPT_PATH`; documented with rationale.

---

### Summary Table

| BCS Code | Tier | Severity | Line(s) | Description |
|----------|------|----------|---------|-------------|
| BCS0702 | core | **[ERROR]** | 48 | `echo >&2` — `>&2` must precede the command |
| BCS0109 | style | [WARN] | 246–247 | `#fin` is not the final line (two blank lines follow) |
| BCS1203 | style | [WARN] | 246–247 | Multiple consecutive blank lines at EOF |
| BCS1204 | style | [WARN] | 21 | Section comment exceeds 2–4 word limit (9 words) |
| BCS1202 | style | [WARN] | 22 | References non-existent function `vecho`; actual function is `info` |
| BCS1201 | style | [WARN] | 53 | Line ≈128 chars exceeds 120-char limit |

**Overall:** 1 core error, 5 style warnings. The script is otherwise highly compliant — clean ShellCheck, correct strict-mode setup, proper array handling, BCS0606-safe arithmetic, documented suppressions. The single [ERROR] is a positional redirect in `yn()` that contradicts every other stderr statement in the file.
bcs: ◉ Elapsed: 505s
bcs: ◉ Exit: 1
