# bcscheck Claude Code Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `skills/bcscheck/SKILL.md` — a pure prompt skill that performs bcscheck-equivalent BCS audits using only `data/BASH-CODING-STANDARD.md` — plus Makefile install targets and README documentation.

**Architecture:** Single SKILL.md in the BCS repo (versioned with the standard); `make install-skill` copies it to the enterprise skills dir. No executables ship. Hybrid dispatch: inline audit for one in-context file, `bash-expert` subagent fan-out otherwise.

**Tech Stack:** Claude Code skill (markdown + YAML frontmatter), GNU make, existing `tests/fixtures/` corpus for acceptance.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-22-bcscheck-skill-design.md` — authoritative.
- Report-only: the skill must never auto-fix.
- Every finding must cite a real `BCS####` code; tier mapping core=ERROR, recommended/style=WARN.
- Out of scope: policy.conf, JSON output, caching, model/effort flags.
- Never commit `CLAUDE.md` or `.claude/` (enterprise rule). `CLAUDE.md` is untracked in this repo — edit locally, do not `git add`.
- Commit author `Biksu Okusi <biksu@okusi.id>`; conventional commit style; no mention of claude in commit messages **except** as the product name "Claude Code skill" is acceptable — prefer wording like "native audit skill" to stay safe.
- Makefile uses TAB indentation (existing style), `DESTDIR`/`PREFIX` conventions.

---

### Task 1: Author `skills/bcscheck/SKILL.md`

**Files:**
- Create: `skills/bcscheck/SKILL.md`

**Interfaces:**
- Produces: the skill file consumed verbatim by Tasks 2–4. Directory name `bcscheck` and file name `SKILL.md` are load-bearing (Claude Code skill discovery).

- [ ] **Step 1: Create the file with exactly this content**

````markdown
---
name: bcscheck
description: Claude-native BCS compliance audit sourced ONLY from BASH-CODING-STANDARD.md — no bcs script, no API keys. Use for "bcscheck <file>", "check this against BCS", "BCS compliance check", "is this BCS compliant", or /bcscheck <files>. Do NOT use when the user wants the real CLI tools executed (shellcheck + bcscheck binaries) — that is /bcs-audit.
---

# bcscheck — Claude-native BCS compliance audit

Audit Bash scripts against the Bash Coding Standard. You (Claude) are the
checker. The ONLY rule source is the assembled standard document; never rely
on memory of BCS rules. Report findings; NEVER auto-fix.

## 1. Resolve the standard (first match wins)

```bash
for d in ./data /usr/local/share/yatti/BCS/data /usr/share/yatti/BCS/data; do
  [[ -f "$d"/BASH-CODING-STANDARD.md ]] && { echo "$d"/BASH-CODING-STANDARD.md; break; }
done
```

If no match: STOP and report the three searched paths. Do not audit from
memory.

## 2. Gather static context (per target file)

```bash
shellcheck --format=json -x "$file"   # if shellcheck missing: proceed, note omission in report
grep -n '#bcscheck disable=BCS' "$file"
```

CAUTION: a `#bcscheck disable=` string inside a heredoc, prompt string, or
documentation text is CONTENT, not a directive. Only column-anchored comment
lines in live code are directives.

## 3. Dispatch (hybrid)

- **Inline**: exactly one target file AND it is already substantially in the
  conversation context → Read the standard and audit in-session.
- **Subagent fan-out** (everything else — multiple files, cold files, long
  session): dispatch one `bash-expert` subagent per file, in parallel. Each
  subagent prompt must include: absolute path of the standard, absolute path
  of the target, the shellcheck JSON, the detected disable directives with
  the heredoc caution above, the audit rules (§4), and the finding-line
  format (§5). Instruct: "return raw findings only, one per line, or
  NO FINDINGS".

## 4. Audit rules (binding)

1. Every finding cites a `BCS####` code that exists as a `## BCS####` header
   in the standard just read. Never invent codes.
2. Severity from the rule's `**Tier:**` line: core → ERROR;
   recommended or style → WARN.
3. Honour `#bcscheck disable=BCSdddd` with shellcheck-directive scope: the
   named rule is suppressed for the next command, function, or `{ ... }`
   block. Do not report suppressed findings.
4. Do not re-emit `SC####` findings as such; use shellcheck JSON only as
   anchoring context, and report a finding only when it maps to a specific
   BCS rule.
