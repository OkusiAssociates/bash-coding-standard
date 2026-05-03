<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Self-Containment Issues — BCS Advanced Bash Reference

Date: 2026-05-03
Source: preflight external-ref inventory + per-Part audit findings.

## Why this report exists

The corpus reads as a *node in a constellation* of three documents:

1. **BCS Coding Standard** (`data/BASH-CODING-STANDARD.md`) — sibling
   document inside this repo.
2. **BCS-bash** (`docs/BCS-bash/`) — strict-mode-rewritten bash man page,
   sibling.
3. **External web references** — Greg Wooledge wiki, GNU bash manual,
   shellcheck wiki, bash-hackers wiki, savannah git, bug-bash list.

For an engineer browsing the assembled `BCS-ADVANCED-BASH-REFERENCE.md`
on disk, the constellation resolves: all three are co-installed alongside
this document. **For an AI/RAG retriever, the constellation breaks**:
chunks return in isolation, and a leaf that says "see BCS§4.5 for the
local-declare rule" has just told the retriever there exists a resolver
*outside the chunk* that the retriever cannot follow.

The audit does **not** prescribe a resolution policy. The user must
choose one of three architectures:

| Policy | Trade-off |
|--------|-----------|
| **Inline** — quote the BCS rule / BCS-bash paragraph inside this corpus | Self-contained but duplicates content; drift risk |
| **Footnote** — paraphrase + cite source | Compromise; leaves a small resolver gap |
| **Link-out** — keep current pointer-only style | Smallest corpus but RAG-hostile |

## Inventory

### External web links (12 occurrences, 10 unique URLs)

Most live in **Appendix Q — Further Reading**, which is editorially
correct: a "Further reading" appendix *should* be link-out.

| File | Line | URL | Status |
|------|-----:|-----|--------|
| `24/10_Reading-the-bash-source.md` | 6 | `https://git.savannah.gnu.org/cgit/bash.git/` | resolves |
| `25/04_Roadmap-signals.md` | 11 | `https://lists.gnu.org/archive/html/bug-bash/` | resolves |
| `99/Q_Further-Reading.md` | 6 | `https://www.gnu.org/software/bash/manual/` | resolves |
| `99/Q_Further-Reading.md` | 8 | `https://mywiki.wooledge.org/` | resolves |
| `99/Q_Further-Reading.md` | 9 | `https://www.shellcheck.net/wiki/` | resolves |
| `99/Q_Further-Reading.md` | 10 | `https://wiki.bash-hackers.org/` | resolves |
| `99/Q_Further-Reading.md` | 11 | `https://github.com/scop/bash-completion` | resolves |
| `99/Q_Further-Reading.md` | 12 | `https://bats-core.readthedocs.io/` | resolves |
| `99/Q_Further-Reading.md` | 13 | `https://www.gnu.org/software/coreutils/manual/` | resolves |
| `99/Q_Further-Reading.md` | 14 | `https://pubs.opengroup.org/onlinepubs/9699919799/` | resolves |
| `99/Q_Further-Reading.md` | 15 | `https://git.savannah.gnu.org/cgit/bash.git/` | resolves (dup) |
| `99/Q_Further-Reading.md` | 16 | `https://lists.gnu.org/archive/html/bug-bash/` | resolves (dup) |

**Recommendation**: keep external links link-out (Q is intentionally
that). The two body-chapter URLs (§24.10, §25.4) are also low-impact
links to authoritative source, but consider a footnote-style citation
so the retriever has the key claim self-contained.

### BCS rule references (0 occurrences)

The corpus does **not** currently inline any `BCS\d{4}` rule code. Body
prose uses structural language ("BCS hook for `local --` rule") without
the rule code.

**Recommendation**: during the PROMOTE pass, **add inline rule-code
citations** at every BCS hook point. Pattern:

```
The local-declare rule (BCS0203) requires `local --` rather than bare `local`.
```

This makes the rule code surface in chunk retrieval and gives the AI
retriever an anchor to fetch the standard's text via separate retrieval.

### BCS-bash references (4 occurrences)

All four resolve correctly in the file-system layout. They are forward
pointers from the reference into the rewritten man-page sibling.

**Recommendation**: keep link-out. The two documents are companion
projects; full inlining would duplicate ~6,000 lines.

### `§N.M(.K)` cross-references (124 occurrences, 96 unique)

Internal corpus references. **All resolve.** Preflight verified
filename-and-anchor correspondence.

