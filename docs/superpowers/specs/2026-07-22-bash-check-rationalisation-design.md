# Design: Bash-Checking Landscape Rationalisation

**Date:** 2026-07-22
**Status:** Approved
**Predecessor:** `2026-07-22-bcscheck-skill-design.md` (shipped the `bcscheck` skill)

## Problem

Seven bash-checking entry points exist for four genuine functions:

- `/bcs-check` (ai-agents) is a strict subset of `/bcs-audit` — both run the
  real `bcscheck` CLI; `/bcs-audit` adds parallel shellcheck and richer
  reporting.
- `/audit-bash` exists in two diverged copies: the hand-maintained enterprise
  copy (`/etc/claude-code/.claude/commands/audit-bash.md`, stale) and the
  ai-agents copy (fresher: frontmatter, corrected BCS0505 guidance).
- `/bcs-audit` (command + trigger skill) is hand-maintained in
  `/etc/claude-code`, unversioned, while newer assets (`bcscheck` skill) are
  repo-versioned and installed — a split-brain maintenance model.

## End State — one entry point per function

| Function | Sole entry point | Source of truth |
|----------|-----------------|-----------------|
| Static lint | `shellcheck` CLI | system package (untouched) |
| Deep BCS check (real CLI) | `bcscheck` / `bcs check` | `bcs` script (untouched) |
| In-session Claude-native check | `bcscheck` skill | `skills/bcscheck/SKILL.md` |
| Combined CLI audit (shellcheck ∥ bcscheck) | `/bcs-audit` command + trigger skill | `ai-agents/commands/bcs-audit.md` + `skills/bcs-audit/SKILL.md` |
| Whole-codebase audit | `/audit-bash` | `ai-agents/commands/audit-bash.md` |
| Shellcheck fixer | `/fix-shellcheck` | `ai-agents/commands/fix-shellcheck.md` (per-user, unchanged) |

**Deleted:** `ai-agents/commands/bcs-check.md` and every reference to it.
**Drift resolved:** stale enterprise `audit-bash.md` is overwritten by the
installed repo copy.

## Migration

1. **`/bcs-check` removal** — delete `ai-agents/commands/bcs-check.md`;
   purge references from `ai-agents/README.md`, `ai-agents/AGENTS.md`, and
   the top-level `README.md` AI Tooling section.
2. **`/bcs-audit` migration into the repo:**
   - `skills/bcs-audit/SKILL.md` — verbatim content of the current
     enterprise trigger skill (its cross-reference to
     `/etc/claude-code/.claude/commands/bcs-audit.md` remains valid
     post-install).
   - `ai-agents/commands/bcs-audit.md` — current enterprise command content
     plus the standard ai-agents frontmatter block (`description`,
     `argument-hint`, `allowed-tools`).
3. **Enterprise dir becomes install-target only** for bash-checking assets:
   nothing under `/etc/claude-code/.claude/{commands,skills}` relating to
   bash checking is hand-maintained after this change.

## Makefile

Rename `install-skill`/`uninstall-skill` (shipped earlier today; no external
users) to **`install-claude` / `uninstall-claude`**:

- Install every `skills/*/SKILL.md` → `$(SKILLDIR)/<name>/SKILL.md`
  (`SKILLDIR ?= /etc/claude-code/.claude/skills`).
- Install an explicit two-item command list — `bcs-audit.md`,
  `audit-bash.md` — from `ai-agents/commands/` →
  `CMDDIR ?= /etc/claude-code/.claude/commands`. Explicitly NOT the whole
  commands directory; remaining ai-agents commands stay per-user.
- `$(srcdir)`-anchored sources, TAB recipes, mode 644, help lines updated
  (column-20 description alignment), uninstall removes exactly what install
  created (the two command files and the two skill directories).

## Documentation

- README AI Tooling section rewritten around the six-row end-state table,
  including one-line differentiation between `bcscheck` skill, `/bcs-audit`,
  and `/audit-bash`. All `/bcs-check` references removed.
- Local `CLAUDE.md` (untracked, never committed) updated to match.
- Fold-in from the previous branch's deferred minors: soften the `bcscheck`
  skill's `/bcscheck <files>` usage strings to phrase-based wording, since a
  bare skill does not guarantee slash-command registration.

## Verification

- `make -n install-claude DESTDIR=/tmp/x` and `make -n uninstall-claude
  DESTDIR=/tmp/x` show the expected file set and nothing else.
- Real DESTDIR sandbox install; `diff -r` installed copies vs repo sources.
- `grep -rn 'bcs-check' README.md ai-agents/` → zero hits (excluding
  historical docs under `docs/superpowers/`).
- `make -n install` / `make help` — pre-existing targets unregressed.
- Existing test suite untouched (no shell code changes); not re-run.

## Out of Scope

- Other ai-agents commands (`bcs-codes`, `scaffold`, `update-docs`,
  `update-internal-docs`, `purpose-functionality-usage`, `fix-shellcheck`
  content).
- Non-bash enterprise commands (`audit-php`, `audit-python`, `chkpoint`, …).
- Any change to the `bcs` script or the standard itself.
- Actual `sudo make install-claude` on this machine — left to the user.