5. Verify each cited line number against the file before reporting.
6. Do not manufacture findings to seem useful; compliant code gets silence.

## 5. Output format

One line per finding:

```
file.bash:42 — BCS0301 [WARN] — Static string uses double quotes; use single quotes
```

Group by file, ERROR before WARN. End with:

| file | ERROR | WARN |
|------|------:|-----:|

and a verdict line: **FAIL** if any ERROR (core) finding, else **PASS**.
State shellcheck status (clean / N findings / not installed) and which
suppressions were honoured.

## 6. Error handling

| Condition | Behaviour |
|-----------|-----------|
| Standard not found | Stop; list the three searched paths |
| shellcheck missing | Proceed; note omission in report |
| Non-bash file argument | Warn and skip that file |
| No arguments, no obvious in-context target | Print usage `/bcscheck <file...>` and stop |

## 7. Boundaries

- Report-only. Never edit the target. Offer fixes only as a follow-up the
  user must request.
- policy.conf, JSON output, caching, model selection: out of scope — direct
  the user to the real `bcs check` for those.
````

- [ ] **Step 2: Structural verification**

Run: `head -5 skills/bcscheck/SKILL.md`
Expected: `---`, `name: bcscheck`, then a `description:` line. Also run
`grep -c 'BCS####' skills/bcscheck/SKILL.md` — expected ≥ 2.

- [ ] **Step 3: Commit**

```bash
git add skills/bcscheck/SKILL.md
git commit -m "feat(skills): native BCS audit skill sourced from BASH-CODING-STANDARD.md"
```

---

### Task 2: Makefile install/uninstall targets

**Files:**
- Modify: `Makefile` (variables block ~line 5-8; after `uninstall:` block ending ~line 90; `help:` body ~line 115+)

**Interfaces:**
- Consumes: `skills/bcscheck/SKILL.md` from Task 1.
- Produces: `make install-skill`, `make uninstall-skill` targets; `SKILLDIR` variable.

- [ ] **Step 1: Add variable** — in the variables block after `SHAREDIR ?= $(PREFIX)/share/yatti/BCS`:

```make
SKILLDIR ?= /etc/claude-code/.claude/skills
```

- [ ] **Step 2: Add targets** — after the `uninstall:` recipe (keep TAB indentation):

```make
install-skill:
	install -d $(DESTDIR)$(SKILLDIR)/bcscheck
	install -m 644 skills/bcscheck/SKILL.md $(DESTDIR)$(SKILLDIR)/bcscheck/SKILL.md
	@echo 'Installed bcscheck skill to $(DESTDIR)$(SKILLDIR)/bcscheck'

uninstall-skill:
	rm -rf $(DESTDIR)$(SKILLDIR)/bcscheck
	@echo 'Removed bcscheck skill from $(DESTDIR)$(SKILLDIR)'
```

- [ ] **Step 3: Add help lines** — inside the `help:` recipe, after the `install` line:

```make
	@echo '  install-skill    Install bcscheck Claude Code skill to $(SKILLDIR)'
	@echo '  uninstall-skill  Remove bcscheck Claude Code skill'
```

- [ ] **Step 4: Dry-run verification**

Run: `make -n install-skill DESTDIR=/tmp/x`
Expected: `install -d /tmp/x/etc/claude-code/.claude/skills/bcscheck` then the `install -m 644 ...` line. Then run `make -n uninstall-skill DESTDIR=/tmp/x` and `make help | grep skill` (expect both help lines).

- [ ] **Step 5: Sandbox install test**

```bash
make install-skill DESTDIR=/tmp/claude-1000/-ai-scripts-Okusi-BCS/skilltest
test -f /tmp/claude-1000/-ai-scripts-Okusi-BCS/skilltest/etc/claude-code/.claude/skills/bcscheck/SKILL.md && echo OK
rm -rf /tmp/claude-1000/-ai-scripts-Okusi-BCS/skilltest
```

Expected: `OK`. (Real install to `/etc/claude-code` needs sudo — leave to the user.)

- [ ] **Step 6: Commit**

```bash
git add Makefile
git commit -m "build: install-skill/uninstall-skill targets for the native audit skill"
```

---

### Task 3: Fixture acceptance run

**Files:**
- Test: `tests/fixtures/01-missing-strict-mode.sh`, `tests/fixtures/14-uses-eval.sh`, one file under `tests/fixtures/clean/`

