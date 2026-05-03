<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XI — Process Management — Audit

**Date:** 2026-05-03
**Priority band:** P1 (foundational, must-have)
**Leaves:** 13 chapters + index = 14 files
**Mean lines/file:** ~14 (skeleton form)

## Summary

Part XI is the engineering layer for the bash process model. Phase-1 evidence
flagged this as one of the weakest areas of the reference. Coverage is
adequate at the topic level — the chapter inventory matches the content a
working bash author needs (process tree, PID variables, subshell origins,
job control, signal delivery, detachment, env inheritance) — but every
chapter is a 10-18 line bullet skeleton. None demonstrates the constructs
it names. As a downstream prose-authoring target, Part XI is dominated by
**PROMOTE** dispositions on the foundational chapters (process tree, PID
variables, subshell origins, foreground/background, process groups,
detachment) where worked examples are essential, with **ENRICH** for the
tighter cheatsheet-shaped chapters (BASH_SUBSHELL, job table, job specs,
job-control builtins, kill, env inheritance) and a single **KEEP** for the
Part index.

| Disposition | Count |
|-------------|-------|
| KEEP | 2 |
| ENRICH | 6 |
| PROMOTE | 6 |

## Top-5 findings

1. `[major]` **`02_PIDs-BASHPID-PPID.md`** — `$$` vs `$BASHPID` is the most-misread
   trio of variables in bash. The skeleton lists the rule but a reference must
   show a subshell exercise: parent prints `$$` and `$BASHPID`, subshell
   prints them again, output proves the divergence. Without that example, AI
   consumers will hallucinate semantics.
2. `[major]` **`01_The-Bash-process-tree-at-runtime.md`** — Construct → tree-shape
   table needs a `pstree -p $$` snapshot from a script that exercises each
   construct (`$()`, `( )`, `{ }`, `|`, `&`). The fork/no-fork distinction is
   foundational and asserted only as a bullet.
3. `[major]` **`03_Subshell-origins.md`** — Catalogue of forking constructs is
   correct but `lastpipe` interaction (a known pipeline-no-subshell exception)
   is missing; without it the rule "pipeline forks at least one subshell" is
   wrong on the rightmost component when `shopt -s lastpipe` is active and the
   shell is non-interactive.
4. `[major]` **`05_Foreground-vs-background.md`** — `wait`, `wait -n`, and
   `$!` are the building blocks of every concurrency idiom (Part XVI builds on
   them). Promote with multi-child `wait -n` example and SIGCHLD interaction
   note.
5. `[major]` **`12_Detaching-from-the-terminal.md`** — Currently 10 lines of
   prose about an inherently long topic (double-fork daemonisation). Needs a
   real bash skeleton or an explicit deferral to systemd with worked unit
   file. As-is the chapter cannot be consumed by a reader who needs to write a
   detached worker.

## Per-leaf table

| Leaf | Cov | Hum | AI | XRef | Strict | Ex | Self | Disp |
|------|-----|-----|----|------|--------|----|------|------|
| 01 process tree | med | high | low | low | low | no | no | PROMOTE |
| 02 PID vars | med | high | low | low | low | no | no | PROMOTE |
| 03 subshell origins | med | med | low | low | low | no | no | PROMOTE |
| 04 BASH_SUBSHELL | med | high | med | low | low | no | yes | ENRICH |
| 05 fg/bg | med | high | low | low | low | no | no | PROMOTE |
| 06 pgrp/sess | med | med | low | low | low | no | no | PROMOTE |
| 07 job table | med | high | med | low | low | no | yes | ENRICH |
| 08 job specs | high | high | high | low | n-a | n-a | yes | KEEP |
| 09 jc builtins | med | high | med | low | low | no | yes | ENRICH |
| 10 kill | med | high | med | low | low | no | yes | ENRICH |
| 11 nohup/setsid | med | med | low | low | low | no | no | PROMOTE |
| 12 detach | low | med | low | low | low | no | no | PROMOTE |
| 13 env inherit | med | high | med | low | low | no | yes | ENRICH |
| index | n-a | high | high | n-a | n-a | n-a | yes | KEEP |

## Cross-reference issues

- `05_Foreground-vs-background.md` mentions `wait`, `wait -n`, and `huponexit`
  but does not link forward to §12.10 (synchronous vs asynchronous delivery)
  or §16 (concurrency).
- `06_Process-groups-and-sessions.md` cites `setpgid(2)` etc. without a clear
  pointer to BCS-bash `25_JOB-CONTROL.md` or the bash5.2 unfiltered reference.
- `10_kill-and-signal-delivery.md` mentions `pkill`/`killall` but has no
  forward link to §12 (signals & traps) or §11.6 (process groups).
- `11_nohup-and-setsid.md` and `12_Detaching-from-the-terminal.md` overlap;
  the boundary between them is implicit and should be linked from each side.
- `13_Environment-inheritance.md` references `ARG_MAX` without xref to
  Appendix or to §02 (Bash as a Program — limits).

## Self-containment risks

- Several chapters cite syscalls (`setpgid(2)`, `setsid(2)`, `tcsetpgrp`)
  without explanation — an AI/RAG consumer cannot resolve these. ENRICH
  candidates need a one-line gloss or pointer to `man 2 setpgid`.
- `01_The-Bash-process-tree-at-runtime.md` says "fork per command (typically)"
  for pipelines without spelling out the `lastpipe` exception. A solo
  consumer reading this leaf will not know the exception exists.
- `04_BASH_SUBSHELL-depth-tracking.md`'s "library code can check
  `(( BASH_SUBSHELL == 0 ))`" is a useful idiom but needs a rationale
  (refusing to run as a forked child) to be self-contained.

## Code-gap recommendations

P1 critical code blocks that must appear after expansion:

- `01` — script that calls `pstree -p $$` and shows the tree under various
  constructs (fork demonstration).
- `02` — parent/subshell exercise comparing `$$` and `$BASHPID`.
- `03` — `lastpipe` demo (variable persistence proves no fork).
- `05` — multi-child `wait -n` worker pool with `$!` capture.
- `06` — `ps -o pid,pgid,sid,comm` output sample.
- `09` — `disown -h` to detach but keep on SIGHUP-immune list.
- `11` — three-way comparison: `nohup cmd &` vs `setsid cmd` vs `cmd & disown`.
- `12` — `setsid bash -c '...'` skeleton plus reference to systemd unit.

## Strict-mode framing gap

No chapter in Part XI mentions `set -euo pipefail` or `inherit_errexit` even
once. Process-management code paths interact with strict mode in non-obvious
ways (e.g., backgrounded jobs and `pipefail`, `wait` and `errexit`,
subshell-in-`$()` and `inherit_errexit`). PROMOTE chapters should each carry
a "Strict-mode interaction" stanza.

#fin
