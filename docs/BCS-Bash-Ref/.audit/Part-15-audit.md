<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XV — Command-Line Processing — Audit

**Date:** 2026-05-03
**Priority band:** P1 (foundational, must-have)
**Leaves:** 11 chapters + index = 12 files
**Mean lines/file:** ~16 (skeleton form, with two chapters carrying inline code)

## Summary

Part XV is the densest BCS hook-point area in the reference: argument
parsing patterns map to insights `bash-308`/`bash-309` (deferred-action
pattern, relative-path qualification) and to the BCS script template's
`while ... case ... shift` loop. Chapter 04 (the canonical hand-rolled
parser) already has a solid code block — closer to its target form than
most leaves elsewhere. The other chapters are bullet-list skeletons that
ENRICH or PROMOTE depending on whether they need an example. The
auto-generation chapter (§11) is the most under-developed relative to the
BCS toolchain (where help text *is* the parser specification).

| Disposition | Count |
|-------------|-------|
| KEEP | 2 |
| ENRICH | 7 |
| PROMOTE | 2 |

## Top-5 findings

1. `[major]` **`02_getopts-builtin.md`** — POSIX getopts deserves a full
   working loop including the silent-mode (`:`-prefixed OPTSTRING) error
   handling, OPTERR behaviour, and OPTIND reset for re-parse. Currently
   bullet-only.
2. `[major]` **`11_Auto-generating-usage.md`** — The deferred-action /
   single-source-of-truth pattern (cf. insights `bash-308`, `bash-309`) is
   gestured at but not implemented. As the reference for BCS template
   authors, this leaf must show a working spec→help+parser implementation.
3. `[minor]` **`04_Hand-rolled-while-case-shift.md`** — Code block is
   present and canonical but the `noarg` helper is referenced without
   definition; bundling-class character set is referenced without explaining
   how to extend it. ENRICH with definitions.
4. `[minor]` **`06_Bundled-short-options.md`** — Bundling expansion
   (`set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue`) is a famous BCS
   idiom; chapter cites it but does not show why each piece is necessary.
5. `[minor]` **`08_Subcommand-dispatch.md`** — Code block present and
   correct; cross-reference to `bcs` itself (which uses this exact pattern)
   should be explicit and link-resolvable.

## Per-leaf table

| Leaf | Cov | Hum | AI | XRef | Strict | Ex | Self | Disp |
|------|-----|-----|----|------|--------|----|------|------|
| 01 conventions | high | high | high | low | n-a | no | yes | ENRICH |
| 02 getopts | med | high | med | low | low | no | yes | PROMOTE |
| 03 GNU getopt(1) | med | high | high | low | low | no | yes | ENRICH |
| 04 hand-rolled | high | high | high | med | low | yes | yes | ENRICH |
| 05 long options | high | high | high | low | low | no | yes | ENRICH |
| 06 bundled short | high | high | med | low | low | no | yes | ENRICH |
| 07 -- end of opts | high | high | high | low | n-a | no | yes | ENRICH |
| 08 subcommand dispatch | high | high | high | med | low | yes | yes | ENRICH |
| 09 help text | med | high | high | low | n-a | no | yes | ENRICH |
| 10 synopsis grammar | high | high | high | low | n-a | n-a | yes | KEEP |
| 11 auto-gen usage | low | med | low | low | low | no | no | PROMOTE |
| index | n-a | high | high | n-a | n-a | n-a | yes | KEEP |

## Cross-reference issues

- `04_Hand-rolled-while-case-shift.md` references "BCS-bash/04_OPTIONS.md
  and BCS §08" — the §08 reference is to BCS Section 8 but BCS sections are
  numbered differently from this reference's Parts; needs disambiguation.
- `08_Subcommand-dispatch.md` references "(§ 'Subcommand Dispatcher' in
  CLAUDE.md)" — CLAUDE.md is a developer doc not part of the published
  reference; replace with link to a reference example or to the `bcs`
  script.
- `02_getopts-builtin.md` mentions "POSIX shell builtin" without forward
  link to BCS-bash `30_22_getopts.md`.
- `03_GNU-getopt1-external.md` does not link to §02 (getopts) for contrast.
- `05_Long-options.md` and `04_Hand-rolled-while-case-shift.md` overlap;
  the boundary should be made explicit.

## Self-containment risks

- `04` references `noarg` helper and `die` without definitions; needs a
  one-line definition or explicit forward link to BCS §05 (helpers).
- `06_Bundled-short-options.md`'s `set -- "${1:0:2}" "-${1:2}" "${@:2}"`
  trick is opaque without per-piece annotation: `${1:0:2}` is the leading
  short option (e.g., `-a`), `-${1:2}` is the remainder rebuilt as a new
  short-option arg (e.g., `-bc`), `${@:2}` is the rest of the original
  args. AI consumers cannot resolve without the annotation.
- `11_Auto-generating-usage.md` mentions "associative array" and "heredoc"
  patterns without showing either; entirely depends on outside knowledge.

## Code-gap recommendations

- `02` — full `getopts` loop with silent error mode and a single
  value-taking option:
  ```bash
  local OPTIND opt
  while getopts ':vqf:h' opt; do
    case $opt in
      v) VERBOSE=1 ;;
      q) VERBOSE=0 ;;
      f) FILE=$OPTARG ;;
      h) usage; return 0 ;;
      :) die 22 "option -$OPTARG requires a value" ;;
      ?) die 22 "unknown option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND-1))
  ```
- `04` — annotated walkthrough of every line in the canonical block; add
  `noarg` helper definition.
- `06` — annotated bundling expansion with worked input/output.
- `09` — a fully-formed `--help` output sample (~15 lines).
- `11` — single-source-of-truth example: an array of option specs, plus a
  function that emits both the help block and the parser case-arms.

## Strict-mode framing gap

- `getopts` and the hand-rolled loop both interact with `set -e`: any
  failure inside a `case` arm exits unless wrapped. Needs a brief callout.
- `shift` under `shopt -s shift_verbose` warns when there are no args to
  shift; the canonical BCS loop (`while (($#))`) avoids this. Worth flagging
  in §04.
- Argument-validation idiom `noarg "$@"` (which checks `[[ -z ${1:-} || ${1:0:1} == - ]]`)
  uses default-expansion specifically because of `set -u`; chapter 04 should
  state the connection.

#fin
