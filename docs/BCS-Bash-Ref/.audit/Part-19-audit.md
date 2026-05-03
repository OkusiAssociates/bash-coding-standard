<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIX — Performance — Audit

Date: 2026-05-03
Priority: P3 (specialist)
Files audited: 14 (13 chapters + index)

## Summary

Part XIX presents the bash cost model, profiling tools, common
optimisations, and a "when bash is the wrong tool" advisory. The skeleton
is generally accurate — cost-magnitude claims (~1ms per fork) are correct
for typical Linux 2026-era hardware — but lacks the citations / benchmark
methodology that would make the claims authoritative. §19.8 is the single
strongest skeleton in the shard: a clean side-by-side table with embedded
benchmark math that genuinely earns KEEP.

Disposition tally: KEEP 6 / ENRICH 7 / PROMOTE 0.

## Top-5 findings

1. **[major] §19.1 Bash cost model presents specific magnitudes
   ("~1 millisecond" per fork) without citing the measurement method.**
   For a reference document this is a credibility issue. ENRICH with a
   one-line benchmark recipe (`for i in {1..1000}; do (true); done`
   timed) and a footnote-style "measured on Linux x86_64 6.x".
2. **[minor] §19.6 `EPOCHREALTIME` example uses `bc -l` to compute the
   delta — exactly the fork-cost the chapter is trying to eliminate.**
   ENRICH with a `printf '%s.%s\n' "$((end_s - start_s))" "..."` or
   leverage bash's float-aware printf where possible.
3. **[minor] §19.11 Bash-5.3 no-fork command-substitution chapter
   describes the variable-leak side-effect but does not show a
   demonstrative example.** ENRICH with vulnerable/safe pair.
4. **[fixable] §19.10 Builtins-vs-externals omits `[[ ]]` to `(( ))` for
   numeric tests, and `mktemp` (no builtin equivalent — same status as
   `sleep`).** Worth adding to the table for completeness; otherwise the
   table is the chapter's strongest cheat-card.
5. **[minor] §19.13 advisory "if this script is over 500 lines, consider
   rewriting it" needs a citation or attribution; otherwise reads as
   editorial whim.** ENRICH with attribution to common bash style guides
   or strike the magic number.

## Per-leaf table

| File | Disposition | Notes |
|------|-------------|-------|
| index.md | KEEP | Complete with orientation prose |
| 01_The-Bash-cost-model.md | ENRICH | Add measurement method + benchmark recipe |
| 02_Profiling-tools.md | ENRICH | Add EPOCHREALTIME instrumentation snippet |
| 03_time-builtin-vs-time-external.md | ENRICH | Show TIMEFORMAT and time -v sample output |
| 04_BASH_XTRACEFD.md | ENRICH | Full exec / fd cleanup example |
| 05_PS4-instrumentation.md | KEEP | Concrete PS4 examples present |
| 06_EPOCHREALTIME-for-sub-second-timing.md | ENRICH | Replace bc fork with arithmetic |
| 07_Common-optimisations.md | KEEP | Concise checklist with internal xrefs |
| 08_Parameter-expansion-vs-external-commands.md | KEEP | Strongest skeleton — table + math |
| 09_Pipes-vs-redirection.md | ENRICH | Add tee replacement example, pipefail-tee gotcha |
| 10_Builtins-vs-externals.md | KEEP | External-to-builtin replacement table |
| 11_Bash-5.3-no-fork-command-substitution.md | ENRICH | Add variable-leak demonstration |
| 12_Memory-considerations.md | ENRICH | Add stream-vs-slurp example |
| 13_When-Bash-is-the-wrong-tool.md | KEEP | Concise heuristics |

## Cross-reference issues

- §19.4 `BASH_XTRACEFD` does not back-link to §13/14 (Error / I/O) or
  §18.13 (PS0–PS4), where related machinery lives.
- §19.5 PS4 instrumentation should reciprocally xref §18.13 Prompts.
- §19.11 mentions Part XXV (Bash 5.3+ futures) topic without xref.
- §19.13 "use Python/jq/etc." should xref Part XXIII (POSIX-conformance
  and Portability) where the tradeoff is also implicit.

## Self-containment risks

- §19.1's "~1ms fork" figure is hardware-specific. RAG retrieval into a
  doc-ingestion-time-different-hardware context could mislead. Frame as
  "order of magnitude on commodity Linux x86_64".
- §19.2 mentions `perf stat` and `strace -c -f` without indicating that
  these are Linux-specific (`perf` definitely; `strace` typically). Note
  in PROMOTE/ENRICH.
- §19.8's "10,000 iterations × 1 fork × 1ms = 10 seconds" math should
  also note "and your feedback loop slows from instant to noticeable" —
  the qualitative impact justifies the quantitative.

## Code-gap recommendations

| Chapter | Required example |
|---------|------------------|
| §19.1 | One-line benchmark recipe; perhaps `time bash -c 'for i in {1..1000}; do :; done' vs forked equivalent` |
| §19.4 | Full `exec 3>>trace.log; BASH_XTRACEFD=3; set -x; …; set +x; exec 3>&-` block |
| §19.6 | Subshell-free EPOCHREALTIME delta (no `bc`) |
| §19.9 | `cmd > out 2>&1` vs `cmd 2>&1 \| tee out`, with note on `set -o pipefail` interaction |
| §19.11 | Vulnerable: `${ x=42; echo done; }` leaks `x`; safe: `$(x=42; echo done)` |
| §19.12 | `mapfile -t arr < file` vs `arr=($(<file))` memory contrast |

Total estimated code-block delta for Part XIX: ~7 blocks across 7 files.

#fin