**Interfaces:**
- Consumes: the SKILL.md procedure from Task 1, executed by the agent (not a shell script).

- [ ] **Step 1: Read expected codes**

Run: `grep -h 'bcs-fixture-expect:' tests/fixtures/01-missing-strict-mode.sh tests/fixtures/14-uses-eval.sh tests/fixtures/clean/*.sh | head`
Expected: `BCS0101` for 01; the listed code(s) for 14; empty expect pragma for the clean fixture.

- [ ] **Step 2: Execute the skill procedure** on the three fixtures exactly as SKILL.md §1–§5 prescribes (resolve standard → shellcheck JSON → subagent fan-out, one per fixture, in parallel).

- [ ] **Step 3: Assert (superset rule, mirroring `test-check-fixtures.sh`)**

- Fixture 01 findings include `BCS0101`.
- Fixture 14 findings include its expected code(s) from Step 1.
- Clean fixture: zero findings (any finding = false positive = acceptance FAIL).

If an assertion fails: adjust SKILL.md audit-rule wording (not the fixtures), re-run the failing fixture, and amend the Task 1 commit rationale in a follow-up commit.

- [ ] **Step 4: Record result** — append a dated acceptance note (fixtures used, pass/fail) to the bottom of `docs/superpowers/plans/2026-07-22-bcscheck-skill.md` and commit:

```bash
git add docs/superpowers/plans/2026-07-22-bcscheck-skill.md
git commit -m "test(skills): fixture acceptance results for native audit skill"
```

---

### Task 4: Documentation

**Files:**
- Modify: `README.md` (inside `## AI Tooling (`ai-agents/`)` section, ~line 286)
- Modify: `CLAUDE.md` (untracked — edit only, never `git add`)

**Interfaces:**
- Consumes: final target names from Task 2 (`install-skill`, `uninstall-skill`).

- [ ] **Step 1: README subsection** — append inside the AI Tooling section:

```markdown
### Claude Code skill (`skills/bcscheck/`)

A pure prompt skill that lets Claude Code audit Bash scripts against
`BASH-CODING-STANDARD.md` directly — no `bcs` script, no API keys. Honours
`#bcscheck disable=` directives and uses shellcheck JSON as static context.
Install machine-wide with `sudo make install-skill`; remove with
`sudo make uninstall-skill`. For policy.conf tiers, JSON output, or caching,
use the real `bcs check`.
```

- [ ] **Step 2: CLAUDE.md note** — add a short paragraph in the repo `CLAUDE.md` near the `check` subcommand docs stating that `skills/bcscheck/SKILL.md` is the Claude-native audit path and is versioned with the standard. Do NOT `git add CLAUDE.md`.

- [ ] **Step 3: Verify and commit**

Run: `grep -n 'install-skill' README.md Makefile | head` — expect hits in both.

```bash
git add README.md
git commit -m "docs: document the native audit skill and its install targets"
```

---

## Self-Review Notes

- Spec coverage: resolution (§1/Task 1), static context (§2/Task 1), hybrid dispatch (§3/Task 1), audit rules incl. heredoc caution (§4/Task 1), output format (§5/Task 1), error table (§6/Task 1), install story (Task 2), fixture acceptance (Task 3), YAGNI boundary (§7/Task 1 + README). No gaps.
- Placeholders: none; SKILL.md content is complete and verbatim.
- Name consistency: `bcscheck` dir name, `SKILLDIR`, `install-skill`/`uninstall-skill` used identically across Tasks 1, 2, 4.

---

## Acceptance Record — 2026-07-22

Task 3 fixture acceptance executed per SKILL.md §1–§5 (standard resolved at
`./data/BASH-CODING-STANDARD.md`; shellcheck JSON clean for all three targets;
no disable directives present; three parallel `bash-expert` subagent audits):

| fixture | expected | result | verdict |
|---------|----------|--------|---------|
| `tests/fixtures/01-missing-strict-mode.sh` | BCS0101 | `01-missing-strict-mode.sh:1 — BCS0101 [ERROR]` | PASS |
| `tests/fixtures/14-uses-eval.sh` | BCS1004 | `14-uses-eval.sh:13 — BCS1004 [ERROR]` | PASS |
| `tests/fixtures/clean/01-greet.sh` | (none) | NO FINDINGS | PASS |

Superset assertion satisfied for both gated fixtures; zero false positives on
the clean fixture. Acceptance: **PASS 3/3**.
