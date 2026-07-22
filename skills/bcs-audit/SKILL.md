---
name: bcs-audit
description: Use when the user asks to audit, lint, BCS-check, shellcheck, or bcscheck Bash scripts. Triggers on phrases like "bcs audit", "bash audit", "lint this script", "shellcheck these files", "run bcscheck", "check my bash". Invokes the /bcs-audit slash command which runs shellcheck and bcscheck in parallel and emits severity-tagged findings with file:line citations.
---

# bcs-audit

When triggered, invoke the `/bcs-audit` slash command, passing the file paths the user named.

## Behavior

1. If the user named files explicitly, pass them as arguments to `/bcs-audit`.
2. If the user said something like "audit this" without filenames:
   - If exactly one `.bash` / `.sh` file is being discussed in context, use that.
   - Otherwise, ask which files.
3. Do not run `shellcheck` or `bcscheck` directly here — defer to the slash command so output formatting and parallelism are consistent.

## Cross-references

- Procedure: `/etc/claude-code/.claude/commands/bcs-audit.md`
- BCS rules: `/etc/claude-code/.claude/rules/bash-coding-standard.md`
- BCS data: `/usr/share/yatti/BCS/data/` (or `/usr/local/share/yatti/BCS/data/`)
