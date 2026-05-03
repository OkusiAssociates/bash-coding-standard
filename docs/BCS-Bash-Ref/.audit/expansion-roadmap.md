<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Expansion Roadmap — BCS Advanced Bash Reference

Date: 2026-05-03
Source: `dispositions.tsv` (350 audited leaves)
Target: ordered prose-authoring sequence for the 105 PROMOTE leaves and
the highest-leverage ENRICH leaves, with effort tags.

## Effort tags

| Tag | Target lines | Required examples | Typical author-time (focused) |
|-----|-------------:|------------------:|-------------------------------|
| **S** | ≤ 120 | 1 | 1–2 hours |
| **M** | 121–180 | 2 | 3–5 hours |
| **L** | 181–260 | 3+ | 6–10 hours |

Effort assumes a bash-fluent author with the relevant rubric finding in
hand. Multipliers if the author needs to develop the canonical example
from scratch (vs porting from BCS / examples/ / personal library).

---

## Policy inputs (locked-in 2026-05-03)

The user has adopted the recommended self-containment policy. Three
decisions bind every sprint below:

1. **Inline 6 BCS canonical-content items** at owner-leaves (see
   `self-containment-issues.md` § Decision 1). Authors inline rather
   than link out for: strict-mode contract (§13.9), exit-code excerpt
   (§13.10/§13.11), hand-rolled parser (§22.3), errexit exemption
   matrix (§13.3), Greg-canonical idioms (§5.8 / §10.1 / §16.9), top-8
   ShellCheck rule codes (§21.2).

2. **Cite BCS rule codes inline at every hook**, pattern
   `(BCS0203)`. Applies to ~70–100 inline citations across all PROMOTE
   and ENRICH leaves. Codes verified against
   `data/BASH-CODING-STANDARD.md` at author-time.

3. **§22 absorbs its deferral-stubs**: §22.3, §22.10, §22.11, §22.13,
   §22.15 inline the canonical idiom and back-reference §15 / §13 / §16
   for full detail. §22.10, §22.11, §22.13 are reclassified from ENRICH
   to PROMOTE (added to Sprint-1 wave 1F below).

## Sprint 0 — Critical fixes (1 day)

Mechanical-friendly corrections raised by the audit. None require prose
authoring; all are surgical.

| File | Action | Effort |
|------|--------|:------:|
| `02/08_Exit-and-shell-session-lifecycle.md` | Correct `set -E`/EXIT-trap inheritance claim | XS |
| `07/01_Compound-command-overview.md` | Reconcile "seven forms" claim with the ten enumerated | XS |
| `13/09_errtrace-and-trap-inheritance.md` | Reconcile strict-mode contract sentence with BCS canonical | XS |
| `16/05_Waiting-for-children.md` | Replace buggy `pids=("${pids[@]/$done_pid}")` with array-element-removal idiom | XS |
| `12/14_Lockfile-pattern.md` | `flock` is `util-linux` external, not a builtin | XS |
| `19/06_*` | Replace `bc -l` example with builtin-only computation | XS |
| `05/06_Command-substitution.md` | Re-label `$(<file)` from "pitfall" to "idiom" | XS |
| `05/13_Locale-and-pattern-matching.md` | Specify or remove "stricter UTF-8 handling in some areas" claim | XS |

---

## Sprint 1 — P1 PROMOTE drive (35 leaves, ~5,300 target lines)

Ordered by reader-impact within priority band. Each leaf has the
`§N.M` citation, target lines, required examples, and effort tag.

### Wave 1A — Error handling spine (9 leaves, ~1,440 lines)

The most-misunderstood feature in bash. Author **first**: nothing else in
the corpus resolves cleanly until §13.* is reference-grade.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 13.2 | `set -e` errexit full semantics | 220 | 4 | **L** |
| 13.3 | The errexit-exemption matrix | 200 | 5 | **L** |
| 13.5 | `set -o pipefail` | 160 | 3 | M |
| 13.4 | `set -u` nounset | 150 | 3 | M |
| 13.11 | Propagating exit codes | 160 | 3 | M |
| 13.6 | `inherit_errexit` | 140 | 2 | M |
| 13.9 | `errtrace` and trap inheritance | 130 | 2 | M |
| 12.6 | Pseudo-signals EXIT/ERR/DEBUG/RETURN | 200 | 4 | **L** |
| 12.8 | Trap inheritance | 160 | 2 | M |

