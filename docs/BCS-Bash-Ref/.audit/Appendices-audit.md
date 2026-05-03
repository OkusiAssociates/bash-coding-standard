<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Appendices Audit — A through Q

Date: 2026-05-03
Priority band: **P1** (all appendices)
Leaves audited: 18 (17 lettered appendices + index)

## Summary

The Appendices are the audit's biggest **KEEP cluster**. Reference tables
succeed when they are complete and tight, and 14 of the 17 lettered
appendices already meet that bar. Two list-form appendices (C, E) need
conversion to tables for column completeness; one cross-ref appendix (O)
would gain reach by resolving to specific BCS#### codes.

KEEP / ENRICH / PROMOTE = **15 / 3 / 0** (incl. index).

No appendix needs full prose-style PROMOTE. Even the prose-leaning ones
— M (version history), N (glossary), Q (further reading) — are
reference-form by design and complete in their current shape.

## Top 5 findings

1. `[minor]` Appendix A (Builtin Reference) lists every bash 5.2 builtin
   with a one-line description and §-level cross-ref. Format consistent;
   no gaps.
2. `[major]` Appendix C (Shell Variables) is bullet-list rather than
   table; missing a few variables (`TIMEFORMAT`, `FUNCNEST`, `PROMPT_*`,
   `READLINE_*`, `COMP_*` is grouped as one line). ENRICH: convert to a
   table with `name | type | scope | description` columns and add the
   missing rows.
3. `[major]` Appendix E (`shopt` Options) similarly bullet-form. The 5.2
   options are all present, but a `name | default | description` table
   would let the reader see at a glance which are on by default and which
   are 5.2+ additions. ENRICH.
4. `[minor]` Appendix O cross-references this corpus's Parts to BCS
   *sections* (§01, §02, …) but BCS itself is organised by `BCS####`
   codes. Resolving the cross-ref to specific codes (e.g. "§22.1 →
   BCS0102, BCS0103") would help RAG retrieval.
5. `[minor]` Appendix Q (Further Reading) is the rare prose appendix
   that earns its keep — every link is annotated, and the "what to skip"
   note (TLDP, freeCodeCamp) is exactly the kind of evaluative
   guidance an AI/RAG reader cannot derive elsewhere.

## Per-leaf table

| Appendix | Disp | Tgt | Ex | Notes |
|----------|------|-----|----|-------|
| A_Builtin-Reference-alphabetical | KEEP | 57 | 0 | full bash 5.2 builtin list |
| B_Special-Parameters-Reference | KEEP | 17 | 0 | all 10 params present |
| C_Shell-Variables-Reference | ENRICH | 50 | 0 | convert to table; add missing rows |
| D_set-Options-Reference | KEEP | 28 | 0 | complete short/long/effect table |
| E_shopt-Options-Reference | ENRICH | 70 | 0 | convert to table with default-state column |
| F_ANSI-C-Escape-Sequences | KEEP | 24 | 0 | complete escape map |
| G_Glob-and-Extglob-Patterns | KEEP | 21 | 0 | glob+extglob+POSIX classes |
| H_Conditional-Expression-Operators | KEEP | 53 | 0 | canonical `[[ ]]` operator tables |
| I_Parameter-Expansion-Cheat-Sheet | KEEP | 41 | 0 | exhaustive incl. @-transformations |
| J_Redirection-Operators | KEEP | 27 | 0 | full redirection-operator table |
| K_Signal-Numbers-Linux | KEEP | 41 | 0 | full Linux x86-64 signal map |
| L_Exit-Code-Conventions | KEEP | 22 | 0 | BCS + sysexits.h |
| M_Bash-Version-History | KEEP | 20 | 0 | 1.0 through 5.3 with notable additions |
| N_Glossary | KEEP | 49 | 0 | ~45 entries; one-line defs |
| O_Cross-Reference-Sections-to-BCS-Sections | ENRICH | 40 | 0 | resolve to BCS#### codes |
| P_Cross-Reference-Sections-to-BCS-bash-Files | KEEP | 32 | 0 | complete chapter→file map |
| Q_Further-Reading | KEEP | 23 | 0 | annotated; what-to-skip is editorial gold |
| index | KEEP | 32 | 0 | complete contents listing |

## Cross-reference issues

- Appendix A cross-refs are sparse and inconsistent: `bind` lists §18.3
  but `cd`, `command`, `pwd`, `umask`, `ulimit` have none. Should be
  systematically populated.
- Appendix B should xref §4.x (positional parameters) and §15.x
  (command-line processing) — presently nothing.
- Appendix C should resolve to Part 4 (variables) and Part 12 (signals
  for `BASH_SUBSHELL`-like state) per group.
- Appendix L should xref BCS Section 13 (env config) for exit-code
  consistency between scripts and `bcs.conf` semantics.
- Appendix N (glossary) entries should each link to their primary
  Part / chapter; currently flat.

These are all **`[fixable]`** mechanical edits — not auto-fixable
without judgement, but a short pass would systematically tighten them.

## Self-containment risks

- Appendix C lists `BASH_REMATCH[]` without explaining when it is
  populated — a glossary reader would resolve via §8.x but a RAG reader
  surfacing C alone might miss the trigger condition. A one-word "(set
  by `=~` matches)" suffix would close this.
- Appendix E lists `compat31`–`compat51` without flagging that BCS
  recommends not enabling them (cross-ref §23.9). Add a note.
- Appendix Q's link to `promo/getting-serious-about-bash.md` is repo-
  internal (`../../promo/...`); a RAG reader might not have access. The
  link should be present but the entry should also describe Gary Dean's
  argument in one sentence so the reference is informative even when the
  link does not resolve.

## Code-gap recommendations

Appendices are reference tables. Code blocks are not the right form for
any of them, including the prose-leaning trio (M, N, Q). The three
ENRICH targets are:

1. **Appendix C** — convert bullet list to `| name | type | scope |
   description |` table; add `TIMEFORMAT`, `FUNCNEST`, `PROMPT_COMMAND`,
   `READLINE_LINE`, `READLINE_POINT`, `COMP_*` per-variable rows.
2. **Appendix E** — convert to `| option | default | bash version |
   description |` table; flag 5.2+ additions explicitly.
3. **Appendix O** — extend right-hand column from `§22.1, §22.2`
   shorthand to `BCS0102 (canonical preamble), BCS0103 (file
   terminator), …` per row.

Once those three table-completions land, the appendix set becomes the
strongest reference component of the whole corpus.

## Surprising findings

- The appendices are **far better than phase-1 evidence implied**. I
  expected to find significant table gaps; instead I found 14 KEEPs and
  three relatively cosmetic ENRICHs.
- Appendix Q's editorial "what to skip" pass-list (TLDP, freeCodeCamp,
  W3Schools, GeeksforGeeks, TutorialsPoint) is unusual and excellent —
  this kind of negative recommendation is rare in technical references
  and is exactly the sort of information AI/RAG cannot derive. KEEP
  unchanged.
- Appendix N (glossary) at 49 lines covers more vocabulary than I
  expected. The entries are tight, accurate, and load-bearing.
- Appendix A is **complete** — every bash 5.2 builtin is present, in
  alphabetical order, with one-line descriptions. This is the appendix
  most likely to silently rot as bash adds builtins; pin to bash 5.2 in
  the header.

#fin
