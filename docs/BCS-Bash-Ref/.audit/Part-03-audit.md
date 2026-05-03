<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part 03 — Lexical Structure and Shell Grammar — Audit

## Summary
- Leaves audited: 12 (11 chapters + index)
- KEEP / ENRICH / PROMOTE: 2 / 5 / 5
- Code-block coverage: 0 of 12 leaves contain at least one fenced code block
- Strict-mode framing: medium (Part is parser-level, but quoting interacts directly with strict-mode discipline; §3.4 and §3.6 should reference `set -u`)
- Cross-reference density: medium (xrefs to §8.10, BCS-bash/11_QUOTING.md present; the bash-man-page cross-link is the kind that fails RAG retrieval)

## Highest-leverage findings (top 5)
1. §3.6 (Double quotes) is the single most-consulted chapter in any Bash reference. The `"$@"` vs `"$*"` distinction is correctly stated but never demonstrated. **Highest-priority PROMOTE in this Part.** Worked example essential.
2. §3.4 (Quoting overview) is correctly the gateway chapter for §§3.5–3.9, but punts to `BCS-bash/11_QUOTING.md`. RAG retrieval of this leaf yields no hierarchy and no rationale beyond bullets — PROMOTE with an inline expansion-suppression hierarchy table.
3. §3.10 (Shell grammar) lists productions as bullets when a BNF-style fenced block is the natural form. PROMOTE.
4. §3.11 (Operator precedence) is footgun-rich: the `a && b || c` pattern is misused as if-then-else by countless scripts. Worked example showing the actual semantics is mandatory. PROMOTE.
5. §3.1 (Tokenisation) is foundational; the longest-match operator-recognition rule and the metachar/control-operator classes deserve a literal table, not a list of "the tokeniser's character classes". PROMOTE.

## Per-leaf table
| File | Disposition | Coverage | Human | AI/RAG | Xref | Strict | Example | Notes |
|------|-------------|----------|-------|--------|------|--------|---------|-------|
| 01_Tokenisation.md | PROMOTE | med | high | low | low | low | no | Foundational parser concept; needs metachar table and worked tokenisation |
| 02_Reserved-words.md | ENRICH | high | high | med | med | n-a | no | List complete; quote-suppression demo would lift it |
| 03_Comments.md | ENRICH | high | high | med | low | n-a | no | Mid-word vs leading distinction needs a demo; BCS style citation missing |
| 04_Quoting-overview.md | PROMOTE | med | high | low | high | med | no | Hierarchy table essential; xref to BCS-bash insufficient for RAG |
| 05_Single-quotes.md | ENRICH | high | high | med | low | n-a | no | Close-escape-reopen idiom is the canonical example; show it |
| 06_Double-quotes.md | PROMOTE | med | high | low | med | high | no | "$@" vs "$*" worked demo essential |
| 07_ANSI-C-quoting.md | ENRICH | high | high | med | low | n-a | no | Convert bullet list of escapes to literal table |
| 08_Locale-translation.md | KEEP | med | high | med | low | n-a | no | Author intentionally short on rare feature; bullets adequate |
| 09_Backslash-escapes.md | ENRICH | high | high | med | low | n-a | no | Context-table with one example per context |
| 10_Shell-grammar.md | PROMOTE | med | high | low | med | n-a | no | BNF block needed; bullet list inverts the form |
| 11_Operator-precedence.md | PROMOTE | med | high | low | med | low | no | The `a && b || c` antipattern must be demonstrated |
| index.md | KEEP | high | high | high | high | n-a | n-a | Standard index page, complete |

## Cross-reference issues
- §3.4 → `BCS-bash/11_QUOTING.md` is a sibling-project xref, not a `§N.M` xref. Acceptable as a pointer, but unresolvable for an isolated RAG retrieval — flag for self-containment review.
- §3.11 → §8.10 (arithmetic operator precedence). Verify §8.10 exists when Part 08 is audited.
- §3.7 → no broken xref but the `printf '%b\n'` alternative cited belongs in §14.5.

## Self-containment risks
- §3.4 — quoting overview's main value is the rationale ("why `"$var"` is the always-correct default"); the rationale is mentioned in one bullet and never argued. RAG retrieval yields a TOC, not a teaching.
- §3.7 — ANSI-C quoting escape table cited as bullets; reader must know what `\cX` means without context. A table with examples ("`$'\cA'` → `\x01`") would resolve this.
- §3.10 — grammar productions referenced informally; the grammar's actual EBNF form (e.g. `pipeline := [time] [!] command (| command)*`) is what a RAG-retrieved leaf needs.

## Code-gap recommendations
1. §3.1 — `set -- a"b c"d; printf '%s\n' "$@"` to show how quoting determines word boundaries.
2. §3.5 — `echo 'it'\''s'` and contrast with `echo $'it\'s'`.
3. §3.6 — `set -- a b c; for x in "$@"; do echo "[$x]"; done` then `for x in "$*"; do echo "[$x]"; done`.
4. §3.7 — `printf '%s\n' $'\t' $'\xff' $'é'` showing tab, byte, and unicode.
5. §3.10 — A fenced BNF block plus one parsed example: `time ! cmd1 | cmd2 && cmd3`.
6. §3.11 — `false && echo a || echo b` (prints "b") vs `true || echo a && echo b` (prints "b" too — which is the gotcha).

#fin