Wave 1A unblocks every cross-reference of the form "see §13.* for errexit
behaviour" — those references are dense across Parts VI–XII.

### Wave 1B — Security spine (9 leaves, ~1,450 lines)

P1, immediate user-visible reader value. Lean on real CVE / Shellshock /
sudoers material; don't synthesise hypothetical attacks.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 20.5 | Command-injection vectors | 200 | 3 | **L** |
| 20.9 | Secrets handling | 180 | 2 | **L** |
| 20.13 | Symlink races | 160 | 2 | M |
| 20.11 | Privilege drop | 160 | 2 | M |
| 20.4 | `eval` avoidance | 160 | 2 | M |
| 20.1 | Threat model | 160 | 1 | M |
| 20.6 | Input validation | 150 | 2 | M |
| 20.12 | Sanitising filenames | 150 | 2 | M |
| 20.8 | SUID restrictions | 130 | 2 | M |

### Wave 1C — Signals & trap mechanics (4 leaves, ~620 lines)

Builds on Wave 1A; `trap` reference depth is essential for §12 / §16 /
§20 to feel coherent.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 12.5 | The `trap` builtin | 160 | 3 | M |
| 12.10 | Synchronous vs asynchronous delivery | 160 | 2 | M |
| 12.11 | Signal-safe code | 150 | 2 | M |
| 11.5 | Foreground vs background | 160 | 3 | M |

### Wave 1D — Process-management foundation (6 leaves, ~890 lines)

Underpins concurrency & IPC chapters. Author after Wave 1A so trap
references resolve.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 11.6 | Process groups and sessions | 170 | 2 | M |
| 11.1 | Bash process tree at runtime | 160 | 2 | M |
| 11.3 | Subshell origins | 150 | 2 | M |
| 11.12 | Detaching from the terminal | 150 | 2 | M |
| 11.2 | PIDs / `BASHPID` / `PPID` | 140 | 2 | M |
| 11.11 | `nohup` and `setsid` | 120 | 2 | M |

### Wave 1E — I/O discipline & CLI (4 leaves, ~570 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 14.7 | Logging discipline | 170 | 3 | M |
| 14.9 | Coloured output and `TERM` detection | 150 | 3 | M |
| 14.1 | Standard streams discipline | 130 | 2 | M |
| 15.2 | `getopts` builtin | 140 | 2 | M |
| 15.11 | Auto-generating usage | 130 | 2 | M |

### Wave 1F — Idioms cookbook self-containment (5 leaves, ~770 lines)

Part XXII is the *idioms* chapter; self-containment is the contract.
Three additional stubs (§22.10, §22.11, §22.13) reclassified from
ENRICH to PROMOTE under Decision 3.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 22.3 | Argument-parsing skeleton | 200 | 2 | **L** |
| 22.15 | Stack-trace error reporter | 150 | 1 | M |
| 22.10 | (deferral stub — to be inlined) | 140 | 2 | M |
| 22.11 | (deferral stub — to be inlined) | 140 | 2 | M |
| 22.13 | (deferral stub — to be inlined) | 140 | 2 | M |

Update `dispositions.tsv` rows for §22.10/§22.11/§22.13 from
`ENRICH` → `PROMOTE` at the start of Sprint 1.

**Sprint 1 total**: 38 leaves, ~5,710 lines, est. 4–5 author-weeks at
focused velocity.

---

## Sprint 2 — P2 PROMOTE drive, language proper (65 leaves, ~9,750 lines)

Authored after Sprint 1 so error-handling cross-refs resolve cleanly.

