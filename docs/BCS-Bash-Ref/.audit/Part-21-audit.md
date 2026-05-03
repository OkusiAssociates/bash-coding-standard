<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXI Audit — Static Analysis, Formatting, and Testing

Date: 2026-05-03
Priority band: **P2**
Leaves audited: 14 (13 chapters + index)

## Summary

Part 21 documents a tooling stack — ShellCheck, shfmt, bcscheck, pre-commit,
CI, bats-core, shunit2, kcov. As a corpus of *recipes* it is the Part where
absent code blocks hurt most: bullets describe a tool exists, but a reader
cannot copy a `.pre-commit-config.yaml` or a GitHub Actions YAML out of
prose. Code-block coverage is one of the lowest in the shard (~7 % of
leaves carry a runnable example — only `11_Mocking-via-PATH-injection.md`
ships meaningful code).

KEEP / ENRICH / PROMOTE = **3 / 7 / 4**.

## Top 5 findings

1. `[major]` `08_bats-core.md`, `10_Bats-run-and-assertions.md` — these
   chapters introduce the test framework and its assertion vocabulary
   without showing one complete `.bats` file. A new reader cannot bootstrap
   a test suite from the briefing.
2. `[major]` `06_Pre-commit-hooks.md`, `07_CI-integration.md` — both are
   recipe chapters whose payload is a YAML file. Bullet enumeration of
   stanzas is no substitute; CI integration in particular needs at least
   one runnable workflow.
3. `[minor]` `11_Mocking-via-PATH-injection.md` is the strongest leaf in
   the Part — complete pattern, working example, prose tied to bats
   `setup`/`teardown`. KEEP.
4. `[minor]` `12_shunit2.md` correctly minimal — shunit2 is a deferred
   secondary framework. The brevity is editorial and warranted.
5. `[fixable]` `02_ShellCheck-directives.md` shows `local --` in an example
   without a function context; the snippet works in isolation but is
   slightly misleading as a directive demo. Consider a function-local
   wrapper or a top-level array assignment.

## Per-leaf table

| Leaf | Disp | Tgt | Ex | Notes |
|------|------|-----|----|-------|
| 01_ShellCheck-warnings | ENRICH | 90 | 1 | needs JSON output sample and CI gate snippet |
| 02_ShellCheck-directives | ENRICH | 60 | 1 | add multi-code disable + file-level shell=bash |
| 03_Source-path-management | ENRICH | 70 | 1 | add SCRIPTDIR sourcing example |
| 04_shfmt | ENRICH | 70 | 1 | add flags snippet and pre-commit hook |
| 05_bcscheck | ENRICH | 90 | 1 | add `-j` invocation + `#bcscheck disable=` |
| 06_Pre-commit-hooks | PROMOTE | 120 | 2 | needs full `.pre-commit-config.yaml` |
| 07_CI-integration | PROMOTE | 160 | 2 | needs Actions YAML and GitLab CI snippet |
| 08_bats-core | PROMOTE | 140 | 2 | needs complete `.bats` file |
| 09_Bats-setup-and-teardown | ENRICH | 90 | 1 | worked setup_file vs setup demo |
| 10_Bats-run-and-assertions | PROMOTE | 130 | 2 | needs run/$status/$output + bats-assert |
| 11_Mocking-via-PATH-injection | KEEP | 28 | 1 | exemplary; complete mock pattern |
| 12_shunit2 | KEEP | 12 | 0 | deferred secondary framework; correctly terse |
| 13_Coverage-with-kcov | ENRICH | 70 | 1 | add `kcov bats` invocation + threshold gate |
| index | KEEP | 30 | 0 | complete chapter index |

## Cross-reference issues

- §21.5 `bcscheck` should xref `BCS Section 13` (env config) for
  `bcs.conf` cascading lookup; presently silent.
- §21.11 cites §21.11 self-reference internally — fine but the link to
  §21.8 bats-core `setup`/`teardown` is implicit; explicit `(see §21.9)`
  would help.
- The whole Part should xref Appendix L (exit codes) for assertion-style
  status patterns; presently not linked.

## Self-containment risks

- `bcscheck` chapter assumes the reader has installed BCS — fine for the
  BCS corpus, but a RAG reader surfacing this leaf without context will
  miss the prerequisite. A one-line "see BCS install instructions" link
  is enough.
- The pre-commit and CI chapters implicitly assume Python `pre-commit`
  and a GitHub Actions account; the YAML format is not introduced.
  PROMOTE-time prose should briefly establish those prerequisites.

## Code-gap recommendations

Five chapters carry the highest priority for code addition:

1. `06_Pre-commit-hooks.md` — full `.pre-commit-config.yaml`.
2. `07_CI-integration.md` — GitHub Actions workflow YAML.
3. `08_bats-core.md` — minimal but complete `.bats` file.
4. `10_Bats-run-and-assertions.md` — `run` + `assert_*` worked example.
5. `13_Coverage-with-kcov.md` — `kcov OUTPUT_DIR bats tests/` invocation
   plus a threshold-gate one-liner.

These five additions would lift Part 21's code coverage from one chapter
to six and convert it from a tool index into a usable testing handbook.

#fin