| Strength | Count | Recommendation |
|----------|------:|----------------|
| Resolved | 124 | Keep |
| Dangling | 0 | — |
| Reciprocal pairs | low | Add reciprocal back-references during ENRICH pass (see REVIEW finding 22) |

### Implicit external dependencies (qualitative)

These are not explicit URLs but **knowledge dependencies** that a RAG
retriever cannot supply. Audited by per-Part agents and listed by
agent-shard in the per-Part files.

| Dependency | Where most acute | Resolution recommendation |
|------------|------------------|----------------------------|
| BCS canonical strict-mode contract (`set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob`) | §13.9, §10.1, §11.*, §20.* | **Inline** the contract sentence in §13.9 and reference it back from §10/§11/§20 |
| BCS exit-code table (Appendix L) | §1.7, §13.10, §15.* | **Inline** a 6-row excerpt at §13.10 (codes 0/1/2/22/13/126/127); link to Appendix L for the full set |
| BCS template structure (`bcs template -t complete`) | §22.3, §15.11 | **Inline** the canonical hand-rolled parser in §22.3 (already a PROMOTE candidate) |
| `bash(1)` man-page semantics (e.g. `set -e` exemption matrix) | §13.2, §13.3 | **Inline** the matrix in §13.3 (already a PROMOTE candidate, target 200 lines / 5 examples) |
| Greg Wooledge wiki idioms | §5.8 (IFS), §10.* (sourcing), §16.9 (races) | **Inline** the Greg-canonical example with attribution; do not just link |
| ShellCheck rule codes (`SC2086` etc.) | §21.* | **Inline** the most-referenced 8 rule numbers in §21.2 with one-line meaning |

## Policy decisions (locked-in 2026-05-03)

User accepted the audit's recommended policy on all three open
questions. The decisions below are now binding inputs to the
downstream prose-authoring sprints.

### Decision 1 — Inline the 6 BCS canonical-content items

Inline the six items listed in the "Implicit external dependencies"
table above; keep all other BCS / BCS-bash references link-out.
Adds ~400 lines to the corpus.

| Item | Owner leaf | Sprint |
|------|------------|--------|
| BCS strict-mode contract sentence | §13.9 | 1A |
| BCS exit-code 6-row excerpt | §13.10 (or §13.11) | 1A |
| Canonical hand-rolled parser | §22.3 | 1F |
| `set -e` exemption matrix | §13.3 | 1A |
| Greg-canonical IFS / sourcing / race idioms | §5.8 / §10.1 / §16.9 | 1B/2A/2H |
| Top-8 ShellCheck rule codes | §21.2 | 4 (ENRICH) |

All six already appear in `expansion-roadmap.md` as PROMOTE or ENRICH
entries; this decision elevates the inline-vs-link-out choice from
"author judgement" to "binding requirement" for those leaves.

### Decision 2 — BCS rule-code inline citation, every hook

At every BCS hook in the corpus, cite the rule code inline:

```
The local-declare rule (BCS0203) requires `local --` rather than bare `local`.
```

Affects ~50 PROMOTE leaves and a similar number of ENRICH leaves;
~70–100 inline citations corpus-wide. Sprint-1 PROMOTE work and
Sprint-4 ENRICH work both author under this rule.

Validation requirement: every cited `BCS\d{4}` code must be verified
against `data/BASH-CODING-STANDARD.md` at author-time. Add a
`grep -F` check to the Sprint-5 re-audit harness.

### Decision 3 — §22 Idioms absorbs its deferral-stubs

§22.3 (argument-parsing skeleton) and §22.15 (stack-trace error
reporter) inline the canonical idiom; back-reference §15.* / §13.*
for full reference. Both are already PROMOTE in `dispositions.tsv`
with target 200 / 150 lines respectively. The audit's other three
deferral-stubs (§22.10, §22.11, §22.13) are re-classified from
ENRICH to PROMOTE under this decision — see roadmap update below.

### Decision 4 — External URLs

Appendix Q stays link-out (editorially correct for "Further
reading"). The §24.10 (savannah git) and §25.4 (bug-bash list)
body-chapter URLs become footnoted citations: paraphrase the key
claim inline, attribute the source as a footnote-style link. Done
during Sprint 4 ENRICH.

## What the audit did NOT do

- Did **not** fetch any external URL.
- Did **not** validate that BCS rule codes mentioned in `dispositions.tsv`
  notes actually exist in `data/BASH-CODING-STANDARD.md`. Validation
  recommended during Sprint 1 critical-fix pass.
- Did **not** modify any source file to inline content. All resolution
  decisions are user-facing.

#fin
