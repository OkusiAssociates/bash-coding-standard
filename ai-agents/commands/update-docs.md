---
description: Update external documentation (READMEs, guides, doc files) to match actual code
argument-hint: <file-or-directory>
allowed-tools: ["Read", "Edit", "Grep", "Glob"]
---

# Update External Documentation

Update the external documentation for $ARGUMENTS ensuring it accurately reflects the actual code.

If no target was specified, identify the most relevant documentation file from the current context.

## Scope — What to Update

Focus exclusively on **standalone documentation files**:

1. **README files** — project overview, setup instructions, usage examples
2. **Guide/reference docs** — API docs, architecture docs, developer guides
3. **Configuration docs** — environment variables, settings, deployment notes
4. **Changelog/release notes** — version history, migration notes

Do NOT update in-code documentation (comments, docstrings, help text) — use `/update-internal-docs` for that.

## Process

1. **Read** the source code to understand actual behavior
2. **Read** the target documentation file(s)
3. **Identify discrepancies** between documentation and code reality
4. **Update** documentation to match — keep structure, fix content
5. **Verify** no references to removed/renamed functions, changed defaults, or obsolete behavior

## Style

- Synopsis/quick-start at top
- Use tables for structured data (commands, options, exit codes)
- Group examples by use case, not alphabetically
- Remove redundant verbosity
- Do not document files listed in `.gitignore`

## Principles

- **Accuracy over completeness** — wrong docs are worse than missing docs
- **Concise but comprehensive** — every word should earn its place
- **Dual audience** — useful for both human developers and AI agents reading the code
- **Preserve voice** — match the existing documentation style of the file
- Do NOT alter code logic, only documentation artifacts
