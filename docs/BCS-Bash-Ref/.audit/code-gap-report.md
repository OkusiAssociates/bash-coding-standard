<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Code-Block Coverage Report — BCS Advanced Bash Reference

Date: 2026-05-03

## Headline

**28 of 351 leaves (8 %) contain at least one fenced code block**.

For a Bash *reference*, this is the audit's most actionable structural
defect. Eighteen Parts contain **zero** code in any leaf — including
Parts III–IX, the language-proper section that most needs worked
examples to function as a reference.

Phase-1 evidence flagged 53 % coverage in Part XXII (Idioms) and 8 %
corpus-wide. Audit confirms: 50 % in XXII (9 of 18) and 8 %
corpus-wide.

## Per-Part heatmap

| Part | With code | Total | Coverage | Verdict |
|------|----------:|------:|---------:|---------|
| I — Unix Model | 0 | 10 | 0 % | Needs examples |
| II — Bash as Program | 0 | 9 | 0 % | Needs examples (esp. invocation matrix) |
| III — Lexical | 0 | 12 | 0 % | Needs examples |
| IV — Parameters & Arrays | 0 | 15 | 0 % | **Critical** — BCS-central type system absent |
| V — Expansions | 0 | 14 | 0 % | **Critical** — IFS, glob, command sub absent |
| VI — Redirection | 0 | 17 | 0 % | **Critical** — heredoc / FD discipline absent |
| VII — Control Flow | 0 | 15 | 0 % | **Critical** — case fall-through, while-read absent |
| VIII — Conditionals | 0 | 15 | 0 % | **Critical** — `=~` / pattern absent |
| IX — Functions | 0 | 13 | 0 % | **Critical** — local / nameref / scope absent |
| X — Sourcing | 3 | 12 | 25 % | OK; needs source-semantics example |
| XI — Process Mgmt | 0 | 14 | 0 % | **Critical** — pgid / wait absent |
| XII — Signals | 4 | 17 | 24 % | Needs trap-builtin example |
| XIII — Errors | 2 | 13 | 15 % | **Critical** — exemption matrix needs row examples |
| XIV — I/O | 0 | 13 | 0 % | **Critical** — logging dispatcher absent |
| XV — CLI | 2 | 12 | 17 % | Needs full getopts loop |
| XVI — Concurrency | 2 | 13 | 15 % | Needs flock subshell pattern |
| XVII — IPC | 1 | 10 | 10 % | Needs coproc demo |
| XVIII — Readline | 1 | 17 | 6 % | OK; cheat-sheet domain |
| XIX — Performance | 0 | 14 | 0 % | Acceptable: tradeoff-table domain |
| XX — Security | 2 | 15 | 13 % | **Critical** — vulnerable/fixed pairs absent |
| XXI — Test | 2 | 14 | 14 % | Needs full bats / CI YAML |
| XXII — Idioms | **9** | 18 | **50 %** | Reference-quality |
| XXIII — POSIX | 0 | 13 | 0 % | OK: cheat-sheet domain |
| XXIV — Internals | 0 | 11 | 0 % | OK: prose-and-table domain |
| XXV — 5.3+ | 0 | 6 | 0 % | OK: forward-looking commentary |
| Appendices | 0 | 18 | 0 % | OK: tables, no code needed |
| **Total** | **28** | **351** | **8 %** | — |

## Mandatory-code leaf list (highest priority)

For a "language reference", the leaves below **must** carry at least
one inline code block. Sourced from per-Part audit recommendations.
Order by reader-impact within priority band.

### P1 mandatory-code leaves (18)

| § | Title | Required examples |
|---|-------|------------------:|
| 13.3 | The errexit-exemption matrix | 5 (one per matrix row) |
| 13.2 | `set -e` errexit full semantics | 4 |
| 12.6 | Pseudo-signals EXIT/ERR/DEBUG/RETURN | 4 |
| 14.7 | Logging discipline | 3 |
| 14.9 | Coloured output and `TERM` detection | 3 |
| 13.5 | `set -o pipefail` | 3 |
| 13.4 | `set -u` nounset | 3 |
| 13.11 | Propagating exit codes | 3 |
| 12.5 | The `trap` builtin | 3 |
| 11.5 | Foreground vs background | 3 |
| 20.5 | Command-injection vectors | 3 (vulnerable/fixed pairs) |
| 13.9 | `errtrace` and trap inheritance | 2 |
| 12.8 | Trap inheritance | 2 |
| 12.10 | Sync vs async signal delivery | 2 |
| 12.11 | Signal-safe code | 2 |
| 14.1 | Standard streams discipline | 2 |
| 15.2 | `getopts` builtin | 2 |
| 15.11 | Auto-generating usage | 2 |
| 20.* | (8 more security leaves; see expansion-roadmap §1B) | 2 each |

### P2 mandatory-code leaves (≥30)

The language-proper Parts III–IX. See `expansion-roadmap.md` Sprint 2 —
each PROMOTE leaf there carries `required_examples` ≥ 1. Highest among
P2:

| § | Title | Required examples |
|---|-------|------------------:|
| 5.4 | Parameter and variable expansion | 4 |
| 4.5 | `declare` builtin and attributes | 3 |
| 4.9 | Indexed arrays | 3 |
| 4.10 | Associative arrays | 3 |
| 4.11 | Namerefs (`-n`) | 3 |
| 5.8 | Word-splitting and `IFS` | 3 |
| 6.8 | Heredocs | 3 |
| 6.10 | Process substitution as redirection | 3 |
| 6.12 | `exec` for FD manipulation | 3 |
| 7.3 | `case…esac` | 3 |
| 8.6 | Regex matching with `[[ … =~ … ]]` | 3 |
| 9.3 | `local` and scope | 3 |
| 9.5 | Communicating results | 3 |

## Code-block style guidance (for downstream prose pass)

A future authoring pass should follow these conventions, derived from
Part XXII's high-coverage chapters:

1. **Strict-mode preamble** — every code example carries
   `set -euo pipefail` (or assumes a containing script does).
2. **`bash` fence label** — `\`\`\`bash` not `\`\`\`sh`. RAG retrievers
   index by language tag; consistency matters.
3. **Annotated, not bare** — each example has a leading comment line
   explaining the scenario.
4. **Show the output** when behaviour is non-obvious (use `# ⇒ output`
   trailing comments, or a separate fenced block labelled `output`).
5. **Side-by-side WRONG / RIGHT** for footgun examples — readers retain
   the contrast better than a single "good" example.
6. **Length cap** — body-leaf examples ≤ 25 lines; full templates go to
   `examples/templates/` with a one-line link from the leaf.

## Out-of-scope

This report does **not**:
- Author the code blocks (that is downstream prose work).
- Validate that existing 28 code blocks are syntactically correct
  bash 5.2 (recommend `shellcheck` pass on extracted blocks during
  Sprint 4 ENRICH).
- Cross-check that example fence labels are consistently `bash` vs
  `sh` (recommend simple grep during Sprint 0 critical-fix pass).

#fin
