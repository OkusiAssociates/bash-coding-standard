<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part IX — Functions: Audit

Date: 2026-05-03
Priority: P2 (language proper)
Files audited: 12 chapters + 1 index = 13

## Summary

Functions are bash's primary code-organisation unit and a major BCS hook-point. The skeleton coverage is solid — every relevant aspect (definition, args, scope, return, communication, recursion, tracing, inspection, export, naming, self-location, calling-convention) gets a chapter. Cross-references to BCS rules (`info`, `success`, etc.) appear in 10. But all the chapters are bullet inventories — no executable examples even where the *idiom itself is the content* (e.g., `local -n` namerefs in 9.5, self-location idiom in 9.11).

5 PROMOTE / 7 ENRICH / 1 KEEP. Naming-conventions chapter is essentially a style cheat-sheet and survives KEEP.

## Top-5 findings

1. **[major]** `05_Communicating-results.md`: four-mechanism trade-off (stdout / nameref / global / exit-status) is foundational to BCS function design. Each mechanism needs an example; trade-off table is asserted with no demonstration.
2. **[major]** `03_local-and-scope.md`: dynamic scope is the single most surprising bash semantic for programmers from other languages. The leaf names it but the only way to make it concrete is a caller→callee variable-shadowing trace.
3. **[major]** `01_Definition-syntax.md`: subshell-bodied function (`name() ( body )`) and trailing-redirection-on-definition are documented but never shown. Both are reference-distinct from `name() { body; }` semantics.
4. **[minor]** `11_Self-locating-with-BASH_SOURCE.md`: the canonical `lib_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")` idiom is the central self-location pattern but appears only once on a single line — needs a complete example showing pairing with `FUNCNAME[]`/`BASH_LINENO[]`.
5. **[minor]** `02_Argument-passing.md`: `${10}` brace requirement, `$#`/`$@`/`$*`/`$0`+`FUNCNAME[0]` distinction list is right but contains 8+ subtle facts in one chapter — a worked example or two would prevent reader-fatigue misuse.

## Per-leaf table

| File | Coverage | Clarity-H | Clarity-AI | XRefs | Strict | Example | Self-cont | Disp |
|------|----------|-----------|------------|-------|--------|---------|-----------|------|
| index.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 01_Definition-syntax.md | high | high | low | low | low | no | no | PROMOTE |
| 02_Argument-passing.md | high | high | low | med | low | no | no | PROMOTE |
| 03_local-and-scope.md | high | high | low | med | high | no | no | PROMOTE |
| 04_Return-value-via-return-N.md | high | high | med | med | low | no | yes | ENRICH |
| 05_Communicating-results.md | high | high | low | med | high | no | no | PROMOTE |
| 06_Recursion-and-FUNCNEST.md | med | high | med | low | low | no | yes | ENRICH |
| 07_Function-tracing.md | med | med | med | low | low | no | yes | ENRICH |
| 08_Listing-and-inspecting-functions.md | high | high | med | low | n-a | no | yes | ENRICH |
| 09_Exporting-functions.md | high | high | med | med | low | no | yes | ENRICH |
| 10_Naming-conventions.md | high | high | high | high | n-a | n-a | yes | KEEP |
| 11_Self-locating-with-BASH_SOURCE.md | high | high | low | high | high | yes | no | PROMOTE |
| 12_Calling-convention-discipline.md | med | med | med | low | med | no | yes | ENRICH |

## Cross-reference issues

- 02 mentions `${FUNCNAME[0]}` — verify the array section in Part IV (parameters/variables/arrays) covers `FUNCNAME` or push that responsibility to 9.11.
- 03 mentions §4.11 namerefs — verify Part IV chapter exists.
- 06 mentions §9.11 forward-ref to `FUNCNAME[]`/`BASH_LINENO[]` — circular with 11; both should mutually link.
- 10 lists BCS messaging helpers; cross-reference to BCS standard chapter is implicit — should be made explicit.
- 11 self-location idiom should cross-reference §10.3 (library self-location) which uses the same pattern; currently each Part owns a copy.

## Self-containment risks

- 01, 02, 03, 05: most-cited bash features in the corpus, presented as bullet lists with no traceable behaviour. RAG will retrieve the assertion without the demonstration.
- 11: contains an inline code block but it's a single line. The full self-location pattern needs context (top-of-file declaration, `realpath` rationale, Bash 4.4+ behaviour for `BASH_SOURCE[0]` of `eval`).

## Code-gap recommendations

Mandatory examples (per disposition column):
- 03, 05: 3 examples each — local-scope trace (caller/callee), each communication mechanism.
- 01, 02, 11: 2 examples each — paired definition forms; arg-forwarding `$@` vs `$*`; full self-location with `FUNCNAME[]` pairing.
- 04, 06–09, 12: 1 example each — small concrete demonstrations.

Total target: ~17 new code blocks across the Part. 11 already has a partial example that needs expansion.

#fin
