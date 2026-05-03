<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXIV Audit — Bash Internals

Date: 2026-05-03
Priority band: **P3**
Leaves audited: 11 (10 chapters + index)

## Summary

Part 24 is a *specialist* Part documenting the bash implementation —
execution pipeline, parser, variable / function / job / trap tables,
exec environment, subshell forking, loadables, and pointers into the
source tree. The editorial register is bullet-form briefing; depth
properly belongs to bash source code itself, not to a reader-level
reference.

KEEP / ENRICH / PROMOTE = **8 / 3 / 0** (incl. index).

Three leaves earn ENRICH because a small concrete demo materially helps
the reader: the execution pipeline (xtrace anchoring), subshell forking
(BASHPID/BASH_SUBSHELL demo), and loadables (`enable -f` invocation).
The remainder are correctly terse.

## Top 5 findings

1. `[minor]` `01_The-execution-pipeline.md` enumerates the 10-step path
   correctly. A small `set -x` transcript anchoring each numbered step
   would make it concrete without bloat.
2. `[minor]` `08_Subshell-forking.md` would benefit from a demonstration
   of `BASHPID` vs `$$` showing the parent/subshell PID divergence —
   one of the bash gotchas readers most often hit.
3. `[minor]` `09_Builtin-loadables.md` should show a real `enable -f`
   call (e.g., `enable -f /usr/lib/bash/sleep sleep`) so the abstract
   description grounds out.
4. `[minor]` `10_Reading-the-bash-source.md` correctly hands off to the
   bash repo. The five-file map (`parse.y`, `subst.c`, `execute_cmd.c`,
   `variables.c`, `jobs.c`) is the load-bearing payload — KEEP.
5. `[minor]` `02_The-bison-grammar.md`–`07_The-execution-environment.md`
   are all correctly terse: at this level of treatment, bullets are the
   right form. Anyone needing more depth reads the source.

## Per-leaf table

| Leaf | Disp | Tgt | Ex | Notes |
|------|------|-----|----|-------|
| 01_The-execution-pipeline | ENRICH | 80 | 1 | xtrace transcript anchoring 10 steps |
| 02_The-bison-grammar | KEEP | 12 | 0 | specialist briefing accurate |
| 03_Variable-storage | KEEP | 13 | 0 | hash-table briefing OK |
| 04_Function-storage | KEEP | 12 | 0 | global-table fact load-bearing |
| 05_The-job-table | KEEP | 11 | 0 | cheatsheet appropriate |
| 06_The-trap-table | KEEP | 11 | 0 | pseudo-signal note key |
| 07_The-execution-environment | KEEP | 16 | 0 | inheritance enumeration is payload |
| 08_Subshell-forking | ENRICH | 60 | 1 | add BASHPID/BASH_SUBSHELL demo |
| 09_Builtin-loadables | ENRICH | 50 | 1 | add `enable -f` invocation |
| 10_Reading-the-bash-source | KEEP | 12 | 0 | source-tour pointers are accurate |
| index | KEEP | 27 | 0 | complete |

## Cross-reference issues

- §24.3 should xref Part 4 (variables) and Part 9 (functions) — the
  storage view complements the user-facing semantics.
- §24.5 (job table) should xref Part 11 (process management) and
  Part 16 (concurrency).
- §24.6 (trap table) should xref Part 12 (signals & traps).
- §24.8 (subshell forking) should xref §22 idioms cookbook for the
  BASHPID idiom — and §17 IPC for shared-fd semantics.
- These are all `[minor]` cross-ref additions; none `[critical]`.

## Self-containment risks

- §24.2 cites `parse.y`/`subst.c` without explaining what bison is. For
  the AI/RAG reader the term is known, but a one-line "(yacc-derived
  parser-generator)" gloss removes the only resolution gap.
- §24.9 mentions `examples/loadables/` without a path on a typical
  install. `/usr/lib/bash/` (Debian/Ubuntu) or `/usr/local/lib/bash/`
  could be cited.

## Code-gap recommendations

Three small ENRICH additions, each ~6–10 lines of code:

1. **§24.1** — `set -x; echo $((1+1))` transcript with the steps
   labelled.
2. **§24.8** — `( echo "subshell PID=$BASHPID parent PID=$$" )`.
3. **§24.9** — a stock `enable -f` invocation pointing at one of the
   shipped loadables (`sleep`, `mkdir`, `realpath`).

These three additions are small but meaningfully ground out three
otherwise-abstract chapters.

#fin
