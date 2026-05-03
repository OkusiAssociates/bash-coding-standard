<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part 01 — The Unix Model from Bash — Audit

## Summary
- Leaves audited: 10 (9 chapters + index)
- KEEP / ENRICH / PROMOTE: 1 / 4 / 5
- Code-block coverage: 0 of 10 leaves contain at least one fenced code block
- Strict-mode framing: low (Part frames Unix substrate, not Bash semantics — strict-mode framing only relevant for §1.7 exit codes and §1.4 stream discipline)
- Cross-reference density: medium (forward refs to §11.6, §17.6, §20.2/.8, §14.5, §12.5/.6, BCS Appendix L all present but unresolvable for a RAG retrieval over a single leaf)

## Highest-leverage findings (top 5)
1. §1.1 (Processes) and §1.2 (fd model) are the conceptual foundation for half the rest of the reference and are currently 14-line bullet lists. Highest impact PROMOTE in this Part. Both need a single concrete worked example (a fork+exec walkthrough; an `ls -l /proc/$$/fd` snapshot).
2. §1.7 (Exit status) cites the BCS exit-code table by xref to Appendix L. For a strict RAG view of just this leaf, the table is missing — inline the 8-row table verbatim. Self-containment fix.
3. §1.5 (Shell environment) treats `export` semantics, IFS, locale, ulimit, umask, PATH security as bullets. This is the gateway chapter for all of Part IV — needs a concrete env-propagation demo to anchor the ideas.
4. No leaf in Part I contains a fenced code block. The Unix Model can be taught largely in prose, but every chapter benefits from one inspection command (`getuid`, `[[ -t 0 ]]`, `lsof -p $$`, `kill -l`, `stty -a`).
5. §1.9 (TTY) confuses two domains — terminal device taxonomy and line-discipline state. PROMOTE candidate; needs a clear separation of "what is a TTY" from "how does cooked mode work".

## Per-leaf table
| File | Disposition | Coverage | Human | AI/RAG | Xref | Strict | Example | Notes |
|------|-------------|----------|-------|--------|------|--------|---------|-------|
| 01_Processes-fork-exec-wait.md | PROMOTE | med | high | low | high | low | no | Foundational; bullets enumerate but cannot replace a worked example |
| 02_The-file-descriptor-model.md | PROMOTE | med | high | low | med | low | no | Substrate for Part VI; needs fd-table mental model |
| 03_Files-directories-and-special-files.md | ENRICH | high | high | med | med | low | no | Solid cheatsheet; one stat snippet would close the gap |
| 04_Streams-and-the-standard-descriptors.md | ENRICH | med | high | med | med | med | no | `[[ -t N ]]` mentioned but not shown; buffering ideas need contrast example |
| 05_The-shell-environment.md | PROMOTE | med | high | low | high | low | no | Gateway to export, IFS, locale; demands prose plus demo |
| 06_Users-groups-permissions.md | ENRICH | high | high | med | med | low | no | Bullet list adequate; one ruid-vs-euid demo plus chmod example would lift it |
| 07_Exit-status-and-process-termination.md | PROMOTE | med | high | low | high | med | no | BCS Appendix L xref unresolvable; inline the table |
| 08_Signals-overview.md | ENRICH | high | high | med | high | low | no | Correctly defers depth to Part XII; add a short signal table |
| 09_The-controlling-terminal-and-TTY-layer.md | PROMOTE | med | high | low | med | low | no | Two domains conflated; rewrite needed |
| index.md | KEEP | high | high | high | high | n-a | n-a | Standard index page, complete |

## Cross-reference issues
None broken. Forward refs §11.6 (process groups), §17.6 (`/dev/tcp`), §20.2/§20.8 (PATH security, SUID), §14.5 (printf vs echo), §12.5/§12.6 (trap, pseudo-signals), §5.13 (locale) all match the live skeleton TOC. **However**, §1.7's reference to "Appendix L" needs a forward-pointer file under `99_Appendices/` named L_*.md — this should be verified by the appendix-shard auditor.

## Self-containment risks
- §1.7 cites BCS exit-code table by Appendix L reference. RAG retrieval of this leaf alone returns no exit-code values. **Recommend inlining the 8-row table.**
- §1.1 mentions "see §11.6 for the deeper treatment" of process groups and sessions. RAG would not have §11.6.
- §1.4 references §14.5 for `printf` over `echo` — same self-containment issue.
- §1.5 references §5.13 (locale) and §20.2 (PATH security) — same.
- §1.8 defers entirely to Part XII for signal depth. RAG retrieval of this leaf returns concept enumeration only.

These are not auto-fixable — the architectural decision is "should leaves be self-contained or rely on the assembled document context?" Flag for user.

## Code-gap recommendations
All nine substantive chapters need at least one fenced code block. Highest priority:
1. §1.1 — `pid=$BASHPID; (sleep 0; echo "child=$BASHPID parent=$$") &` to demonstrate `$$` vs `$BASHPID`.
2. §1.2 — `ls -l /proc/$$/fd` and a `dup2`-via-redirection example (`exec 3>&1`).
3. §1.5 — `export X=value; bash -c 'echo $X'` and the bare-shell-var counterexample.
4. §1.7 — `( exit 42 ); echo $?` and `( kill -TERM $BASHPID ); echo $?` to show 128+15 encoding.
5. §1.9 — `[[ -t 0 ]] && echo terminal || echo redirected` and `stty -a | head`.

#fin
