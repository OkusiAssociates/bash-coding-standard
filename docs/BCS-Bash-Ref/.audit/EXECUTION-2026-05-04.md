<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Execution Log — Phases 9-13 (residual triage)

**Date:** 2026-05-04
**Scope:** drive the REVIEW pile from 211 → 0 by enriching the audit
sandbox, expanding triage classification, generating per-Part triage
reports, and applying targeted edits across every Part with residuals.

## Phase summary

| Phase | Goal | Result |
|-------|------|--------|
| 9 | Sandbox helper-stub library so blocks calling `die`/`info`/`success`/`warn`/`error`/`noarg`/`vecho`/`yn` don't crash under `env -i`. | `lib/bcs-helpers-stub.sh` written; `run-blocks.bash` sources it; pre-creates `/tmp/sandbox/{lib,bin}`. |
| 10 | stderr-aware triage rules so sandbox artefacts are auto-classified instead of swelling the REVIEW pile. | `triage.bash` extended with: `SANDBOX_TOOL`, `SANDBOX_FLEET`, `SANDBOX_PERM`, `SANDBOX_FS`, `SANDBOX_HOME`, `SANDBOX_NONDETERMINISTIC`, `ILLUSTRATIVE_FRAGMENT`, `EXPECTED_TIMEOUT`; `EXPECTED_CRASH` expanded for SIGPIPE / annotation-described / scenario-marked failures. New `-L/--log-dir` option. |
| 11 | Per-Part triage report generator. | `triage-report.bash` written; emits one `Part-NN-triage.md` per Part with stdout/stderr excerpts and a decision stub per entry. |
| 12 | Manual review pass per Part — apply `FIX_BLOCK` / `FIX_ANNOTATION` / `ACCEPT_SANDBOX` / `ACCEPT_PROSE` decisions to every REVIEW entry. | All 211 REVIEW entries cleared. Per-Part atomic commits limit blast radius. Decisions logged in `.audit/auto-fix-log.md`. |
| 13 | Re-assemble single-file artefact + HTML mirror; write this execution log. | `generate.bash` clean (parts 25 / chapters 307 / appendices 17). HTML build clean (353 files). |

## Matcher hardening

`run-blocks.bash` `extract_expected()` was tightened in three steps as
the corpus exposed edge cases:

1. **Em-dash convention** — strip trailing ` — explanatory prose` after
   any literal value (`# ⇒ 5    — string length in characters` →
   expected = `5`).
2. **Anchor `# ⇒` to ≤1 space** — deeply-indented column-trace prose
   (`#                  ⇒ both streams land in out.log`) is no longer
   misread as expected output.
3. **Interleave parens-strip and em-dash strip** — handles
   `value (a) — prose` (em-dash exposes a paren) and
   `value — (no split — IFS no longer contains space)` (em-dash
   inside paren). Loop bound at 16 iterations to avoid pathology.

## Triage classification expansion

`triage.bash` `classify_lint()` now has explicit cases for the BCS-Bash
corpus's recurring lint codes — SC2088, SC2080, SC2050, SC2125,
SC2194, SC2206, SC2128, SC2053, SC2066, SC2064, SC2069/75/76,
SC2104/2152/2188/2207/2216/2220/2254/2259/2261, plus the parser-
confusion sweep SC1010/1020/1035/1054/1055/1056/1072/1073/1083/1087/
1133/1141. SC2242 was promoted from REVIEW to ADD_SUPPRESSION
(out-of-range exit codes are pedagogical in §13).

## Bucket-distribution delta (runtime)

| Bucket | Before phase 9 | After phase 13 |
|--------|---------------:|---------------:|
| OK | 64 | 150 |
| MISMATCH | 97 | 13 |
| CRASH | 211 | 198 |
| NO_EXPECTED | 106 | 111 |
| MISSING_ANNOT | 14 | 17 |
| TIMEOUT | 4 | 2 |

The CRASH count is essentially unchanged in absolute terms but is now
fully classified — every crash is attributed to a sandbox artefact
(`SANDBOX_TOOL`/`FLEET`/`PERM`/`FS`/`ARTEFACT`), an illustrative
fragment under `set -u`, an expected failure (anti-pattern,
SIGPIPE, annotation-described), or an expected timeout. None remain
in REVIEW.

## REVIEW-pile delta

