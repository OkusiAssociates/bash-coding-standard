<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# BCS-Bash-Ref Audit (.audit/)

Date: 2026-05-03

## Purpose

Audit the 351-file `BCS-Bash-Ref/` source tree (assembled into
`docs/BCS-ADVANCED-BASH-REFERENCE.md` by `generate.bash`) for
prose-readiness. Each leaf file is currently a skeleton:

```
SPDX header
## N.M Heading
1-line description
- bullet topic
- bullet topic
- bullet topic
#fin
```

Mean ~17 lines/file. The skeleton form is **inadequate as a deliverable
reference**. This audit assigns each leaf a disposition and produces a
roadmap for downstream prose-authoring.

## Scope

- 25 Parts (`[012][0-9]_*/`) — each with an `index.md` plus N chapter files.
- 1 Appendices Part (`99_Appendices/`) — 17 lettered files (A–Q) plus an
  index.
- 1 top-level `index.md`.

Total: 351 markdown files.

## Out of scope

- Writing the actual prose for PROMOTE leaves — that is the multi-week
  downstream project this audit *plans for*.
- Edits to `docs/BCS-bash/` (sibling project — strict-mode man-page rewrite).
- Re-architecting the tree or `generate.bash`.
- Ingesting BCS / BCS-bash content into BCS-Bash-Ref leaves to "solve"
  self-containment — that is an architectural decision the user must take
  on the basis of `self-containment-issues.md`.

## Audit conventions

The leading dot on `.audit/` keeps it outside `generate.bash`'s
`[012][0-9]_*/` glob, so the assembled artefact is unaffected. Do not
add `.md` files at the top of `.audit/` whose names start with `[A-Z]`
inside `99_Appendices/` — those globs are also live.

`baseline-assembled.md` is a snapshot of `BCS-ADVANCED-BASH-REFERENCE.md`
taken at audit start. Drift checks `diff` against this baseline.

## Rubric

Each leaf scored on seven dimensions:

| Dimension | Scale | Definition |
|-----------|-------|------------|
| Coverage completeness | high / med / low | Sub-topic enumeration vs needed surface area for that section |
| Briefing clarity (human) | high / med / low | Engineer skim test — would a working bash author understand the intended scope? |
| Briefing clarity (AI/RAG) | high / med / low | Self-contained? Concrete? Resolvable without external knowledge? |
| Cross-reference density | high / med / low | Forward / back links to adjacent §N.M.K, BCS, BCS-bash, Greg Wooledge present where needed? |
| Strict-mode framing | high / med / low | Strict-mode interaction stated where relevant? |
| Example presence | yes / no / n-a | Code block present where a reference needs one? `n-a` for pure cheatsheets |
| Self-containment | yes / no | Comprehensible without external resolver? |

## Disposition rules (deterministic)

| Disposition | Trigger |
|-------------|---------|
| **KEEP** | All dimensions ≥ medium; appendix tables and tight cheatsheets that don't need prose |
| **ENRICH** | One or two dimensions low; fix is bullet additions, tighter cross-refs, or a single inline mini-example |
| **PROMOTE** | Three+ low scores OR coverage-completeness=low OR a chapter in a code-free Part needing examples |

Expected envelope: ~10–15% KEEP, ~40–50% ENRICH, ~35–50% PROMOTE.

## Priority bands

| Band | Parts |
|------|-------|
| **P1** (foundational, must-have) | XII (Signals), XIII (Errors), XIV (I/O), XV (CLI), XX (Security), XXII (Idioms), all Appendices |
| **P2** (high-value) | III–IX (language proper) |
| **P3** (specialist) | XVII (IPC), XVIII (Readline), XIX (Perf), XXIV (Internals), XXV (5.3+) |

## Severity scale (for findings outside the rubric)

| Tag | Meaning |
|-----|---------|
| `[critical]` | Wrong, broken, or contradicts BCS / BCS-bash |
| `[major]` | Substantive content gap with reader impact |
| `[minor]` | Nit / polish / wording |
| `[fixable]` | Mechanical, auto-fix candidate |

## Auto-fix policy

The user has authorised mechanical auto-fixes. Permitted:

- Broken / dangling `§N.M.K` cross-refs (target file or anchor missing).
- Wrong section-number / filename mismatch.
- Obvious typos in headings (vs Part `index.md` TOC).
- Missing `#fin` lines.
- Trailing-whitespace / blank-line drift.

All fixes recorded to `auto-fix-log.md` with before/after.

NOT auto-fixable: substantive content judgement, prose authoring, rubric
dimension up-grading. Those flag for user review.

## Output files

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `dispositions.tsv` | Machine-readable per-leaf disposition |
| `Part-NN-audit.md` | Per-Part audit (25 + 1 appendices) |
| `auto-fix-log.md` | Record of mechanical edits |
| `REVIEW-2026-05-03.md` | Top-level summary |
| `expansion-roadmap.md` | Ordered prose-authoring plan |
| `self-containment-issues.md` | External-ref resolution status |
| `code-gap-report.md` | Code-block coverage analysis |
| `baseline-assembled.md` | Snapshot for drift diff |

## dispositions.tsv schema

Tab-separated, no header repetition; columns:

```
path  disposition  target_lines  required_examples  priority  notes
```

- `path` — relative to repo root, e.g. `docs/BCS-Bash-Ref/04_Parameters-Variables-and-Arrays/09_Indexed-arrays.md`
- `disposition` — `KEEP` | `ENRICH` | `PROMOTE`
- `target_lines` — integer; current value if KEEP, target if ENRICH/PROMOTE (typical PROMOTE: 100–250)
- `required_examples` — integer 0–5; mandatory code-block count after expansion
- `priority` — `P1` | `P2` | `P3`
- `notes` — short pipe-free phrase capturing the most important rubric finding

#fin
