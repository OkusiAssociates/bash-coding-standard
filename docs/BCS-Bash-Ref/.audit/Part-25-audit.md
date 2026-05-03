<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXV Audit — Bash 5.3 and the Future

Date: 2026-05-03
Priority band: **P3**
Leaves audited: 6 (5 chapters + index)

## Summary

Part 25 is forward-looking commentary, deliberately small. Four of the
five chapters (releases, roadmap, forward-compat, additions) are
correctly stub-form because they concern *future* events that should not
be over-elaborated. Only the headline-feature chapter — `${ cmd; }`
no-fork command substitution — warrants a code-block demonstration
because the side-effect-persistence behaviour is non-obvious.

KEEP / ENRICH / PROMOTE = **5 / 1 / 0** (incl. index).

This Part overlaps `23_Forward-compatibility-hygiene.md` intentionally;
the duplication is editorially fine.

## Top 5 findings

1. `[minor]` `01_No-fork-command-substitution-cmd.md` is the chapter
   that earns a code block: a 6-line `${ ... ; }` demo showing variable
   changes persisting to the parent scope vs `$(...)` losing them. Currently
   bullet-only.
2. `[minor]` `02_Other-Bash-5.3-additions.md` correctly defers to the
   bash 5.3 NEWS file — this kind of stub-by-design is appropriate for a
   moving target.
3. `[minor]` `03_Release-cadence.md` cites the major-release timeline
   accurately. KEEP.
4. `[minor]` `04_Roadmap-signals.md` is forward-looking commentary, not
   a reference. Bullet form correct.
5. `[minor]` `05_Forward-compatibility-considerations.md` overlaps with
   §23.11 by ~80%. Not a defect — both Parts have legitimate reasons to
   carry the same advice. Could add an explicit reciprocal cross-ref.

## Per-leaf table

| Leaf | Disp | Tgt | Ex | Notes |
|------|------|-----|----|-------|
| 01_No-fork-command-substitution-cmd | ENRICH | 60 | 1 | demo side-effect persistence |
| 02_Other-Bash-5.3-additions | KEEP | 12 | 0 | stub-by-design |
| 03_Release-cadence | KEEP | 11 | 0 | historical fact |
| 04_Roadmap-signals | KEEP | 13 | 0 | forward-looking; bullet form correct |
| 05_Forward-compatibility-considerations | KEEP | 12 | 0 | overlap with §23.11 intentional |
| index | KEEP | 22 | 0 | complete |

## Cross-reference issues

- §25.1 should xref Appendix M (version history) — `${ cmd; }` is the
  marquee 5.3 feature noted there.
- §25.5 ↔ §23.11 should be reciprocally cross-linked. Currently neither
  side acknowledges the other.
- §25.4 should xref Appendix Q (further reading) for the bug-bash
  mailing list URL — currently in §25.4 directly, fine, but the appendix
  should be the canonical source.

## Self-containment risks

- None of substance. Forward-looking commentary is a register that
  tolerates external resolution; the reader who wants depth follows the
  bug-bash link.
- The "(saves ~1 ms per call)" claim in §25.1 is a soft figure that
  varies by host; keeping it as a soft claim is fine.

## Code-gap recommendations

One small ENRICH:

1. **§25.1** — minimal demo, ~6 lines:
   ```bash
   x=outer
   $(x=inner; echo $x)        # prints "inner"; outer x untouched
   ${ x=inner; echo $x; }     # prints "inner"; outer x is now "inner"
   ```
   Anchor the side-effect-persistence claim and the "no fork" claim in
   the same example.

#fin
