<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VIII — Conditional Expressions and Arithmetic: Audit

Date: 2026-05-03
Priority: P2 (language proper)
Files audited: 14 chapters + 1 index = 15

## Summary

Part VIII is structurally the **strongest of the shard**. Its operator inventories (file tests, string operators, arithmetic operators) read correctly as cheat-sheet tables — KEEP territory. Where it fails is in the *semantically loaded* chapters: `[[ ]]` overview, RHS quoting rules for `==` and `=~`, `BASH_REMATCH` capture lifecycle, and the `((count++))` errexit pitfall. Those four are dense semantic landmines and need worked examples or PROMOTE.

3 KEEP / 8 ENRICH / 4 PROMOTE distribution. Three operator-table chapters (file tests, arithmetic operators, deprecated-`[`) read as reference-grade as-is.

## Top-5 findings

1. **[major]** `06_Regex-matching-with.md`: the rule that *quoting the RHS of `=~` changes semantics* is the single biggest landmine in conditional expressions. The leaf states it but a reference cannot stop at the assertion — needs at least one `pat=…; [[ $x =~ $pat ]]` traceable example.
2. **[major]** `09_Arithmetic-context.md`: the `((count++))` returns 1 when `count` was 0 — interaction with `set -e` is a silent script-killer. Leaf mentions §13.3 but supplies no demonstration.
3. **[major]** `01_overview.md` claims "right-hand side of `==` is treated as a glob pattern unless quoted" without a demonstration. Same for `=~`. These are reference-cardinal rules.
4. **[minor]** `05_Pattern-matching-with.md` mentions `extglob` `@(yes|no|maybe)` but `extglob` requires `shopt -s extglob` to be active — the prerequisite is invisible.
5. **[minor]** `13_let-builtin.md` correctly recommends `(( ))` over `let` but fails to demonstrate the equivalent `let` exit-status pitfall in a strict-mode script.

## Per-leaf table

| File | Coverage | Clarity-H | Clarity-AI | XRefs | Strict | Example | Self-cont | Disp |
|------|----------|-----------|------------|-------|--------|---------|-----------|------|
| index.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 01_overview.md | high | high | low | med | high | no | no | PROMOTE |
| 02_File-test-operators.md | high | high | high | low | n-a | n-a | yes | KEEP |
| 03_File-comparison-operators.md | high | high | med | low | low | no | yes | ENRICH |
| 04_String-operators.md | high | high | med | med | low | no | yes | ENRICH |
| 05_Pattern-matching-with.md | high | high | low | med | low | no | no | PROMOTE |
| 06_Regex-matching-with.md | high | high | low | low | low | no | no | PROMOTE |
| 07_Logical-operators-and-grouping.md | high | high | med | low | n-a | no | yes | ENRICH |
| 08_Quoting-rules-inside.md | high | high | med | high | low | no | yes | ENRICH |
| 09_Arithmetic-context.md | high | high | low | high | high | no | no | PROMOTE |
| 10_Arithmetic-operators-and-precedence.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 11_Integer-types-overflow-base-prefixes.md | high | high | med | low | low | no | yes | ENRICH |
| 12_Floating-point-workarounds.md | high | high | med | low | n-a | no | yes | ENRICH |
| 13_let-builtin.md | high | high | med | high | high | no | yes | ENRICH |
| 14_The-deprecated-and-test.md | high | high | high | low | n-a | n-a | yes | KEEP |

## Cross-reference issues

- 01 mentions §8.6 `=~` quoting; reachable.
- 09 references §5.5 (arithmetic expansion `$(( ))`) and §13.3 (errexit interaction) — both anchors must be verified by a parent agent owning Parts 5 and 13.
- 10 punts to "Appendix H" — verify `99_Appendices/H_*.md` exists and contains the operator-precedence table.
- 14 lists `[ ` deprecation but never points back to `[[ ]]` overview at §8.1 — add a forward-link.

## Self-containment risks

- 01, 05, 06, 09: assertions about quoting/glob/regex/arithmetic semantics that are unverifiable without running the example. PROMOTE leaves must include the pre/post bash trace.
- 11: bases-table is correct but the `36#zz = 1295` example must be present (it is); should add an octal-leading-zero gotcha (`0755 = 493`).

## Code-gap recommendations

Mandatory examples (per disposition column):
- 01, 05, 09: 2 examples each.
- 06: 3 examples — capture-group, quoted-RHS, variable-stored-pattern.
- 03, 04, 07, 08, 11, 12, 13: 1 example each; mostly cheat-sheet supplement.

Total target: ~14 new code blocks. The KEEP cheat-sheets (02, 10, 14) need none.

#fin