| Source | Before phase 9 | Mid (after phases 9-11) | After phase 12 | After phase 13 |
|--------|---------------:|------------------------:|---------------:|---------------:|
| lint  | 116 | 106 | 0 | 0 |
| runtime | ~250 | 95 | 0 | 0 |
| **Total** | **~370** | **211** | **0** | **0** |

## Per-Part fix counts (Phase 12)

| Part | REVIEW entries cleared | Notes |
|------|----------------------:|-------|
| 13 (Error-Handling) | 13 | Highest priority per plan |
| 20 (Security) | 3 | Second priority |
| 04 (Parameters) | 18 | Largest single Part |
| 03 (Lexical) | 5 | Comment / quote demos |
| 06 (Redirection) | 8 | Trace-prose `⇒` cleanup |
| 07 (Control Flow) | 7 | `cmd_that_exits_1` / process placeholders |
| 09 (Functions) | 8 | local-attribute demo, nameref collision, fac_bad |
| 11 (Process Mgmt) | 4 | PID/PGID non-determinism |
| 12 (Signals/Traps) | 5 | trap-disposition annotations |
| 14 (I/O) | 5 | tab-separated outputs, locking |
| 02 (Bash-as-program) | 3 | `bash -s --` invocation, /var/log fixture |
| 05 (Expansions) | 4 | base prefixes, glob fixtures, locale |
| 19 (Performance) | 3 | placeholder `cmd`, bash-5.3 syntax |
| 22 (Idioms) | 4 | jq -c compact JSON, lockfile path |
| 23 (POSIX) | 3 | zsh-only blocks → `text` fence |
| 01 (Unix model) | 2 | ps -p with `|| true`, exit annotation |
| 08 (Conditional) | 2 | corrected arithmetic, multi-paren strip |
| 16 (Concurrency) | 1 | mktemp prefix demo |
| 17 (Coprocesses) | 1 | tmpfs option string varies |
| 24 (Internals) | 1 | shell-prompt transcript → text fence |
| **Total** | **111** unique blocks (211 entries — multiple findings per block) | |

## Verification (plan checklist)

```bash
# Bucket distribution improvement
awk -F'\t' 'NR>1 {print $6}' docs/BCS-Bash-Ref/.audit/findings/runtime.tsv \
  | sort | uniq -c
# Result: OK=150 ≥ 130 ✓; MISMATCH=13 ≤ 50 ✓.

# Residual REVIEW count
awk -F'\t' 'NR>1 && $7=="REVIEW"' \
  docs/BCS-Bash-Ref/.audit/findings/dispositions-augmented.tsv | wc -l
# Result: 0 ≤ 30 ✓.

# Tools clean
shellcheck -x docs/BCS-Bash-Ref/.audit/tools/*.bash \
  docs/BCS-Bash-Ref/.audit/tools/lib/*.sh
# Result: clean ✓.

# Artefact regenerates
docs/BCS-Bash-Ref/generate.bash
# Result: parts 25 / chapters 307 / appendices 17 ✓.

# HTML re-renders
docs/BCS-Bash-Ref.html.build
# Result: 353 HTML files ✓.

# Commits properly authored
git log --format='%an <%ae>' fcd7147^..HEAD | sort -u
# Result: Biksu Okusi <biksu@okusi.id> ✓.
```

## Artefact / file inventory

| Path | Role | Phase |
|------|------|-------|
| `.audit/tools/lib/bcs-helpers-stub.sh` | new — BCS messaging helper shim | 9 |
| `.audit/tools/run-blocks.bash` | edited — load stub, harden matcher | 9, 12 |
| `.audit/tools/triage.bash` | edited — stderr-aware rules, lint sweep | 10, 12 |
| `.audit/tools/triage-report.bash` | new — per-Part report generator | 11 |
| `.audit/triage/Part-NN-triage.md` | new — 23 per-Part review files | 11 |
| `.audit/findings/inventory.tsv` | refreshed | 12, 13 |
| `.audit/findings/runtime.tsv` | refreshed | 12, 13 |
| `.audit/findings/shellcheck.tsv` | refreshed | 12 |
| `.audit/findings/dispositions-augmented.tsv` | refreshed | 12 |
| `.audit/auto-fix-log.md` | extended with phase-12 entries | 12 |
| `docs/BCS-ADVANCED-BASH-REFERENCE.md` | regenerated | 13 |
| `docs/BCS-Bash-Ref.html/` | re-rendered (353 files) | 13 |

#fin