### Wave 2A — Parameters & arrays (10 leaves, ~1,820 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 4.4 | Shell variables | 220 | 2 | **L** |
| 4.9 | Indexed arrays | 220 | 3 | **L** |
| 4.5 | `declare` builtin and attributes | 200 | 3 | **L** |
| 4.10 | Associative arrays | 200 | 3 | **L** |
| 4.11 | Namerefs (`-n`) | 180 | 3 | **L** |
| 4.13 | Variable-assignment semantics | 170 | 2 | M |
| 4.6 | `local` and dynamic scope | 170 | 2 | M |
| 4.2 | Positional parameters | 160 | 2 | M |
| 4.12 | Integer arithmetic semantics | 150 | 2 | M |
| 4.8 | `export` and the environment | 150 | 2 | M |

### Wave 2B — Expansions (7 leaves, ~1,210 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 5.4 | Parameter and variable expansion | 260 | 4 | **L** |
| 5.8 | Word-splitting and `IFS` | 180 | 3 | **L** |
| 5.9 | Pathname expansion / globbing | 170 | 2 | M |
| 5.11 | Glob options | 160 | 2 | M |
| 5.6 | Command substitution | 150 | 2 | M |
| 5.12 | Extended globs | 150 | 2 | M |
| 5.7 | Process substitution | 140 | 2 | M |

### Wave 2C — Redirection (12 leaves, ~1,720 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 6.12 | `exec` for FD manipulation | 180 | 3 | **L** |
| 6.8 | Heredocs | 170 | 3 | M |
| 6.10 | Process substitution as redirection | 160 | 3 | M |
| 6.15 | `pipefail` semantics | 150 | 2 | M |
| 6.6 | Duplicating FDs | 150 | 2 | M |
| 6.13 | Pipelines | 140 | 2 | M |
| 6.4 | Stderr redirection and merging | 130 | 2 | M |
| 6.16 | `lastpipe` semantics | 130 | 2 | M |
| 6.11 | Order of evaluation | 120 | 2 | M |
| 6.7 | Moving and closing FDs | 120 | 2 | M |
| 6.5 | `<>` reading-and-writing | 100 | 1 | S |
| 6.9 | Here-strings | 100 | 2 | S |

### Wave 2D — Control flow (9 leaves, ~1,090 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 7.3 | `case…esac` | 160 | 3 | M |
| 7.10 | `&&` / `||` short-circuits | 140 | 2 | M |
| 7.6 | `while` / `until` | 130 | 2 | M |
| 7.8 | Subshell grouping | 120 | 2 | M |
| 7.2 | `if/elif/else/fi` | 120 | 2 | M |
| 7.7 | `select` | 110 | 2 | S |
| 7.4 | `for x in list` | 110 | 2 | S |
| 7.5 | C-style `for` | 100 | 2 | S |
| 7.9 | Brace grouping | 100 | 2 | S |

### Wave 2E — Conditionals & arithmetic (4 leaves, ~480 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 8.6 | Regex matching with `[[ … =~ … ]]` | 150 | 3 | M |
| 8.1 | `[[ ]]` overview | 120 | 2 | M |
| 8.9 | Arithmetic context | 110 | 2 | S |
| 8.5 | Pattern matching with `[[ … == … ]]` | 100 | 2 | S |

### Wave 2F — Functions & sourcing (7 leaves, ~930 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 9.3 | `local` and scope | 160 | 3 | M |
| 9.5 | Communicating results | 150 | 3 | M |
| 9.2 | Argument passing | 130 | 2 | M |
| 10.1 | `source` semantics | 130 | 2 | M |
| 9.1 | Definition syntax | 120 | 2 | M |
| 9.11 | Self-locating with `BASH_SOURCE` | 120 | 2 | M |
| 10.8 | Lazy and conditional loading | 120 | 2 | M |

### Wave 2G — Lexical & grammar (5 leaves, ~750 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 3.10 | Shell grammar | 160 | 2 | M |
| 3.1 | Tokenisation | 150 | 2 | M |
| 3.4 | Quoting overview | 150 | 2 | M |
| 3.6 | Double quotes | 150 | 2 | M |
| 3.11 | Operator precedence | 140 | 2 | M |

