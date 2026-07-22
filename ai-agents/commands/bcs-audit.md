---
description: Parallel shellcheck + bcscheck audit on listed bash files; severity-tagged findings with file:line citations
argument-hint: <file1> [file2 ...]
allowed-tools: ["Bash", "Read"]
---

# /bcs-audit — Bash audit (shellcheck + bcscheck in parallel)

**Args**: `$ARGUMENTS` — one or more `.bash` / `.sh` file paths.

## Procedure

1. **Validate input.** If `$ARGUMENTS` is empty, print:
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
   - **ERROR** — shellcheck `error:` lines; BCS hard-rule violations.
   - **WARN** — shellcheck `warning:` / `note:` (style); BCS soft-rule violations.
   - **INFO** — `info:` notes, advisory BCS hints.

6. **Cite every finding** as `<file>:<line> — <code> — <message>`. Quote messages exactly as emitted by the tool — do not paraphrase.

7. **Group output:** by file, then by severity (ERROR → WARN → INFO). End with a summary table:

   | file | ERROR | WARN | INFO |
   |------|------:|-----:|-----:|

8. **Exit code reporting.** Note shellcheck/bcscheck exit codes per file. Non-zero → flag in summary.

## Constraints
- Do NOT auto-fix. Report only.
- Do NOT batch all files into a single tool call — parallelism matters because `bcscheck` is slow.
- Quote findings exactly. Errors quoted exact (per caveman rules).
