<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXIII Audit — POSIX Conformance and Portability

Date: 2026-05-03
Priority band: **P3**
Leaves audited: 13 (12 chapters + index)

## Summary

Part 23 is by editorial intent a **comparison cheat-sheet**, not a code
reference. Most chapters enumerate features-Bash-has-but-X-does-not, or
explain a portability target's quirks. Bullet enumeration is the right
form for ten of the twelve chapters; only two warrant code blocks.

KEEP / ENRICH / PROMOTE = **9 / 4 / 0** (incl. index).

This is the highest KEEP ratio in the shard — appropriate, because
cheatsheets succeed when they are tight and accurate, and all twelve
chapters are tight and accurate.

## Top 5 findings

1. `[minor]` `02_The-bashisms-list.md` and `01_Bash-vs-POSIX-sh.md` are
   complementary and both KEEP. Together they constitute a complete
   bashism catalogue for the reader who needs it.
2. `[major]` `12_Targeting-multiple-Bash-versions.md` is the chapter
   whose payload should be a code block (`(( BASH_VERSINFO[0] >= 4 ))`
   gate plus a polyfill example). Currently bullet-only — ENRICH.
3. `[minor]` `03_Bash-vs-dash.md` should mention `checkbashisms` more
   prominently, ideally with a sample invocation. Currently in 02 but not
   tied to dash-specific testing.
4. `[minor]` `05_Bash-vs-zsh.md` mentions `setopt KSH_ARRAYS` without
   showing the user-visible difference. A 6-line code block contrasting
   bash and zsh word-splitting closes this.
5. `[minor]` `09_shopt-compatibility-levels.md` correctly recommends
   *not* using `compatNN`. The advice is pure BCS posture — no code
   needed.

## Per-leaf table

| Leaf | Disp | Tgt | Ex | Notes |
|------|------|-----|----|-------|
| 01_Bash-vs-POSIX-sh | KEEP | 22 | 0 | bashism enumeration; n-a |
| 02_The-bashisms-list | KEEP | 18 | 0 | tight contrasts |
| 03_Bash-vs-dash | ENRICH | 50 | 1 | add checkbashisms invocation |
| 04_Bash-vs-ksh | KEEP | 12 | 0 | specialist niche |
| 05_Bash-vs-zsh | ENRICH | 60 | 1 | KSH_ARRAYS + word-split contrast |
| 06_Bash-3.2-on-macOS | KEEP | 11 | 0 | cheatsheet appropriate |
| 07_BSD-sh | KEEP | 11 | 0 | terse and accurate |
| 08_posix-mode | KEEP | 11 | 0 | short but complete |
| 09_shopt-compatibility-levels | KEEP | 11 | 0 | BCS posture intact |
| 10_When-to-write-portable-sh | KEEP | 12 | 0 | use-case enumeration |
| 11_Forward-compatibility-hygiene | KEEP | 12 | 0 | rule-based hygiene |
| 12_Targeting-multiple-Bash-versions | ENRICH | 50 | 1 | needs version-gate block |
| index | KEEP | 30 | 0 | complete |

## Cross-reference issues

- §23.6 (macOS bash 3.2) should xref Appendix M (version history) —
  presently doesn't.
- §23.9 (compat levels) should xref BCS-bash editorial note in
  `docs/CLAUDE.md` (compat31–compat51 dropped from BCS-bash). A
  one-liner suffices.
- §23.11 → §25.5 forward-compat overlap is intentional editorially;
  could note the duplication explicitly.

## Self-containment risks

- None of substance. The Part is editorially designed as a cheatsheet
  set; the bullets resolve without external knowledge.
- `02_The-bashisms-list.md` mentions "POSIX 2024 adds it" for `pipefail`
  — accurate, but a date-bound claim. Acceptable as a passing note.

## Code-gap recommendations

Two small ENRICH additions:

1. **§23.5 Bash vs zsh** — 6-line block showing word-split divergence:
   bash splits unquoted `$var`, zsh does not (without
   `SH_WORD_SPLIT`).
2. **§23.12 Targeting multiple Bash versions** — `BASH_VERSINFO`
   gate, an example of nameref guard, and an explicit "die if too old"
   header pattern.

#fin
