<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Code-block inventory — 2026-05-04 refresh

**Source of truth:** `findings/inventory.tsv` (700 rows incl. header).
**Predecessor:** `code-gap-report.md` (2026-05-03 — pre-authoring snapshot).
**Tooling:** `tools/extract-blocks.bash` v1.0.0, `tools/lint-blocks.bash`, `tools/run-blocks.bash`.

## Headline numbers

| Metric | Count |
|--------|------:|
| Total fenced code blocks | **699** |
| `bash`-tagged blocks (lint+run) | 659 |
| Other-tagged or untagged (skipped) | 40 |
| Blocks with `# ⇒` output annotation | 287 |
| Leaves containing at least one block | 259 (of 351) |

The original 2026-05-03 audit reported 8 % code coverage; the
post-authoring tree at this refresh point holds 699 blocks, ~94 %
`bash`-tagged. The expansion roadmap was largely executed in the
intervening session.

## Language distribution

```
bash      659    (94.3 %)
NONE       19    (untagged — ASCII diagrams)
text        9    (output-only samples)
yaml        6
ini         2
json        1
bnf         1
c           1
sudoers     1
```

`NONE`-tagged blocks are diagrams or output captures, **not** shell code.
The lint and runtime pipelines correctly skip everything that is not
`bash`-tagged.

## Label class

| Class | Count | Meaning |
|-------|------:|---------|
| `NEUTRAL` | 625 | No explicit `# wrong` / `# right` markers |
| `MIXED` | 44 | Paired wrong+right side-by-side in one block |
| `WRONG` | 15 | Pure footgun demo — lint + runtime errors are *expected* |
| `RIGHT` | 15 | Pure correct demo |

## Runnability classification (`bash` only)

| Class | Count | Pipeline |
|-------|------:|----------|
| `RUNNABLE` | 516 | lint + run |
| `DESTRUCTIVE` | 62 | lint only (rm/sudo/chmod/kill outside `/tmp`) |
| `NEEDS_INPUT` | 44 | lint only (bare `read`) |
| `NETWORK` | 14 | lint only (curl/wget/ssh/…) |
| `ANTIPATTERN` | 15 | lint only (WRONG-labelled) |
| `INTERACTIVE` | 8 | lint only (read -p / select / tput) |
| `FRAGMENT` | 40 | skipped (non-bash language) |

## Per-Part coverage

Columns: leaves-with-blocks · blocks · bash-blocks · RUNNABLE · annotated.

| Part | Leaves | Blocks | Bash | RUNNABLE | Annotated |
|------|-------:|-------:|-----:|---------:|----------:|
| 01_The-Unix-Model-from-Bash | 9 | 24 | 21 | 16 | 15 |
| 02_Bash-as-a-Program | 7 | 15 | 14 | 11 | 8 |
| 03_Lexical-Structure-and-Shell-Grammar | 10 | 31 | 28 | 27 | 15 |
| 04_Parameters-Variables-and-Arrays | 14 | 53 | 52 | 51 | 44 |
| 05_Expansions | 13 | 51 | 51 | 42 | 32 |
| 06_Redirection-and-Pipelines | 16 | 38 | 38 | 27 | 25 |
| 07_Control-Flow-and-Compound-Commands | 14 | 51 | 42 | 30 | 18 |
| 08_Conditional-Expressions-and-Arithmetic | 11 | 17 | 17 | 16 | 15 |
| 09_Functions | 11 | 27 | 26 | 25 | 19 |
| 10_Sourcing-Libraries-and-Modules | 11 | 21 | 20 | 19 | 9 |
| 11_Process-Management | 12 | 34 | 32 | 22 | 14 |
| 12_Signals-and-Traps | 15 | 38 | 38 | 26 | 13 |
| 13_Error-Handling-and-Exit-Status | 12 | 41 | 41 | 39 | 22 |
| 14_Input-Output-and-Messaging | 11 | 30 | 30 | 22 | 10 |
| 15_Command-Line-Processing | 10 | 27 | 25 | 23 | 0 |
| 16_Concurrency-and-Parallelism | 12 | 38 | 36 | 22 | 11 |
| 17_Coprocesses-and-IPC | 7 | 20 | 20 | 5 | 9 |
| 18_Readline-History-and-Completion | 6 | 6 | 5 | 1 | 0 |
| 19_Performance | 8 | 11 | 10 | 9 | 5 |
| 20_Security | 14 | 57 | 54 | 35 | 28 |
| 21_Static-Analysis-Formatting-and-Testing | 12 | 24 | 16 | 10 | 3 |
| 22_Idioms-Patterns-and-Anti-Patterns | 16 | 27 | 26 | 22 | 6 |
| 23_POSIX-Conformance-and-Portability | 3 | 8 | 8 | 8 | 3 |
| 24_Bash-Internals | 3 | 7 | 6 | 5 | 1 |
| 25_Bash-5.3-and-the-Future | 1 | 2 | 2 | 2 | 2 |
| 99_Appendices | 1 | 1 | 1 | 1 | 0 |

