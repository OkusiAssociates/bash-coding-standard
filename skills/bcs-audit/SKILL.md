---
name: bcs-audit
description: Opt-in audit running the REAL shellcheck + bcscheck CLI binaries in parallel (bcscheck is LLM-backed, up to ~10 min/file). Use ONLY when the user explicitly asks for the CLI tools or types /bcs-audit; for ordinary BCS checks use the bcscheck skill.
---

# bcs-audit — Bash audit (shellcheck + bcscheck binaries in parallel)

**Args**: one or more `.bash` / `.sh` file paths. If the user said "audit this" without filenames: use the single shell file in context if unambiguous, otherwise ask which files.

## Procedure

1. **Validate input.** If no file paths were given and none is unambiguous in context, print:
   ```
   Usage: /bcs-audit <file1> [file2 …]
   ```
   and stop.

2. **Existence check.** For each path, `test -f <path>`. Drop missing paths and warn.

3. **Warn the user up front** that `bcscheck` uses an LLM backend and may take up to ~10 minutes per file. Confirm before continuing if more than 2 files were listed.

4. **Run audits in parallel.** In a single tool-use block, dispatch one Bash call per `(file, tool)` pair:
   - `shellcheck -f gcc <file>`
   - `bcscheck <file>`

5. **Tag findings by severity:**
   - **bcscheck** prints its own tag on every finding line
     (`[ERROR|WARN] BCSxxxx line N: …`). Take the tag as printed; never
     re-grade a finding. It has no INFO level. The answer
     `No BCS violations found.` means zero findings. Lines prefixed `bcs: ◉`
     are diagnostics (backend, elapsed, exit), not findings.
   - **shellcheck**: `error:` → ERROR; `warning:` → WARN; `note:` → INFO.

6. **Cite every finding** as `<file>:<line> — <code> — <message>`. Quote messages exactly as emitted by the tool — do not paraphrase.

7. **Group output:** by file, then by severity (ERROR → WARN → INFO). End with a summary table:

   | file | ERROR | WARN | INFO |
   |------|------:|-----:|-----:|

8. **Exit code reporting.** Note shellcheck/bcscheck exit codes per file. Non-zero → flag in summary. For bcscheck, 0 = no ERROR finding, 1 = at least one ERROR finding, anything higher = the check itself failed (backend, timeout, empty answer) and is **not** a verdict on the script.

## Constraints
- Do NOT auto-fix. Report only.
- Do NOT batch all files into a single tool call — parallelism matters because `bcscheck` is slow.
- Quote findings exactly.

## Cross-references

- BCS rules: `/etc/claude-code/.claude/rules/bash-coding-standard.md`
- BCS data: `/usr/share/yatti/BCS/data/` (or `/usr/local/share/yatti/BCS/data/`)
