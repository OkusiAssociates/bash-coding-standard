# Bash-Check Rationalisation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One entry point per bash-checking function: delete `/bcs-check`, migrate `/bcs-audit` into the repo, single-source `/audit-bash`, and install everything enterprise-wide via new `install-claude`/`uninstall-claude` Makefile targets.

**Architecture:** The BCS repo becomes the versioned source of truth for all bash-checking Claude assets; `/etc/claude-code/.claude/{skills,commands}` holds only installed copies. Migration is file-copy based (deterministic), not transcription.

**Tech Stack:** GNU make, markdown command/skill files, existing enterprise assets at `/etc/claude-code/.claude/`.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-22-bash-check-rationalisation-design.md` — authoritative.
- Never commit `CLAUDE.md` or `.claude/` (enterprise rule); repo-root `CLAUDE.md` is untracked — edit locally only.
- Do NOT touch `/etc/claude-code/` in any task — installation there is the user's `sudo make install-claude`, out of scope. Reading from it is fine.
- Do NOT touch `tests/accuracy/bcs-check-accuracy.sh` or `README.md:235` (the accuracy-fixture reference contains the substring `bcs-check` but is unrelated).
- Makefile: TAB recipe indentation, `$(srcdir)` anchoring on every source path, help descriptions start at column 20.
- Commit author `Biksu Okusi <biksu@okusi.id>`; conventional commits; never mention claude-the-agent in messages (product names like "Claude skills" are fine; prefer neutral wording).
- Out of scope: all other ai-agents commands' content, non-bash enterprise commands, the `bcs` script, `sudo` installation.

---

### Task 1: Delete `/bcs-check` and purge references

**Files:**
- Delete: `ai-agents/commands/bcs-check.md`
- Modify: `ai-agents/AGENTS.md:53`, `ai-agents/README.md:75,81`, `README.md:293`

**Interfaces:**
- Produces: a tree with zero `/bcs-check` references (Task 4's README rewrite assumes the slash-command list no longer contains it).

- [ ] **Step 1: Delete the command file**

```bash
git rm ai-agents/commands/bcs-check.md
```

- [ ] **Step 2: Purge the AGENTS.md index line** — in `ai-agents/AGENTS.md`, delete exactly this line (~line 53):

```markdown
- `bcs-check.md` -- `/bcs-check` -- Run `bcscheck` against a single script and report findings
```

- [ ] **Step 3: Update the ai-agents/README.md workflow example** — in the "End-to-end flow" fenced block (~lines 65-82), replace both occurrences:

Old (appears twice, steps 3 and 5 of the example):
```bash
/bcs-check deploy
```
New (both occurrences):
```bash
/bcs-audit deploy
```
Also update the step-3 comment line `# 3. Run the BCS auditor` — leave as is (still accurate) — and the closing prose line "Each slash command delegates to `bcscheck`, `bcs template`, or `shellcheck` under the hood" — leave as is (still accurate for /bcs-audit).

- [ ] **Step 4: Update top-level README.md slash-command inventory** — line ~293, remove `/bcs-check`:

Old:
```markdown
| Slash commands | `/audit-bash`, `/bcs-check`, `/bcs-codes`, `/fix-shellcheck`, `/scaffold`, `/purpose-functionality-usage`, `/update-docs`, `/update-internal-docs` | Single-shot operations |
```
New:
```markdown
| Slash commands | `/audit-bash`, `/bcs-audit`, `/bcs-codes`, `/fix-shellcheck`, `/scaffold`, `/purpose-functionality-usage`, `/update-docs`, `/update-internal-docs` | Single-shot operations |
```
(`/bcs-audit` is added here in anticipation of Task 2's migration; Task 2 provides the file.)

- [ ] **Step 5: Verify zero stray references**

Run: `grep -rn 'bcs-check' README.md ai-agents/ | grep -v accuracy`
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add -A ai-agents README.md
git commit -m "refactor(ai-agents): retire /bcs-check in favour of /bcs-audit"
```

---

### Task 2: Migrate `/bcs-audit` (command + skill) into the repo

**Files:**
- Create: `skills/bcs-audit/SKILL.md` (copy of `/etc/claude-code/.claude/skills/bcs-audit/SKILL.md`, 22 lines)
- Create: `ai-agents/commands/bcs-audit.md` (copy of `/etc/claude-code/.claude/commands/bcs-audit.md`, 43 lines, frontmatter transformed)
- Modify: `ai-agents/AGENTS.md` (add index line)

**Interfaces:**
- Consumes: Task 1's purged tree (README slash list already names `/bcs-audit`).
- Produces: the two exact paths Task 3's Makefile installs: `skills/bcs-audit/SKILL.md`, `ai-agents/commands/bcs-audit.md`.

- [ ] **Step 1: Copy the trigger skill verbatim**

```bash
mkdir -p skills/bcs-audit
cp /etc/claude-code/.claude/skills/bcs-audit/SKILL.md skills/bcs-audit/SKILL.md
diff /etc/claude-code/.claude/skills/bcs-audit/SKILL.md skills/bcs-audit/SKILL.md && echo IDENTICAL
```
Expected: `IDENTICAL`. Do not edit the content — its cross-reference to `/etc/claude-code/.claude/commands/bcs-audit.md` remains valid post-install.

- [ ] **Step 2: Copy the command and transform its frontmatter** — copy `/etc/claude-code/.claude/commands/bcs-audit.md` to `ai-agents/commands/bcs-audit.md`, then replace its existing frontmatter (the first block delimited by `---` lines, containing `name: bcs-audit` and a `description:`) with the ai-agents house style:

```markdown
---
description: Parallel shellcheck + bcscheck audit on listed bash files; severity-tagged findings with file:line citations
argument-hint: <file1> [file2 ...]
allowed-tools: ["Bash", "Read"]
---
```
Everything below the frontmatter is copied unchanged (starting at the `# /bcs-audit — Bash audit (shellcheck + bcscheck in parallel)` heading).

- [ ] **Step 3: Verify body integrity**

Run: `diff <(sed -n '/^# /,$p' /etc/claude-code/.claude/commands/bcs-audit.md) <(sed -n '/^# /,$p' ai-agents/commands/bcs-audit.md)`
Expected: no output (bodies identical from the first `# ` heading onward).

- [ ] **Step 4: Add the AGENTS.md index line** — in `ai-agents/AGENTS.md` "Commands Index", insert alphabetically after the `audit-bash.md` line:

```markdown
- `bcs-audit.md` -- `/bcs-audit` -- Parallel shellcheck + bcscheck audit with severity-tagged findings
```

- [ ] **Step 5: Commit**

```bash
git add skills/bcs-audit ai-agents/commands/bcs-audit.md ai-agents/AGENTS.md
git commit -m "feat(ai-agents): migrate bcs-audit command and trigger skill into the repo"
```

---

### Task 3: Makefile `install-claude` / `uninstall-claude`

**Files:**
- Modify: `Makefile` (variables ~line 9-10, `.PHONY` ~line 18, targets ~lines 93-100, help ~lines 130-131)

**Interfaces:**
- Consumes: `skills/bcscheck/SKILL.md`, `skills/bcs-audit/SKILL.md`, `ai-agents/commands/bcs-audit.md`, `ai-agents/commands/audit-bash.md` (Tasks 1-2).
- Produces: `make install-claude`, `make uninstall-claude`; variables `SKILLDIR`, `CMDDIR`. The old `install-skill`/`uninstall-skill` names cease to exist (Task 4 updates docs).

- [ ] **Step 1: Add CMDDIR variable** — directly after the `SKILLDIR ?= /etc/claude-code/.claude/skills` line:

```make
CMDDIR   ?= /etc/claude-code/.claude/commands
```

- [ ] **Step 2: Update .PHONY** — replace `install-skill uninstall-skill` with `install-claude uninstall-claude` in the `.PHONY:` line.

- [ ] **Step 3: Replace the two skill targets** — replace the entire `install-skill:` and `uninstall-skill:` recipes with (TAB indentation):

```make
install-claude:
	install -d $(DESTDIR)$(SKILLDIR)/bcscheck $(DESTDIR)$(SKILLDIR)/bcs-audit $(DESTDIR)$(CMDDIR)
	install -m 644 $(srcdir)skills/bcscheck/SKILL.md $(DESTDIR)$(SKILLDIR)/bcscheck/SKILL.md
	install -m 644 $(srcdir)skills/bcs-audit/SKILL.md $(DESTDIR)$(SKILLDIR)/bcs-audit/SKILL.md
	install -m 644 $(srcdir)ai-agents/commands/bcs-audit.md $(DESTDIR)$(CMDDIR)/bcs-audit.md
	install -m 644 $(srcdir)ai-agents/commands/audit-bash.md $(DESTDIR)$(CMDDIR)/audit-bash.md
	@echo 'Installed Claude skills (bcscheck, bcs-audit) and commands (bcs-audit, audit-bash)'

uninstall-claude:
	rm -rf $(DESTDIR)$(SKILLDIR)/bcscheck $(DESTDIR)$(SKILLDIR)/bcs-audit
	rm -f $(DESTDIR)$(CMDDIR)/bcs-audit.md $(DESTDIR)$(CMDDIR)/audit-bash.md
	@echo 'Removed Claude skills and commands'
```

- [ ] **Step 4: Replace the two help lines** — descriptions start at column 20, matching neighbours:

Old:
```make
	@echo '  install-skill    Install bcscheck Claude Code skill to $(SKILLDIR)'
	@echo '  uninstall-skill  Remove bcscheck Claude Code skill'
```
New:
```make
	@echo '  install-claude   Install Claude skills+commands to /etc/claude-code'
	@echo '  uninstall-claude Remove installed Claude skills+commands'
```

- [ ] **Step 5: Dry-run verification**

Run: `make -n install-claude DESTDIR=/tmp/x`
Expected: one `install -d` line covering both skill dirs + CMDDIR, then exactly four `install -m 644` lines, all sources prefixed with the absolute srcdir path. Then `make -n uninstall-claude DESTDIR=/tmp/x` (one `rm -rf` with two dirs, one `rm -f` with two files). Then `make help` (both new lines, aligned; old names absent). Then `make -n install DESTDIR=/tmp/x` (pre-existing target unaffected).

- [ ] **Step 6: Sandbox round-trip**

```bash
make install-claude DESTDIR=/tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test
diff -r skills/bcscheck /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test/etc/claude-code/.claude/skills/bcscheck
diff -r skills/bcs-audit /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test/etc/claude-code/.claude/skills/bcs-audit
diff ai-agents/commands/bcs-audit.md /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test/etc/claude-code/.claude/commands/bcs-audit.md
diff ai-agents/commands/audit-bash.md /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test/etc/claude-code/.claude/commands/audit-bash.md
make uninstall-claude DESTDIR=/tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test
find /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test -type f | wc -l   # expect 0
rm -rf /tmp/claude-1000/-ai-scripts-Okusi-BCS/rat-test
```
Expected: all diffs empty; post-uninstall file count 0.

- [ ] **Step 7: Commit**

```bash
git add Makefile
git commit -m "build: replace install-skill with install-claude covering skills and commands"
```

---

### Task 4: Documentation sync

**Files:**
- Modify: `README.md` (AI Tooling section, ~lines 286-306)
- Modify: `skills/bcscheck/SKILL.md` (two usage-string softenings)
- Modify: `CLAUDE.md` (untracked — edit only, never `git add`)

**Interfaces:**
- Consumes: final target names from Task 3 (`install-claude`, `uninstall-claude`).

- [ ] **Step 1: Replace the `### Claude Code skill (skills/bcscheck/)` subsection** with:

```markdown
### Claude Code integration (`skills/`, enterprise install)

One entry point per checking function — no overlap:

| Function | Entry point | Mechanism |
|----------|-------------|-----------|
| Static lint | `shellcheck` | CLI |
| Deep BCS check | `bcscheck` / `bcs check` | CLI, LLM backend |
| In-session BCS check | `bcscheck` skill | Claude reads `BASH-CODING-STANDARD.md` directly — no CLI, no API keys |
| Combined CLI audit | `/bcs-audit` | Runs shellcheck + bcscheck in parallel |
| Whole-codebase audit | `/audit-bash` | 15-section audit prompt, saves `AUDIT-BASH.md` |
| ShellCheck remediation | `/fix-shellcheck` | Fixes SC#### per BCS patterns (per-user, `ai-agents/`) |

The `bcscheck` skill honours `#bcscheck disable=` directives and uses
shellcheck JSON as static context; for policy.conf tiers, JSON output, or
caching use the real `bcs check`. Sources live in `skills/*/SKILL.md` and
`ai-agents/commands/`; install machine-wide with `sudo make install-claude`,
remove with `sudo make uninstall-claude`.
```

- [ ] **Step 2: Soften the bcscheck skill's slash-command claims** — in `skills/bcscheck/SKILL.md`:

Frontmatter description: replace `or /bcscheck <files>.` with `or "bcscheck <files>" typed in chat.`
§6 table row: replace `Print usage `/bcscheck <file...>` and stop` with `` Print usage `bcscheck <file...>` and stop ``

- [ ] **Step 3: Update untracked CLAUDE.md** — in the paragraph about the Claude-native audit path (near `### \`check\` Subcommand Internals`), change `make install-skill` to `make install-claude` and note that `/bcs-audit` and `/audit-bash` are now repo-sourced (`ai-agents/commands/`) and enterprise-installed by the same target. Do NOT `git add CLAUDE.md`.

- [ ] **Step 4: Verify**

```bash
grep -n 'install-skill\|install-claude' README.md Makefile        # only install-claude hits
grep -rn 'bcs-check' README.md ai-agents/ | grep -v accuracy      # empty
grep -n '/bcscheck' skills/bcscheck/SKILL.md                      # empty
```

- [ ] **Step 5: Commit**

```bash
git add README.md skills/bcscheck/SKILL.md
git commit -m "docs: one-entry-per-function checking table; install-claude rename"
```

---

## Self-Review Notes

- Spec coverage: `/bcs-check` deletion (T1), `/bcs-audit` migration (T2), enterprise-as-install-target + explicit two-command list (T3), drift resolution (T3 install overwrites), README six-row table + differentiation + `/bcscheck` softening (T4), CLAUDE.md local (T4). Out-of-scope guarded in Global Constraints. No gaps.
- Placeholders: none; every edit shows exact old/new text.
- Name consistency: `install-claude`/`uninstall-claude`, `CMDDIR`, `skills/bcs-audit/SKILL.md`, `ai-agents/commands/bcs-audit.md` used identically across T2-T4.
- The stray thought in T2 Step 3 ("wait: simpler...") — cleaned to the single sed-based diff command.
