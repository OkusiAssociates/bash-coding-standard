<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVII — Coprocesses and IPC — Audit

Date: 2026-05-03
Priority: P3 (specialist)
Files audited: 10 (9 chapters + index)

## Summary

Part XVII covers coprocesses (`coproc`), FIFOs, anonymous pipes, `/dev/tcp`
and `/dev/udp`, `/dev/shm`, and external IPC tools. Specialist material — a
P3 part — but heavy on subtle semantics (fd lifetimes, blocking-open, SIGPIPE,
buffering deadlocks). Skeleton is uneven: §17.2 has a working coproc example
yet the foundational §17.1 has none, and §17.3 (multiple coprocs) has neither.
The decision-tree in §17.9 and the external-tool register in §17.8 are
genuinely cheat-card-shaped and KEEP.

Disposition tally: KEEP 3 / ENRICH 5 / PROMOTE 1.

## Top-5 findings

1. **[major] §17.3 Multiple coprocesses skeleton has no example and no
   pre-4.4 caveat in the body.** Anyone reading this without prior
   knowledge will not know how to demux output from two coprocs (you must
   `read -u "${A[0]}"` vs `read -u "${B[0]}"` — the array fd dereference is
   non-obvious). PROMOTE with a two-coproc demo.
2. **[major] §17.2 mentions buffering deadlocks but does not show the
   `stdbuf -oL` workaround in code.** This is the single most-asked
   coproc question. ENRICH with a side-by-side block.
3. **[minor] §17.4 FIFO chapter omits trap-cleanup discipline.** A FIFO
   created without a trap leaks on script death — readers will copy the
   bullet code and ship the leak. ENRICH with `trap 'rm -f "$FIFO"' EXIT`.
4. **[minor] §17.5 anonymous-pipes references `§6.13` for pipeline subshell
   semantics; verify the cross-reference resolves** (Part 6 is
   Redirection-and-Pipelines but section ordering must be confirmed). The
   audit cannot verify cross-Part anchors; flag for §6 audit.
5. **[minor] §17.6 `/dev/tcp` cheatsheet splits an HTTP probe across four
   bullets; consolidate into one runnable code block.** Skim-test fails:
   reader cannot see the full sequence at a glance.

## Per-leaf table

| File | Disposition | Notes |
|------|-------------|-------|
| index.md | KEEP | Complete chapter index |
| 01_The-coproc-builtin.md | ENRICH | Add minimal invocation block |
| 02_Bidirectional-fd-pairs.md | ENRICH | Add `stdbuf -oL` deadlock demo |
| 03_Multiple-coprocesses.md | PROMOTE | Two-coproc example required |
| 04_Named-pipes-FIFOs.md | ENRICH | Add trap-cleanup example |
| 05_Anonymous-pipes.md | ENRICH | Verify §6.13 xref; mention pipefail |
| 06_devtcp-and-devudp.md | ENRICH | Consolidate scattered HTTP example |
| 07_devshm-shared-memory.md | ENRICH | Add tmpfs size detection |
| 08_External-IPC-tools.md | KEEP | Cheatsheet of escape-hatches OK |
| 09_Choosing-the-right-primitive.md | KEEP | Decision tree concise and complete |

## Cross-reference issues

- §17.5 references `§6.13` (pipeline subshell semantics) — verify anchor
  exists in Part VI; the path traversal `../06_Redirection-and-Pipelines/`
  contains numbered files but the audit cannot confirm chapter 13 exists
  there from this shard.
- §17.6 `/dev/tcp` chapter should xref §20 Security on
  cleartext-protocol-leak; not present.
- §17.8 lists `socat` and `redis-cli` without any link to §20.9 secrets
  handling — relevant for credentials in URI form.

## Self-containment risks

- §17.1 references `NAME_PID` env var but does not show the dereference
  pattern (`"${NAME_PID}"` vs literal). Confusing in RAG.
- §17.2 example uses `bc -l` but readers may not have `bc`; mention
  `awk` alternative or call it out as illustrative.
- §17.7 `/dev/shm` notes "not all systems mount" but does not show how to
  detect (`mountpoint -q /dev/shm`). Add one-liner.

## Code-gap recommendations

| Chapter | Required example |
|---------|------------------|
| §17.1 | Minimal `coproc CALC { bc -l; }` invocation showing array fd dereference |
| §17.2 | stdbuf -oL deadlock-fix demo |
| §17.3 | Two-coproc demux with `read -u "${A[0]}"` / `read -u "${B[0]}"` |
| §17.4 | FIFO + trap cleanup; producer-consumer round-trip |
| §17.6 | Single consolidated HTTP/1.0 probe block |

Total estimated code-block delta for Part XVII: ~7 blocks across 6 files.

#fin
