<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXII Audit — Idioms, Patterns, and Anti-Patterns

Date: 2026-05-03
Priority band: **P1**
Leaves audited: 18 (17 chapters + index)

## Summary

Part 22 is — as the phase-1 evidence predicted — the **richest practical
Part in the corpus**. Eleven of seventeen chapters ship a working bash
code block; the anti-pattern catalogue (§22.17) catalogues 18 distinct
anti-patterns each with the corrected form. By the rubric, ten chapters
qualify as KEEP, four as ENRICH, three as PROMOTE.

KEEP / ENRICH / PROMOTE = **11 / 4 / 3** (incl. index).

The PROMOTE candidates are not weak chapters — they are stubs that
**defer to other Parts** (§15.4 for the parser, §13.12 for the stack
trace, §12.13–12.15 for atomic write / lock / tempdir). For a chapter in
the *idioms cookbook*, deferring is wrong: the canonical idiom must be
inlined here even at the cost of duplication, because a reader looking
up "how do I parse arguments BCS-style?" lands on §22.3 expecting the
recipe.

## Top 5 findings

1. `[major]` `03_Argument-parsing-skeleton.md` is a 13-line stub that
   defers to §15.4 for the body. The full BCS-canonical hand-rolled
   parser is the single most-requested idiom in this Part and **must** be
   inlined here, ~150–200 lines, with bundling, equals form, and
   `noarg()` validation.
2. `[major]` `15_Stack-trace-error-reporter.md` defers to §13.12 with no
   inline code. The canonical stack-trace function (FUNCNAME/BASH_SOURCE/
   BASH_LINENO walker) is ~30 lines and should appear here.
3. `[major]` Three idiom chapters (§22.10 atomic write, §22.11 exclusive
   lock, §22.13 tempdir lifecycle) defer to Part 12 with bullet hints
   only. The whole point of an idioms cookbook is one-stop self-contained
   recipes; these three deserve ENRICH-level inline code blocks (~40–50
   lines each).
4. `[minor]` `17_Anti-patterns-catalogue.md` is the **benchmark for the
   corpus** — 18 anti-patterns each paired with the corrected form, all
   accurate, all load-bearing. KEEP unchanged.
5. `[minor]` `01_The-strict-mode-preamble.md`, `02_Self-locating-script-
   directory.md`, `06_Memoisation.md`, `09_Reading-config-files-safely.md`
   all match BCS canonical patterns verbatim — KEEP, no changes needed.

## Per-leaf table

| Leaf | Disp | Tgt | Ex | Notes |
|------|------|-----|----|-------|
| 01_strict-mode-preamble | KEEP | 20 | 1 | canonical preamble; matches BCS §1 |
| 02_Self-locating-script-directory | KEEP | 18 | 1 | BCS realpath idiom |
| 03_Argument-parsing-skeleton | PROMOTE | 200 | 2 | inline the full canonical parser |
| 04_Default-value-patterns | ENRICH | 60 | 1 | add side-by-side code block |
| 05_Lazy-initialisation | KEEP | 20 | 1 | sentinel pattern complete |
| 06_Memoisation | KEEP | 22 | 1 | `+set` test idiom present |
| 07_Iter-assoc-array-deterministically | KEEP | 16 | 1 | sort flags + perf caveat |
| 08_Building-structured-output | ENRICH | 70 | 2 | add tsv/csv/jq examples |
| 09_Reading-config-files-safely | KEEP | 24 | 1 | BCS read_conf pattern |
| 10_Atomic-file-write | ENRICH | 50 | 1 | inline mktemp+mv block |
| 11_Exclusive-lock | ENRICH | 50 | 1 | inline `exec 9` + flock block |
| 12_Bounded-retry-with-exponential-backoff | KEEP | 28 | 1 | retry + jitter caveat |
| 13_Tempdir-lifecycle | ENRICH | 50 | 1 | inline mktemp -d + EXIT trap |
| 14_Mock-friendly-subprocess-wrapper | KEEP | 14 | 1 | `command` prefix idiom |
| 15_Stack-trace-error-reporter | PROMOTE | 150 | 1 | inline canonical walker |
| 16_Self-test-mode-dual-purpose-script | KEEP | 18 | 1 | `${#BASH_SOURCE[@]}` test |
| 17_Anti-patterns-catalogue | KEEP | 26 | 0 | benchmark-quality catalogue |
| index | KEEP | 34 | 0 | complete |

## Cross-reference issues

- §22.3 → §15.4: legitimate cross-ref, but the deferral is the wrong
  pattern for an idioms cookbook. Both should hold the canonical parser
  (Part 15 as definition; Part 22 as recipe).
- §22.10/§22.11/§22.13 cross-refs to §12.13–12.15 work, but again the
  cookbook contract is broken if §22 is unable to stand alone.
- §22.15 → §13.12 same issue.
- §22.5/§22.6 lack a forward link to Part 9 functions (especially scope
  and `declare -g` semantics) — minor.
- §22.16 mentions "BCS template includes this pattern" without naming
  which template — should xref `data/templates/` or `bcs template`.

## Self-containment risks

- The deferral pattern is the only material self-containment risk in
  this Part. Once §22.3, §22.10, §22.11, §22.13, §22.15 inline their
  canonical code blocks, every chapter stands alone for AI/RAG retrieval.
- `09_Reading-config-files-safely.md` declares `declare -g -- "${key^^}=$value"`
  inside a function — this is correct under bash 4.2+ but `declare -g`
  pre-4.2 behaviour differs; a one-line bash-version requirement note
  would close the small remaining ambiguity.

## Code-gap recommendations

Three high-value PROMOTEs (in priority order):

1. **§22.3 Argument-parsing skeleton** — inline the full hand-rolled
   parser (~180 lines): defaults, while/case/shift loop, long+short+
   bundled+equals+`--`, post-parse validation, error path with `noarg`.
2. **§22.15 Stack-trace error reporter** — canonical FUNCNAME walker
   showing BASH_LINENO[i] alignment, BASH_SOURCE[i+1] alignment, and a
   trap-ERR wiring example.
3. **§22.10 / §22.11 / §22.13** — three small ENRICH additions, each
   ~40–50 lines, that turn deferral stubs into self-contained recipes.

After those five edits, Part 22 becomes the corpus's **strongest** Part
and a viable cookbook for new BCS-aligned engineers.

#fin
