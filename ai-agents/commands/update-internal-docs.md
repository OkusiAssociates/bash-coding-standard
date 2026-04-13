---
description: Update internal code documentation (comments, help text, messages) to match actual behavior
argument-hint: <file-or-directory>
allowed-tools: ["Read", "Edit", "Grep", "Glob"]
---

# Update Internal Documentation

Update the internal documentation for $ARGUMENTS ensuring it accurately reflects the actual code.

If no target was specified, identify the most relevant file/s from the current context.

All comments should be in English; comments in other languages should be translated to English.

## Scope — What to Update

Focus exclusively on documentation **inside the code**:

1. **Inline comments** — explain *why*, not *what*; remove stale/misleading comments
2. **Docstrings / function headers** — parameters, return values, side effects
3. **Usage / help text** — CLI `--help` output, usage strings, synopsis blocks
4. **User-facing messages** — error messages, log strings, status output
5. **Header blocks** — file-level description, author, version notes

## Process

1. **Read** the target file(s) thoroughly to understand actual behavior
2. **Identify discrepancies** between documentation and code reality
3. **Update** documentation to match — edit in place, do not rewrite code logic
4. **Verify** no documentation references removed/renamed functions, changed defaults, or obsolete behavior

## Principles

- **Accuracy over completeness** — wrong docs are worse than missing docs
- **Concise but comprehensive** — every word should earn its place
- **Dual audience** — useful for both human developers and AI agents reading the code
- **Preserve voice** — match the existing documentation style of the file
- Do NOT alter code logic, only documentation artifacts
