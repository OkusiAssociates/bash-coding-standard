<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVI — Concurrency and Parallelism — Audit

Date: 2026-05-03
Priority: P2 (high-value)
Files audited: 13 (12 chapters + index)

## Summary

Part XVI covers a load-bearing topic for production bash: background jobs,
`wait`/`wait -n`, bounded fan-out, `xargs -P`, GNU parallel, races, locking,
signal handling, and queues. The skeleton form is dangerous here — concurrency
chapters that omit code are *worse* than no chapter, because readers
extrapolate wrong patterns from underspecified bullet hints. Phase-1 flagged
"thin strict-mode framing" and the audit confirms: only 5/12 chapters even
mention strict-mode interaction; only 3/12 carry an example. The two chapters
most likely to be searched by real engineers — locking primitives and
signal-handling-under-concurrency — are exactly the two thinnest.

Disposition tally: KEEP 2 / ENRICH 7 / PROMOTE 4. Above the
expected-PROMOTE rate for P2 because correctness bugs lurk in every
concurrency anti-pattern.

## Top-5 findings

1. **[critical] §16.5 contains a buggy idiom.** The example removes a PID
   from the array via `pids=("${pids[@]/$done_pid}")`, which uses the
   *substring-replacement* parameter expansion across array elements rather
   than removing the matching element. This will leave empty strings in the
   array and incorrectly count concurrency. Promote and fix; canonical idiom
   is `pids=("${pids[@]/$done_pid/}")` followed by a re-pack, or a loop
   filter.
2. **[major] §16.10 Locking primitives is the most-needed chapter and the
   thinnest.** No worked `flock` example. The canonical
   `(flock -x 200; ...) 200>/var/lock/foo` subshell pattern must appear, as
   must mkdir-as-mutex with cleanup-trap discipline. PROMOTE.
3. **[major] §16.11 Signal-handling-under-concurrency lacks the
   trap-and-forward template.** Without it, fan-out scripts orphan children
   on Ctrl-C. The reference must show `trap 'kill 0' INT TERM` /
   `trap 'kill "${pids[@]}" 2>/dev/null' EXIT` and reason about pgid vs pid.
   PROMOTE.
4. **[major] §16.9 Race conditions skeleton conflates several distinct race
   classes (TOCTOU, symlink, signal-during-handler) into one bullet list
   with no fixes.** Each deserves at least a vulnerable/fixed pair. Cross-
   ref §20.13 must resolve. PROMOTE.
5. **[minor] §16.4 Capturing per-child exit status duplicates §16.3 without
   adding the multi-pid aggregation pattern that justifies its existence.**
   Either merge with §16.3 or PROMOTE with a full `pids[]`/`status[]`
   parallel-array template.

## Per-leaf table

| File | Disposition | Notes |
|------|-------------|-------|
| index.md | KEEP | Complete chapter index |
| 01_Sequential-vs-background-execution.md | ENRICH | Add `disown` contrast and redirect example |
| 02_wait-and-wait-n.md | ENRICH | Need `wait -n` loop demo and pre-5.1 fallback |
| 03_wait-pid-for-specific-child.md | KEEP | Concise, has example |
| 04_Capturing-per-child-exit-status.md | PROMOTE | Needs full parallel-array template |
| 05_Bounded-concurrency-fan-out.md | ENRICH | Fix buggy `${pids[@]/$done_pid}` idiom |
| 06_The-job-table-under-concurrency.md | ENRICH | Add `jobs` output sample, `disown` semantics |
| 07_xargs-P.md | ENRICH | Add `find -print0` pipe demo, line-buffer pitfall |
| 08_GNU-parallel.md | ENRICH | Add citation guidance, `:::` separator demo |
| 09_Race-conditions-in-shell.md | PROMOTE | Each race class needs vulnerable/fixed pair |
| 10_Locking-primitives.md | PROMOTE | `flock` subshell pattern missing — load-bearing |
| 11_Signal-handling-under-concurrency.md | PROMOTE | Trap-and-forward template required |
| 12_Queue-patterns.md | ENRICH | Need at least one fifo producer-consumer block |

## Cross-reference issues

- §16.9 references symlink-race fixes without xref to §20.13. **Add
  `→ §20.13`.**
- §16.5 references "GNU parallel" without xref to §16.8. **Add `→ §16.8`.**
- §16.10 references `noclobber` lock pattern without xref to §20.10. **Add
  `→ §20.10`.**
- §16.11 references `kill 0` (process-group) without xref to Part XII
  Signals or §11.x process-management. **Add `→ §11`/`§12`.**

## Self-containment risks

- "BCS pattern" implicit in several bullets but never named. RAG retrieval
  on these chapters will not surface the relevant BCS rule. Inline at least
  the rule code (e.g., `BCS0905` for trap discipline) in PROMOTE expansions.
- §16.9 says "Tempfile races: `mktemp` is safe; `tempfile` is not on all
  systems." A RAG agent will not know what `tempfile` is. Either drop the
  reference or explain it.
- "Bash 4.3+" / "Bash 5.1+" version bumps are scattered across §16.2
  bullets without a feature-matrix. Consider an inline mini-table.

## Code-gap recommendations

PROMOTE chapters require these concrete blocks:

| Chapter | Required example |
|---------|------------------|
| §16.4 | Parallel-array `pids[]` / `status[]` aggregation with non-zero detection |
| §16.9 | Vulnerable/fixed pair for each race class (TOCTOU, symlink, lock) |
| §16.10 | `flock`-subshell, `mkdir`-mutex, `noclobber`-create — three blocks |
| §16.11 | Trap-and-forward fan-out skeleton with EXIT cleanup of children |

ENRICH chapters need one inline code block each (typically 4–10 lines).
Total estimated code-block delta for Part XVI: ~25 blocks across 11 files.

#fin
