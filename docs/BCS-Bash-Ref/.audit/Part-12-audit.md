<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XII — Signals and Traps — Audit

**Date:** 2026-05-03
**Priority band:** P1 (foundational, must-have)
**Leaves:** 16 chapters + index = 17 files
**Mean lines/file:** ~14 (skeleton form, with 4 chapters carrying inline code blocks)

## Summary

Part XII is in better shape than Part XI: chapters 13 (tempfiles), 14
(lockfile), 15 (atomic write), and 16 (SIGHUP reload) already carry working
code blocks. The conceptual chapters (signal taxonomy, dispositions, trap
builtin, pseudo-signals, inheritance, sync vs async delivery, signal-safe
code) remain skeletons. The pseudo-signal chapter and the trap-builtin
chapter are the most-consequential PROMOTE targets — they are referenced from
half the rest of the reference and from BCS itself. The "wait-and-invert"
idiom flagged in the brief is not yet present in §12.10 and is the single
biggest content gap.

| Disposition | Count |
|-------------|-------|
| KEEP | 2 |
| ENRICH | 9 |
| PROMOTE | 6 |

## Top-5 findings

1. `[major]` **`06_Pseudo-signals-EXIT-ERR-DEBUG-RETURN.md`** — Each of the
   four pseudo-signals deserves its own subsection with a worked example.
   This is one of the most-cross-referenced files in the entire reference;
   skeleton form is unacceptable for a P1 leaf.
2. `[major]` **`05_The-trap-builtin.md`** — Single-vs-double-quote
   handler-expansion pitfall is mentioned but not demonstrated. This is the
   single most-common trap bug; reference must show before/after.
3. `[major]` **`10_Synchronous-vs-asynchronous-delivery.md`** — The
   "wait-and-invert" idiom (run a long command in background, `wait $!` in
   foreground, restore SIGCHLD trap) is not present. Brief explicitly calls
   it out as a strict-mode-critical pattern.
4. `[major]` **`08_Trap-inheritance.md`** — Matrix of (trap-type) ×
   (inheriting-context) × (set -E / set -T / extdebug) is non-obvious. The
   chapter currently lists rules in prose; a tabular form is mandatory for
   reference grade.
5. `[major]` **`11_Signal-safe-code.md`** — Async-signal-safety in bash is
   poorly documented elsewhere; this chapter is the canonical place for the
   "set a flag, defer, return" idiom but currently only names it without
   showing it.

## Per-leaf table

| Leaf | Cov | Hum | AI | XRef | Strict | Ex | Self | Disp |
|------|-----|-----|----|------|--------|----|------|------|
| 01 taxonomy | med | high | high | low | n-a | n-a | yes | ENRICH |
| 02 numbers/names | high | high | high | med | n-a | n-a | yes | KEEP |
| 03 uncatchable | med | high | high | low | low | no | yes | ENRICH |
| 04 disposition | med | high | med | low | low | no | yes | ENRICH |
| 05 trap builtin | med | med | low | low | low | no | no | PROMOTE |
| 06 pseudo-signals | low | med | low | med | low | no | no | PROMOTE |
| 07 trap -p | high | high | med | low | n-a | no | yes | ENRICH |
| 08 trap inheritance | low | med | low | low | low | no | no | PROMOTE |
| 09 trap reset on exec | high | high | med | low | n-a | no | yes | ENRICH |
| 10 sync vs async | low | med | low | low | low | no | no | PROMOTE |
| 11 signal-safe | low | med | low | low | low | no | no | PROMOTE |
| 12 idempotent cleanup | med | high | med | low | low | no | yes | ENRICH |
| 13 tempfile/dir | high | high | high | med | low | yes | yes | ENRICH |
| 14 lockfile | high | high | high | low | low | yes | yes | ENRICH |
| 15 atomic write | high | high | high | low | low | yes | yes | ENRICH |
| 16 SIGHUP reload | med | high | med | low | low | yes | yes | ENRICH |
| index | n-a | high | high | n-a | n-a | n-a | yes | KEEP |

## Cross-reference issues

- `06_Pseudo-signals-EXIT-ERR-DEBUG-RETURN.md` introduces ERR but the full
  ERR mechanics live in §13.8/§13.9; chapter must forward-link explicitly.
- `08_Trap-inheritance.md` references `set -E`, `set -T`, `extdebug` without
  cross-link to §13.9 (errtrace) or BCS-bash `30_43_set.md` / `30_45_shopt.md`.
- `13_Tempfile-and-tempdir-lifecycle.md` references `die` and the
  trap-on-EXIT pattern without linking to §13.10 (exit codes) or the BCS
  template.
- `14_Lockfile-pattern.md` references `flock` as a builtin — incorrect; it
  is an external from `util-linux`. `[fixable]` candidate for auto-fix log.
- `16_Reload-on-SIGHUP.md` uses `info` helper without xref to §14.7
  (logging discipline).

## Self-containment risks

- `02_Signal-numbers-and-names.md` defers full table to "Appendix K" — the
  appendix must exist and be populated for this leaf to be self-contained.
  Audit other shards for confirmation.
- `11_Signal-safe-code.md` claims "bash may queue or coalesce" signals
  during handler execution without citing source. AI consumers will need
  either a bash5.2 manpage pointer or evidence.
- `12_Idempotent-cleanup-patterns.md` shows `[[ -n ${_CLEANED:-} ]] &&
  return; _CLEANED=1` — the `:- ` form requires `set -u` knowledge to be
  parsed; ENRICH should add a sentence on why the default-expansion is
  there.

## Code-gap recommendations

- `05_The-trap-builtin.md` — paired example: `trap "echo $var" EXIT`
  vs `trap 'echo $var' EXIT` with output proving the difference.
- `06_Pseudo-signals-EXIT-ERR-DEBUG-RETURN.md` — four worked examples, one
  per pseudo-signal, each ~6 lines.
- `08_Trap-inheritance.md` — markdown matrix table plus minimal proof
  scripts (function-with-ERR-trap inside subshell, with and without `-E`).
- `10_Synchronous-vs-asynchronous-delivery.md` — `sleep 1000` + `trap INT`
  walkthrough; **then** wait-and-invert idiom: `cmd & wait $!` so SIGINT
  reaches `cmd` rather than just bash.
- `11_Signal-safe-code.md` — flag-and-defer pattern: handler sets `STOP=1`,
  main loop checks it.

## Strict-mode framing gap

Trap interaction with strict mode is non-obvious:

- ERR trap interacts with `set -e` exemption matrix (§13.3) — chapter 06
  needs explicit "ERR trap fires under same conditions as `set -e` exit".
- EXIT trap fires *after* the failing command sets `$?`, so cleanup code
  can capture it: `trap 'rc=$?; ...' EXIT`. Currently absent from §12.05/06.
- `inherit_errexit` does not affect trap inheritance — a frequent confusion;
  flag in §08.

#fin
