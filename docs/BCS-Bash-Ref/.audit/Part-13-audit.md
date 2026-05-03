<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIII — Error Handling and Exit Status — Audit

**Date:** 2026-05-03
**Priority band:** P1 (foundational, must-have)
**Leaves:** 12 chapters + index = 13 files
**Mean lines/file:** ~15 (skeleton form)

## Summary

Part XIII covers the most-misunderstood feature in bash (`set -e`) plus its
strict-mode allies (`set -u`, `pipefail`, `inherit_errexit`, `errtrace`, the
`ERR` trap). The brief explicitly tags this Part: **"critical that these
leaves be reference-grade"**. Currently every chapter is a 12-18 line
skeleton, with §13.8 and §13.12 carrying inline code. The exemption matrix
(§13.3) is the single most-cited error-handling reference in the bash world
and must become the canonical version. Six chapters PROMOTE; remaining six
ENRICH.

| Disposition | Count |
|-------------|-------|
| KEEP | 1 |
| ENRICH | 6 |
| PROMOTE | 6 |

## Top-5 findings

1. `[critical]` **`02_set-e-errexit-full-semantics.md`** + **`03_The-errexit-exemption-matrix.md`**
   — These two leaves together ARE the canonical errexit reference for
   downstream readers. Both must be promoted to ~200 lines with one demo per
   exemption row. As-is they are unusable for anyone trying to debug "why
   didn't `set -e` exit".
2. `[critical]` **`11_Propagating-exit-codes.md`** — The
   `local x=$(failing-cmd)` error-eating bug is mentioned only by implication
   (§13.6 inherit_errexit) but not directly in this chapter. This is a P1
   bug that bites every bash author; needs explicit demo here.
3. `[major]` **`05_set-o-pipefail.md`** — `PIPESTATUS[]` array semantics,
   SIGPIPE interaction with pipefail, and the rightmost-non-zero rule's
   surprises (e.g., `cmd | head` exits 141 with pipefail) are absent.
4. `[major]` **`06_inherit_errexit.md`** — The single most-confusion-causing
   shopt in strict mode; needs before/after demo (`result=$(grep foo file)`
   with and without).
5. `[major]` **`04_set-u-nounset.md`** — Array-unset gotcha
   (`${arr[@]}` errors when array unset; `${arr[@]:-}` workaround) and
   positional-parameter exception are mentioned but not demonstrated.

## Per-leaf table

| Leaf | Cov | Hum | AI | XRef | Strict | Ex | Self | Disp |
|------|-----|-----|----|------|--------|----|------|------|
| 01 fundamentals | med | high | med | low | low | no | yes | ENRICH |
| 02 set -e semantics | low | med | low | med | low | no | no | PROMOTE |
| 03 exemption matrix | low | high | low | low | low | no | no | PROMOTE |
| 04 set -u | med | high | med | low | low | no | yes | PROMOTE |
| 05 pipefail | med | high | med | low | low | no | yes | PROMOTE |
| 06 inherit_errexit | med | high | med | low | low | no | yes | PROMOTE |
| 07 ||: idioms | med | high | high | low | low | no | yes | ENRICH |
| 08 ERR trap | high | high | high | med | low | yes | yes | ENRICH |
| 09 errtrace | med | high | med | med | med | no | yes | PROMOTE |
| 10 exit codes | high | high | high | low | n-a | no | yes | ENRICH |
| 11 propagation | low | med | low | low | low | no | no | PROMOTE |
| 12 rich error output | high | high | high | low | low | yes | yes | ENRICH |
| index | n-a | high | high | n-a | n-a | n-a | yes | KEEP |

## Cross-reference issues

- `02_set-e-errexit-full-semantics.md` references §13.3 (good) and §13.8
  (good). Should also forward-link §13.6 (`inherit_errexit`) and §12.6 (ERR
  pseudo-signal).
- `03_The-errexit-exemption-matrix.md` is freestanding — should xref each
  row to a worked demo (post-PROMOTE) and link back from §13.2.
- `06_inherit_errexit.md` says "Bash 4.4+" without linking to BCS-bash
  `30_45_shopt.md` (the shopt reference) or to §11.0 / Part II.
- `09_errtrace-and-trap-inheritance.md` links to neither §12.8 (trap
  inheritance) nor BCS-bash `30_43_set.md`.
- `10_Exit-code-conventions.md` references "BCS codes" inline; should link
  to BCS Section 6 (Error Handling) and to Appendix exit-code table.

## Self-containment risks

- `03` exemption matrix — each row needs a self-contained demonstration; an
  AI consumer cannot infer correctness of "(( expression )) evaluating to
  zero — counts as failure" without seeing it.
- `09` says "Strict-mode scripts often use `set -eET -o pipefail` plus
  `inherit_errexit`" — the actual BCS strict-mode contract is
  `set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob`
  per `BASH-CODING-STANDARD.md`. Reconcile.
- `11_Propagating-exit-codes.md` mentions "last command's status" without
  reference to bash's own definition — needs forward link to BCS-bash
  `23_EXIT-STATUS.md`.

## Code-gap recommendations

- `02` — minimal script demonstrating each major exemption (≥3 examples).
- `03` — one demo per exemption row (target 5 inline blocks).
- `04` — array unset demo + `${arr[@]:-}` workaround.
- `05` — three pipelines: success, middle-fail, last-fail; show `$?` and
  `PIPESTATUS` for each.
- `06` — `result=$(grep foo file)` before/after `shopt -s inherit_errexit`.
- `09` — function-with-ERR-trap inside subshell, with and without `set -E`.
- `11` — `local x=$(false)` bug demo; capture-then-test workaround.

## Strict-mode framing gap

This Part *is* the strict-mode framing — it should set the tone. Current
chapters describe individual flags but never assemble them into the BCS
contract sentence. Recommend a "strict-mode contract" callout in §13.2 or
§13.9 (or both) of the form:

> The BCS strict-mode contract:
> ```
> set -euo pipefail
> shopt -s inherit_errexit shift_verbose extglob nullglob
> ```
> Together these enable the error-detection semantics described in this
> Part. Removing any one component reintroduces a documented hazard.

#fin
