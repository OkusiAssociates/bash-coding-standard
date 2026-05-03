<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part 04 — Parameters, Variables, and Arrays — Audit

## Summary
- Leaves audited: 15 (14 chapters + index)
- KEEP / ENRICH / PROMOTE: 1 / 4 / 10
- Code-block coverage: 0 of 15 leaves contain at least one fenced code block
- Strict-mode framing: medium (Part is BCS-central; `declare`, `local --`, `readonly`, `set -u` interactions are repeatedly relevant)
- Cross-reference density: medium-high (xrefs to §4.11, §22.7, §14.3, §18.13, Appendix B/C, §20 — Appendix B/C citations are critical and currently unresolvable in isolation)

## Highest-leverage findings (top 5)
1. **The PROMOTE rate in this Part (10/15) is by far the highest in the shard.** This Part is BCS-central — `declare -ar`, `local --`, array semantics, namerefs, exit-trap-as-cleanup are all rooted here — and every substantive chapter is currently a 14–20-line bullet sketch. The downstream prose-authoring effort for Part IV alone is large.
2. §4.5 (`declare`) is the **single highest-leverage chapter in the whole shard**. It governs BCS rules across the standard. Currently 19 lines of attribute bullets. Needs an attribute table (column per flag), worked examples for `-i`, `-a`, `-A`, `-n`, `-r`, `-x`, plus the combining-attributes pattern (`declare -ar` is a frequent BCS idiom).
3. §4.9 (Indexed arrays) and §4.10 (Associative arrays) are the two most-consulted chapters of any Bash reference for working programmers. PROMOTE both with copy-pitfall demos, sparse-array demos, deterministic-iteration idiom.
4. §4.11 (Namerefs) is conceptually the hardest chapter in this Part. The output-parameter pattern is a BCS-recommended idiom and must appear as worked code. The `local -n self=self` shadowing pitfall must be demonstrated, not just listed.
5. §4.6 (`local` and dynamic scope) is an unusual concept for readers from lexical-scope languages. PROMOTE with a caller→callee→callee2 visibility demo and an explicit statement of the BCS `local --` rule with its rationale.

## Per-leaf table
| File | Disposition | Coverage | Human | AI/RAG | Xref | Strict | Example | Notes |
|------|-------------|----------|-------|--------|------|--------|---------|-------|
| 01_Parameter-taxonomy.md | ENRICH | med | high | med | high | n-a | no | Overview chapter; one example per taxonomy class |
| 02_Positional-parameters.md | PROMOTE | med | high | low | med | low | no | "$@" vs "$*" worked example mandatory; getopts loop |
| 03_Special-parameters.md | ENRICH | high | high | med | high | n-a | no | Convert bullets to table with example values |
| 04_Shell-variables.md | PROMOTE | med | med | low | high | low | no | Long bulleted reserved-name list; needs sub-grouping (call-stack vs runtime vs prompt-context) and examples for the load-bearing names |
| 05_The-declare-builtin-and-attributes.md | PROMOTE | med | high | low | med | low | no | BCS-central; single highest-leverage chapter in shard |
| 06_local-and-dynamic-scope.md | PROMOTE | med | high | low | med | low | no | Dynamic scope is foreign concept; needs visibility demo |
| 07_readonly-and-immutability.md | ENRICH | high | high | med | low | low | no | Add SCRIPT_NAME and -f function-readonly examples |
| 08_export-and-the-environment.md | PROMOTE | med | high | low | med | low | no | Shellshock paragraph deserved; export -f and assignment-prefix demo |
| 09_Indexed-arrays.md | PROMOTE | high | high | low | med | low | no | Most-consulted chapter; sparse and copy demos essential |
| 10_Associative-arrays.md | PROMOTE | high | high | low | med | low | no | Same; deterministic iteration idiom |
| 11_Namerefs-n.md | PROMOTE | med | high | low | low | low | no | Conceptually hard; pitfall demos mandatory |
| 12_Integer-arithmetic-semantics.md | PROMOTE | med | high | low | low | med | no | Overflow, base prefixes, set -u inconsistency all demand demos |
| 13_Variable-assignment-semantics.md | PROMOTE | med | high | low | low | low | no | Scalar-vs-compound expansion difference is footgun-rich |
| 14_Unsetting.md | ENRICH | high | high | med | low | low | no | unset 'arr[i]' quoting demo; -n nameref-vs-target distinction |
| index.md | KEEP | high | high | high | high | n-a | n-a | Standard index page, complete |

## Cross-reference issues
- §4.1 → "Appendix B" (special parameters). Verify `99_Appendices/B_*.md` exists. **Flag for appendix-shard auditor.**
- §4.4 → "Appendix C" (shell variables). Same.
- §4.4 → §18.13 (prompts). Verify §18.13 exists when Part 18 is audited.
- §4.4 → §14.3 (mapfile). Verify §14.3 exists.
- §4.5 → §4.11 (namerefs). Internal xref — resolves.
- §4.6 → §4.11 (namerefs). Internal xref — resolves.
- §4.10 → §22.7 (sorted iteration). Verify §22.7 exists when Part 22 is audited.
- §4.13 → no broken xrefs.

## Self-containment risks
- §4.4 — the chapter explicitly defers to Appendix C for the canonical list. RAG retrieval of this leaf yields a *preview* of the canonical list — sub-grouping by purpose (introspection, runtime, prompt, identity) would make the leaf self-contained at the conceptual level even if specific values live in Appendix C.
- §4.8 — Shellshock CVE referenced obliquely; for an isolated retrieval the reader doesn't know the export-encoding mechanism. Either a paragraph of context or a sharper xref to a "Bash security history" section.
- §4.12 — the assertion "set -u still treats unset variables as 0 in arithmetic — a notable inconsistency" is precise but unsupported by example. RAG retrieval would not let a reader verify the claim.
- §4.13 — the assignment-prefix-command rule has POSIX special-builtin caveats listed but not enumerated. The "(unless cmd is a special builtin or function with POSIX rules)" parenthetical needs the actual list of special builtins.

## Code-gap recommendations
Highest-priority code blocks:
1. §4.5 — Attribute table plus six worked examples (one per attribute).
2. §4.9 — `arr=(a b c); arr[10]=x; printf '%s\n' "${!arr[@]}"` plus `new=("${arr[@]}")` showing re-indexing.
3. §4.10 — `declare -A m=([a]=1 [b]=2); for k in $(printf '%s\n' "${!m[@]}" | sort); do echo "$k=${m[$k]}"; done`.
4. §4.11 — output-parameter pattern: `set_result() { local -n out=$1; out="hello"; }`.
5. §4.6 — visibility demo with three nested functions.
6. §4.8 — `export X=1; bash -c 'echo $X'` and `unset X; X=1 bash -c 'echo $X'` to show assignment-prefix scope.
7. §4.12 — `declare -i x=0xff; echo $x` (255), then overflow demo `echo $((2**63))`.
8. §4.13 — `arr=(a b c); arr2=("${arr[@]}")` (no globbing) vs `unquoted=( $str )` (subject to globbing) contrast.

#fin
