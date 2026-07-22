# Design: `bcscheck` Claude Code Skill

**Date:** 2026-07-22
**Status:** Approved
**Deliverable:** `skills/bcscheck/SKILL.md` in the BCS repo

## Problem

`bcscheck` (the `bcs check` shim) is LLM-backed and slow (up to ~10 minutes per
script) and requires either API keys or a `claude` CLI round-trip. During a
Claude Code session, Claude itself is already a capable LLM with the standard
document on disk — a skill can perform the same audit natively, with no `bcs`
script involvement, no API keys, and near-instant turnaround.

The org already ships two bash-audit entry points:

- `/bcs-audit` — runs `shellcheck` + real `bcscheck` in parallel (still pays
  the backend cost).
- `/audit-bash` — embeds a hand-distilled rule summary that drifts from
  `data/*.md` as the standard evolves.

This skill fills the gap: Claude is the checker, and the **live assembled
standard** (`BASH-CODING-STANDARD.md`) is the only rule source. No drift, no
subprocess LLM.

## Use Cases

1. **In-session dev loop** — "check what we just wrote against BCS" with
   instant feedback while editing.
2. **Standalone audit** — `/bcscheck <file...>` as a bcscheck-style audit on
   any machine with Claude Code, regardless of API key configuration.

## Form and Location

A **pure prompt skill**: a single `SKILL.md` under `skills/bcscheck/` in the
BCS repo. No bundled executables — instructions only. Versioned with the
standard it references.

**Installation:** a `make install-skill` target (or documented `cp -r`) copies
`skills/bcscheck/` to `/etc/claude-code/.claude/skills/` for machine-wide
availability. The repo copy is authoritative.

**Triggering:** the frontmatter `description` targets phrases such as
"bcscheck this", "check against BCS", "BCS compliance check", and the
`/bcscheck` slash invocation. It explicitly defers to `/bcs-audit` when the
user wants the real CLI tools run, so the two never compete for triggers.

## Procedure (encoded in SKILL.md)

### 1. Resolve the standard

Same FHS search order as the `bcs` script, first match wins:

1. `./data/BASH-CODING-STANDARD.md` (development tree)
2. `/usr/local/share/yatti/BCS/data/BASH-CODING-STANDARD.md`
3. `/usr/share/yatti/BCS/data/BASH-CODING-STANDARD.md`

If none exists: stop with an error listing the searched paths.

### 2. Gather static context

- `shellcheck --format=json -x <file>` — feed the JSON to the audit as
  static-analysis context. If shellcheck is not installed, proceed and note
  the omission in the report.
- Grep the target for `#bcscheck disable=BCS....` directives.

### 3. Dispatch (hybrid)

- **Inline** when checking a single file that is already substantially in
  conversation context: read the standard directly and audit in-session.
- **Subagent fan-out** otherwise (multiple files, cold files, or an already
  long session): one `bash-expert` subagent per file, dispatched in parallel.
  Each subagent reads the standard, the target, and the shellcheck JSON, and
  returns findings only.

### 4. Audit rules

- Every finding must cite a real `BCS####` code present in the document just
  read. Never invent codes.
- Honour `#bcscheck disable=BCSdddd` with shellcheck-style scope (next
  command, function, or `{ ... }` block).
- Do not re-emit bare `SC####` findings unless they map to a specific BCS
  rule.
- Tier → severity mapping matches `cmd_check()`: `core` = **ERROR**,
  `recommended` and `style` = **WARN**.

### 5. Output format

Matches `bcscheck` text mode closely:

```
file.bash:42 — BCS0301 [WARN] — Static string uses double quotes; use single quotes
```

- Grouped by file, ERROR findings first.
- Per-file summary table (ERROR / WARN counts).
- Verdict line: **FAIL** if any core (ERROR) violation, else **PASS**.
- Report-only: never auto-fix (same constraint as `/bcs-audit`).

## Error Handling

| Condition | Behaviour |
|-----------|-----------|
| Standard not found | Stop; list the three searched paths |
| shellcheck missing | Proceed; note omission in report |
| Non-bash file argument | Warn and skip that file |
| No arguments and no obvious in-context target | Print usage and stop |

## Testing

Reuse `tests/fixtures/` — the labelled fixtures carry expected-BCS-code
pragmas and serve as the truth set. Acceptance: run `/bcscheck` on 2–3
fixtures and confirm each fixture's expected codes appear in the findings
(superset assertion, mirroring `test-check-fixtures.sh`). No automated CI
hook — the skill is a prompt artifact, not code.

## Out of Scope (YAGNI)

- `policy.conf` tier cascades and rule disabling
- JSON envelope output (`bcs check -j` equivalent)
- Result caching
- Model/effort selection and tier-filter flags

Anyone needing these uses the real `bcs check`.