### Wave 2H — Concurrency, testing tooling (8 leaves, ~1,090 lines)

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 16.10 | Locking primitives | 180 | 3 | **L** |
| 21.7 | CI integration | 160 | 2 | M |
| 16.9 | Race conditions in shell | 160 | 2 | M |
| 16.11 | Signal handling under concurrency | 150 | 2 | M |
| 21.8 | bats-core | 140 | 2 | M |
| 21.10 | Bats run and assertions | 130 | 2 | M |
| 16.4 | Capturing per-child exit status | 120 | 2 | M |
| 21.6 | Pre-commit hooks | 120 | 2 | M |

**Sprint 2 total**: 65 leaves, ~9,840 lines, est. 5–7 author-weeks.

---

## Sprint 3 — P3 PROMOTE drive (5 leaves, ~830 lines)

Specialist context. Author last; lowest reader-impact-per-line.

| § | Title | Lines | Examples | Effort |
|---|-------|------:|---------:|:------:|
| 1.1 | Processes — fork, exec, wait | 180 | 2 | **L** |
| 1.2 | The file descriptor model | 180 | 2 | **L** |
| 2.5 | Startup file chains | 180 | 2 | **L** |
| 2.4 | Invocation modes | 160 | 2 | M |
| 1.5 | The shell environment | 150 | 2 | M |
| 1.7 | Exit status and process termination | 140 | 2 | M |
| 1.9 | Controlling terminal and TTY layer | 150 | 1 | M |
| 17.3 | Multiple coprocesses | 120 | 2 | M |

(8 leaves shown; agent breakdowns vary on Part-I/II priority assignment.)

---

## Sprint 4 — ENRICH pass (145 leaves, ~80 lines avg)

After PROMOTE leaves are authored, return to the 145 ENRICH leaves and
apply targeted bullet additions, tighter cross-refs, and single inline
mini-examples per the per-Part audit recommendations. Mean target ~80
lines per leaf; sum ~11,600 additional lines.

Order ENRICH work by Part priority band:
1. P1 ENRICH (54 leaves): Parts XII / XIII / XIV / XV / XX / XXII / Appendices.
2. P2 ENRICH (58 leaves): Parts III–IX, XVI.
3. P3 ENRICH (33 leaves): Parts I, II, XVII, XVIII, XIX, XXIII, XXIV, XXV.

---

## Sprint 5 — Re-audit (~3 days)

- Rerun the audit; validate disposition shifts (PROMOTE → KEEP after work).
- Run `bash docs/BCS-Bash-Ref/generate.bash`.
- Diff against `baseline-assembled.md`; expected drift = sum of authored
  prose plus mechanical fixes.
- Update `dispositions.tsv` with new state; add second baseline snapshot.

---

## Aggregate effort estimate

Adjusted for the 3 §22 reclassifications (ENRICH→PROMOTE) under
Decision 3, and the inline-citation work across PROMOTE/ENRICH passes
under Decision 2.

| Sprint | Leaves | Lines | Est. focused weeks |
|--------|------:|------:|-------------------:|
| Sprint 0 (mechanical fixes) | ~8 | ~30 | 0.2 |
| Sprint 1 (P1 PROMOTE) | 38 | ~5,710 | 4–5 |
| Sprint 2 (P2 PROMOTE) | 65 | ~9,840 | 5–7 |
| Sprint 3 (P3 PROMOTE) | 5–8 | ~830 | 1 |
| Sprint 4 (ENRICH) | 142 | ~11,400 | 4–6 |
| Sprint 5 (re-audit) | — | — | 0.5 |
| **Total** | ~253 of 350 | ~27,800 | **~15–20 weeks** |

Parallelism opportunities: Sprints 2–4 are leaf-independent; multiple
authors can divide cleanly along Part boundaries. Sprint 1 is mostly
serialised because §13.* and §20.* anchor downstream cross-references.

#fin