## Lint findings (Phase 2 input)

`findings/shellcheck.tsv` holds **543** shellcheck findings across
~590 bash blocks (the 16/15/40 ANTIPATTERN/DESTRUCTIVE/FRAGMENT-other
combos are excluded by classification). The dominant non-trivial codes
are listed below; numbers in parentheses are raw counts before triage.

| Code | Count | Triage hint |
|------|------:|-------------|
| SC2034 | 152 | Mostly pedagogical (declared to demonstrate); confirm during triage |
| SC1128 | 110 | Shebang-on-line-1 violations from `# scenario:` comments above shebang — consider a convention call: drop scenario-comments above shebangs OR keep and accept SC1128 fleet-wide |
| SC2154 | 101 | Variable referenced not assigned — fragments deliberately use vars defined elsewhere in the leaf prose |
| SC1072 / SC1073 | 32 | Real parser errors — most are intentional grammar samples in §3 / §15; flag for inline `#shellcheck disable=` |
| SC1083 | 18 | Literal `{ ... }` in word context — usually inside diagram-style braces |
| SC2046 | 17 | Unquoted `$(…)` — likely real bugs; flag FIX |
| SC2120 | 14 | Function passed args it does not declare — likely real |
| SC1056 | 9 | Code-fence parser confusion — investigate per-leaf |
| SC2288 | 8 | `$(…)` inside `[…]` — likely real |
| SC1090 | 8 | Non-constant source — convention is to suppress with directive |

## Runtime findings (Phase 3 input)

`findings/runtime.tsv` holds 516 RUNNABLE-block executions:

| Bucket | Count | Meaning |
|--------|------:|---------|
| `OK` | 51 | Block ran, every `# ⇒` annotation matched |
| `MISMATCH` | 112 | Block ran, but at least one annotation did not appear in stdout |
| `CRASH` | 221 | Non-zero exit. Most are sandbox-sandboxing artefacts (no `die`/`info` helpers) — triage required |
| `NO_EXPECTED` | 107 | Block ran, no annotations to compare |
| `MISSING_ANNOT` | 21 | Block produced stdout but had no `# ⇒` annotations — opportunity to add one |
| `TIMEOUT` | 4 | Killed at 10 s — block has a sleep / loop that exceeds the budget |

CRASH dominates because the runner runs each block under `env -i` with
no project helper functions in scope. Phase 4 triage will separate
"sandbox can't reach `info`/`die`/`bcscheck`" CRASHes from real bugs.

## Phase-2/3 hottest leaves

Leaves with ≥ 5 lint findings AND ≥ 1 CRASH that is not obviously a
sandbox artefact merit early triage. Top of the list — generated from
`shellcheck.tsv` and `runtime.tsv` — should be examined first in
Phase 4. (Specific leaf list is rebuilt at triage time; not pinned
here.)

## Annotation gap

15 leaves in §15 (Command-Line-Processing) have **0** annotated blocks.
§18 Readline likewise. §21 Static-Analysis has 16 bash blocks but only 3
with `# ⇒`. These are obvious targets for Phase 6 enrichment.

## Reproducing the inventory

```bash
cd docs/BCS-Bash-Ref
.audit/tools/extract-blocks.bash -H -q   > .audit/findings/inventory.tsv
.audit/tools/extract-blocks-to-files.bash -c -q   # rebuild blocks/
.audit/tools/lint-blocks.bash -q                  # rebuild shellcheck.tsv
.audit/tools/run-blocks.bash -q                   # rebuild runtime.tsv (+ logs)
```

The 2026-05-03 historical report (`code-gap-report.md`) is preserved
in place as a baseline snapshot and is **not** to be edited.

#fin
