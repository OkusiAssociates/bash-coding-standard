---
description: Run bcscheck against a Bash script and report BCS compliance findings
argument-hint: <file>
allowed-tools: ["Bash", "Read"]
---

# BCS Compliance Check

Run `bcscheck` against **$ARGUMENTS** and interpret the output.

If `$ARGUMENTS` is empty, ask the user which file to check. Never run `bcscheck` without
an explicit target.

## Procedure

1. **Validate the target**
   - Confirm the path exists.
   - Confirm it looks like a Bash script (shebang, `.sh` extension, or `file` reports a
     shell script). Refuse to check binaries.

2. **Run the checker**
   ```bash
   bcscheck "$ARGUMENTS"
   ```
   Defaults come from `~/.config/bcs/bcs.conf`. Do not override `-m`, `-e`, or `-s`
   unless the user has explicitly asked for a different model, effort, or strict mode.

3. **Parse the findings.** Group by severity, keeping the BCS code on every finding.

4. **Report.**

   ```
   ## BCS Check: <file>

   **Verdict**: pass | warnings | fail
   **Violations**: <count>
   **Model / Effort**: <as reported by bcscheck>

   ### Critical
   - BCS#### @ line NN -- <quoted code>
     Fix: <one-liner>

   ### High / Medium / Low
   - ...
   ```

## Rules

**Always do:**
- Use the `bcscheck` shim. Never call `bcs check` directly.
- Preserve the BCS code in every finding so the user can look it up.
- Escalate any BCS1000 (security) finding to Critical regardless of what the tool reports.

**Never do:**
- Auto-apply fixes without confirmation from the user.
- Rewrite unrelated lines as drive-by cleanup.
- Silently fall back to manual review if `bcscheck` is missing -- report the missing tool.

## Escalation Hints

- If most findings are shellcheck-driven: suggest `/fix-shellcheck`.
- If the script is missing most of the structural skeleton: suggest `/scaffold` to start
  from a clean BCS template.
- For multi-file audits: recommend the `bcs-auditor` subagent for aggregated reporting.
