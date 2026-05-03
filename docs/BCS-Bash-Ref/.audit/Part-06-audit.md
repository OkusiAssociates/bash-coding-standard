<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VI — Redirection and Pipelines: Audit

Date: 2026-05-03
Priority: P2 (language proper)
Files audited: 16 chapters + 1 index = 17

## Summary

Redirection is one of the densest subsystems in bash. The skeleton coverage is broad — every operator family is named — but the chapters are written almost entirely as *operator inventories* with no executable demonstrations. For a reference document, that is inadequate: half of bash's redirection operators have semantics that cannot be inferred from a one-liner ("`2>&1 >file` differs from `>file 2>&1`" is named but never traced). 13/16 chapters need PROMOTE. The 3 that do not (input/output cheat-sheets and the `|&` shorthand) are tight tables that read well as cheat-sheets.

The Part is **the worst code-block desert in this shard** — 0 code blocks across 16 chapters in a Part whose subject matter is fundamentally about composing operators.

## Top-5 findings

1. **[major]** `08_Here-documents.md` lacks any heredoc body example. The quoted-vs-unquoted delimiter rule is unverifiable from the prose alone. This is the single highest-impact omission in the Part.
2. **[major]** `11_Order-of-evaluation.md` names the `>file 2>&1` vs `2>&1 >file` contrast but never traces the fd-table state through it. The reference reader still has to consult an external resource.
3. **[major]** `13_Pipelines.md` mentions `PIPESTATUS[]` but never shows it. A pipelines reference without a `PIPESTATUS` example is not a reference.
4. **[major]** `15_pipefail-semantics.md` calls itself "the strict-mode trio" then provides no demonstration of the trio's interaction. Strict-mode framing claim is not earned.
5. **[minor]** `12_exec-for-fd-manipulation.md` mentions `varredir_close` (Bash 5.2) without explaining what variable-scope it ties to — this is a Bash 5.2 feature that warrants 2-3 lines plus an example.

## Per-leaf table

| File | Coverage | Clarity-H | Clarity-AI | XRefs | Strict | Example | Self-cont | Disp |
|------|----------|-----------|------------|-------|--------|---------|-----------|------|
| index.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 01_The-fd-table-from-Bashs-perspective.md | med | high | med | med | low | no | yes | ENRICH |
| 02_Input-redirection.md | high | high | med | low | n-a | no | yes | ENRICH |
| 03_Output-redirection.md | high | high | med | low | n-a | no | yes | ENRICH |
| 04_Stderr-redirection-and-merging.md | high | high | low | med | low | no | no | PROMOTE |
| 05_Reading-and-writing.md | low | med | low | low | low | no | no | PROMOTE |
| 06_Duplicating-fds.md | med | med | low | med | low | no | no | PROMOTE |
| 07_Moving-and-closing-fds.md | med | med | low | low | low | no | no | PROMOTE |
| 08_Here-documents.md | med | med | low | low | low | no | no | PROMOTE |
| 09_Here-strings.md | med | high | low | low | low | no | no | PROMOTE |
| 10_Process-substitution-as-redirection.md | low | med | low | med | low | no | no | PROMOTE |
| 11_Order-of-evaluation.md | high | high | low | low | low | no | no | PROMOTE |
| 12_exec-for-fd-manipulation.md | med | med | low | low | low | no | no | PROMOTE |
| 13_Pipelines.md | high | high | low | high | low | no | no | PROMOTE |
| 14_Stderr-pipelines.md | high | high | med | med | n-a | no | yes | ENRICH |
| 15_pipefail-semantics.md | high | high | low | high | high | no | no | PROMOTE |
| 16_lastpipe-semantics.md | med | med | low | med | high | no | no | PROMOTE |

## Cross-reference issues

- §1.2 backref in 01 is asserted but not anchored — verify §1.2 file path resolves.
- §6.6 → §6.7 dup-and-close pointer chain in 06/07 is correct but circular without examples to disambiguate.
- §6.15 self-references §6.13 and §6.16 correctly, but §13.3 errexit interaction is mentioned without anchor verification.
- 10 mentions §5.7 process substitution; verify Part V chapter numbering.

## Self-containment risks

- 06, 07, 12: unparseable without external bash man-page knowledge. PROMOTE leaves must include a fd-table state-trace style.
- 08, 09: heredoc/herestring examples must include the *exact whitespace input* — heredoc rules are whitespace-sensitive and cannot be approximated.
- 16 (`lastpipe`): the `set +m` qualifier is critical and the leaf states it but the demonstration line at the end uses interactive-mode wording that won't survive RAG ingestion as an example.

## Code-gap recommendations

Mandatory examples (count from disposition column `required_examples`):
- 04, 06, 07, 11, 14, 15, 16: 2 examples each — paired contrastive (with/without the rule, before/after fd-table state).
- 08, 10, 12: 3 examples each — heredoc has 3 distinct delimiter forms; process substitution has 3 distinct uses; `exec` has at least 3 modes.
- 13: 2 examples — one trivial pipeline plus one `PIPESTATUS` capture.
- 05, 09: 1 example minimum but 2 preferred.

Total target: ~33 new code blocks across the Part.

#fin
