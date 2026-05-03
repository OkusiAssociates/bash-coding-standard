<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VII — Control Flow and Compound Commands: Audit

Date: 2026-05-03
Priority: P2 (language proper)
Files audited: 14 chapters + 1 index = 15

## Summary

Phase-1 evidence flagged Part VII as having **zero code blocks corpus-wide**. Audit confirms. Every chapter is a bullet enumeration; every form (`if`, `case`, `for`, `for ((;;))`, `while`, `until`, `select`, `( )`, `{ }`, `&&`/`||`, `break`, `continue`, `return`, `exit`, `:`/`true`/`false`) is *named* but never *exhibited*. For language-fundamental forms in a reference document this fails the basic test.

Most chapters merit PROMOTE. The exceptions are the index, the trivial-builtin chapter (14), and `break`/`continue`/`return`/`exit` which read acceptably as cheat-sheets but still warrant a single example each. There is one factual error: `01_Compound-command-overview.md` says "one of seven forms" then names ten — needs an enumeration fix.

## Top-5 findings

1. **[critical]** `01_Compound-command-overview.md` arithmetic error: lists ten forms after announcing "seven". Fixable mechanically; flag for prose author.
2. **[major]** `03_caseesac.md` introduces `;&` and `;;&` (Bash 4.0+ fall-through forms) without examples. Most bash authors do not know these; a reference must demonstrate them.
3. **[major]** `06_whileuntil.md` flags the canonical `cmd | while read…` subshell pitfall but provides neither the broken pattern nor the working `< <(cmd)` fix.
4. **[major]** `10_and-short-circuits.md` calls out the famous `cmd1 && cmd2 || cmd3` ≠ `if-then-else` misconception but never traces it. This trap is the #1 bash interview question and deserves a worked example.
5. **[minor]** `04_for-x-in-list.md` and `05_C-style-for.md` need their canonical forms shown side-by-side; the prose currently relies on the reader knowing the C-for syntax already.

## Per-leaf table

| File | Coverage | Clarity-H | Clarity-AI | XRefs | Strict | Example | Self-cont | Disp |
|------|----------|-----------|------------|-------|--------|---------|-----------|------|
| index.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 01_Compound-command-overview.md | med | med | low | med | low | no | yes | ENRICH |
| 02_ifelifelsefi.md | high | high | low | high | high | no | no | PROMOTE |
| 03_caseesac.md | high | high | low | med | low | no | no | PROMOTE |
| 04_for-x-in-list.md | med | high | low | med | low | no | no | PROMOTE |
| 05_C-style-for.md | med | high | low | low | low | no | no | PROMOTE |
| 06_whileuntil.md | high | high | low | high | high | no | no | PROMOTE |
| 07_select.md | med | med | low | low | low | no | no | PROMOTE |
| 08_Subshell-grouping.md | med | med | low | low | low | no | no | PROMOTE |
| 09_Brace-grouping.md | med | high | low | low | low | no | no | PROMOTE |
| 10_and-short-circuits.md | high | high | low | high | high | no | no | PROMOTE |
| 11_break-and-continue.md | high | high | med | med | n-a | no | yes | ENRICH |
| 12_return.md | med | high | med | med | low | no | yes | ENRICH |
| 13_exit.md | med | high | med | med | low | no | yes | ENRICH |
| 14_true-false.md | high | high | med | low | n-a | no | yes | ENRICH |

## Cross-reference issues

- 02 references §13.3 errexit exemption — verify Part XIII anchor exists.
- 06 references §7.11 (break/continue) and §6.16 (lastpipe) — both internal and reachable.
- 10 references §13.x errexit — verify anchor.
- 11 says `case` is not a loop — true; cross-reference to §7.3 would help readers searching for "break in case".

## Self-containment risks

- 02, 03, 06, 10: critical strict-mode interaction text is present but unanchored to demonstrations. RAG retrieval of the assertion alone cannot reproduce the behaviour.
- 07 (`select`): interactive-only — without a sample session showing `PS3` and the `?#` prompt, the leaf is unparseable for AI agents.
- 08, 09: the `( )` vs `{ }` distinction is critical and the chapters list properties but never juxtapose them. A side-by-side example is the only honest exposition.

## Code-gap recommendations

Mandatory examples (per disposition column):
- 02, 04, 05, 07, 08, 09: 2 examples each — typical use plus one strict-mode/pitfall trace.
- 03, 06, 10: 3 examples each — `case` needs `;`/`;&`/`;;&`; `while` needs read-loop plus subshell pitfall plus `process-sub` fix; `&&`/`||` needs the misconception trace.
- 11–14: 1 example each minimum; cheat-sheet form acceptable.

Total target: ~28 new code blocks. Combined with Part VI's deficit, this shard is responsible for >60 missing examples in code-free territory.

#fin
