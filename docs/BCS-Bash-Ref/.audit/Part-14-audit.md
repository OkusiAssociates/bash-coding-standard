<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIV — Input, Output, and Messaging — Audit

**Date:** 2026-05-03
**Priority band:** P1 (foundational, must-have)
**Leaves:** 12 chapters + index = 13 files
**Mean lines/file:** ~14 (skeleton form, mostly bullet-list chapters)

## Summary

Part XIV is generally well-scoped at the topic level but lean on prose and
on code blocks. The strongest chapters are the builtin references (`read`,
`mapfile`, `printf`, format specifiers) where bullet-list flag enumeration
is closer to its final form — these can ENRICH with one or two example
blocks. The discipline chapters (standard streams, logging, colour) need
PROMOTE; they exist to teach the BCS messaging idiom and currently only
gesture at it.

| Disposition | Count |
|-------------|-------|
| KEEP | 2 |
| ENRICH | 8 |
| PROMOTE | 3 |

## Top-5 findings

1. `[major]` **`07_Logging-discipline.md`** — The BCS canonical messaging
   pattern uses `_msg()` with FUNCNAME dispatch (info/warn/error/die/success).
   This chapter mentions the pattern but does not show the implementation.
   The BCS `bcs` script itself depends on this idiom; reference must promote
   to a full ~30-line implementation block.
2. `[major]` **`01_Standard-streams-discipline.md`** — The "stdout=data,
   stderr=diagnostics" rule is foundational for composability and is asserted
   without a worked anti-pattern demonstration. Promote with a broken
   pipeline showing why mixing destroys composability.
3. `[major]` **`09_Coloured-output-and-TERM-detection.md`** — TTY-detection
   gating is the rule but the chapter does not show the BCS pattern of
   conditionally setting `RED`, `GREEN`, etc. to either escape codes or empty
   strings. Needs concrete `[[ -t 1 ]] && ...` initialisation block.
4. `[minor]` **`05_printf-vs-echo.md`** — Anti-`echo` argument is correct
   but lacks a concrete pathological case (`var=-e; echo "$var"`).
5. `[minor]` **`02_The-read-builtin.md`** — Comprehensive flag table; needs
   one or two pattern examples (timeout-loop, NUL-separated `find` pipe).

## Per-leaf table

| Leaf | Cov | Hum | AI | XRef | Strict | Ex | Self | Disp |
|------|-----|-----|----|------|--------|----|------|------|
| 01 streams discipline | med | high | low | low | low | no | no | PROMOTE |
| 02 read | high | high | high | low | low | no | yes | ENRICH |
| 03 mapfile | high | high | high | low | low | no | yes | ENRICH |
| 04 printf | high | high | high | low | low | no | yes | ENRICH |
| 05 printf vs echo | med | high | med | low | low | no | yes | ENRICH |
| 06 format specifiers | high | high | high | low | n-a | n-a | yes | KEEP |
| 07 logging discipline | med | med | low | low | low | no | no | PROMOTE |
| 08 log levels | med | high | med | low | low | no | yes | ENRICH |
| 09 colour/TERM | med | high | low | low | low | no | no | PROMOTE |
| 10 progress | med | high | med | low | low | no | yes | ENRICH |
| 11 binary data | med | high | med | low | low | no | yes | ENRICH |
| 12 file locking | med | high | med | med | low | no | yes | ENRICH |
| index | n-a | high | high | n-a | n-a | n-a | yes | KEEP |

## Cross-reference issues

- `01` and `07` are tightly coupled (stdout/stderr → logging always to
  stderr) but neither links the other.
- `04_The-printf-builtin.md` references the `%(fmt)T` form without linking
  to BCS-bash `30_36_printf.md`.
- `07_Logging-discipline.md` references the BCS `_msg()` pattern without
  linking to BCS standard's Section 7 (Messaging) or to the `bcs` script.
- `12_File-locking-for-concurrent-writes.md` correctly references §12.14
  but should also link forward to §16 (concurrency/parallelism) and to
  Appendix on file-system primitives.
- `11_Reading-binary-data.md` mentions `xxd`, `od`, `hexdump`, `dd` without
  forward link to Part XX (security) where binary-handling caveats live.

## Self-containment risks

- `09_Coloured-output-and-TERM-detection.md` lists ANSI escape codes
  (`\033[31m` etc.) without explanation of `\033` = ESC = `\e` in different
  shells; AI consumers may not resolve.
- `12_File-locking-for-concurrent-writes.md` cites `PIPE_BUF` (4096 bytes
  on Linux) without explaining what `PIPE_BUF` is or where it is defined
  (`<limits.h>`, also reported by `getconf PIPE_BUF`).
- `07_Logging-discipline.md` references `$SCRIPT_NAME` without saying where
  it comes from; needs forward link to BCS Section 1 (Script Structure).

## Code-gap recommendations

- `01` — broken pipeline demo: a script printing diagnostics to stdout,
  piped into `wc -l`; show why count is wrong.
- `02` — timeout-loop pattern: `while read -r -t 1 line; do ... done` with
  exit-status disambiguation (timeout vs EOF).
- `03` — `mapfile -d '' -t arr < <(find . -print0)` idiom.
- `04` — `printf -v var '%s_%s' "$a" "$b"` capture; `%(%F %T)T` timestamp.
- `07` — full `_msg()` + `info()/warn()/error()/die()/success()`
  implementation (~25 lines) matching BCS pattern.
- `09` — TTY-gated initialisation:
  ```bash
  if [[ -t 1 && ${TERM:-} != dumb ]]; then
    declare -gr RED=$'\033[31m' GREEN=$'\033[32m' RESET=$'\033[0m'
  else
    declare -gr RED='' GREEN='' RESET=''
  fi
  ```
- `10` — spinner block + bar block (small, ~10 lines each).

## Strict-mode framing gap

- `read -r` interaction with `set -e`: `read` returns non-zero at EOF, which
  trips `errexit` if used outside an exempt context. §02 needs an explicit
  callout: `while IFS= read -r line; do ... done` is exempt because it is
  the loop condition.
- `printf` failures (write to closed fd) under `pipefail` cause exits
  some readers find surprising.
- `mapfile` does not split on IFS; users coming from `read -a` may be
  surprised. Worth a strict-mode-relevant note.

#fin
