<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part 05 — Expansions — Audit

## Summary
- Leaves audited: 14 (13 chapters + index)
- KEEP / ENRICH / PROMOTE: 1 / 6 / 7
- Code-block coverage: 0 of 14 leaves contain at least one fenced code block
- Strict-mode framing: medium (word-splitting and IFS interact directly with strict-mode safety; arithmetic-vs-`set -u` is one of the few points where the framing is currently called out — §5.5)
- Cross-reference density: medium (xrefs to §8.10, §17.6, §22.7, §14.3, §20, Appendix I; Appendix I citation is critical and currently unresolvable in isolation)

## Highest-leverage findings (top 5)
1. §5.4 (Parameter and variable expansion) is the **richest expansion in Bash** and is currently a 22-line bullet sketch deferring the full operator catalogue to Appendix I. PROMOTE with a high target (~260 lines) and 4 examples — this is the workhorse chapter readers consult for `${var:-default}`, `${var/old/new}`, `${var^^}`, and the bash-5.2 `${var@k}` operators. Without inline examples the leaf is unusable for RAG.
2. §5.8 (Word splitting and IFS) is the **#1 source of Bash bugs in production scripts**. Currently 14 lines of bullets. PROMOTE with the IFS-whitespace-vs-non-whitespace contrast as worked code; the `IFS=$' \t\n'` and `IFS=:` idioms must appear as fenced blocks.
3. §5.7 (Process substitution) — `diff <(sort a) <(sort b)` is the canonical motivation for the feature and is mentioned in prose but not shown. PROMOTE.
4. §5.6 (Command substitution) makes a strong claim about Bash 5.3's `${ command; }` no-fork form — verify this against §25 when the 5.3 Part is audited. Also: the `$(<file)` form is mentioned as a "pitfall" in the bullet — semantically this is an *idiom*, not a pitfall. Wording should be corrected during PROMOTE.
5. §5.9 (Pathname expansion) and §5.11 (Glob options) together cover globbing. §5.9's POSIX class list is correct but a literal table is more useful than a comma-list. §5.11's `local`-isn't-possible-for-shopt note demands a save-restore idiom demo.

## Per-leaf table
| File | Disposition | Coverage | Human | AI/RAG | Xref | Strict | Example | Notes |
|------|-------------|----------|-------|--------|------|--------|---------|-------|
| 01_Order-of-expansions.md | ENRICH | high | high | med | low | med | no | Numbered list excellent; needs one walkthrough |
| 02_Brace-expansion.md | ENRICH | high | high | med | low | n-a | no | Range and nested forms benefit from short outputs in fenced blocks |
| 03_Tilde-expansion.md | ENRICH | high | high | med | low | low | no | Quoted-vs-unquoted demo |
| 04_Parameter-and-variable-expansion.md | PROMOTE | med | med | low | med | low | no | Highest-leverage in this Part; needs operator-by-operator examples |
| 05_Arithmetic-expansion.md | ENRICH | med | high | med | med | high | no | Set -u inconsistency must be demoed, not asserted |
| 06_Command-substitution.md | PROMOTE | med | high | low | low | med | no | Bash 5.3 ${ ; } claim needs verification; $(<file) wording |
| 07_Process-substitution.md | PROMOTE | med | high | low | low | low | no | `diff <(...) <(...)` example mandatory |
| 08_Word-splitting-and-IFS.md | PROMOTE | med | high | low | low | high | no | #1 production bug source; demands worked demos |
| 09_Pathname-expansion-globbing.md | PROMOTE | high | high | low | low | low | no | POSIX class table; nullglob/dotglob demos |
| 10_Quote-removal.md | ENRICH | high | high | med | low | n-a | no | Short by intent; the var=$'a\\b' example deserves a fenced block |
| 11_Glob-options.md | PROMOTE | high | high | low | low | low | no | shopt save-restore idiom demo |
| 12_Extended-globs-extglob.md | PROMOTE | high | high | low | low | low | no | One demo per operator |
| 13_Locale-and-pattern-matching.md | ENRICH | high | high | med | low | high | no | LC_ALL=C example and locale-collation gotcha |
| index.md | KEEP | high | high | high | high | n-a | n-a | Standard index page, complete |

## Cross-reference issues
- §5.4 → "Appendix I" (parameter expansion operator set). Verify `99_Appendices/I_*.md` exists. **Flag for appendix-shard auditor.**
- §5.5 → §8.10 (arithmetic operator precedence). Verify §8.10 exists when Part 08 is audited.
- §5.6 → §25.1 (Bash 5.3 no-fork command substitution). Verify §25.1 exists when Part 25 is audited.
- §5.13 → no broken xrefs.
- §5.7 → mentions "capture via wait on the explicit PID, or use a coproc" — should xref Part XVII coproc chapter explicitly.

## Self-containment risks
- §5.4 — The whole operator menu is presented bullet-style with no examples; an LLM/RAG retrieval of this leaf cannot answer "how do I substitute in `$var`?" without already knowing the answer.
- §5.6 — The `inherit_errexit` interaction is named but not explained. RAG reader has no resolver.
- §5.8 — IFS-whitespace-vs-non-whitespace rule stated as bullet ("different rules for adjacent runs") without showing what those rules produce. Needs the canonical `a::b` (with `IFS=:`) → 3 fields demo.
- §5.13 — claim that "Bash 5.2 introduces stricter UTF-8 handling in some areas" is vague. Specify what or remove.

## Code-gap recommendations
Every chapter except §5.10 needs at least one fenced code block. Highest priority:
1. §5.4 — Operator catalogue with mini-examples in a single fenced block: `var=hello; echo "${var:-default} ${var:0:3} ${var^^} ${#var}"`.
2. §5.8 — `IFS=: read -ra parts <<< "a::b"; printf '[%s]\n' "${parts[@]}"` to show empty-field behaviour with non-whitespace IFS.
3. §5.7 — `diff <(printf 'a\nb\n') <(printf 'a\nc\n')` and the canonical fan-out: `tee >(gzip > a.gz) >(sha256sum > a.sha) > /dev/null`.
4. §5.5 — `set -u; echo $((unset_var + 1))` to demonstrate the arithmetic-vs-`set -u` inconsistency claim.
5. §5.9 — `shopt -s nullglob; arr=( *.notexist ); echo "${#arr[@]}"` (0) vs default behaviour.
6. §5.11 — Save-restore idiom: `was=$(shopt -p nullglob); shopt -s nullglob; …; eval "$was"`.
7. §5.12 — One demo per extglob operator: `shopt -s extglob; ls !(*.bak|*.tmp)`.

#fin
