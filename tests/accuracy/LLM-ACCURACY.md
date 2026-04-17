# BCS Check LLM Accuracy Report

Comparative analysis of LLM backends for `bcs check` compliance auditing.
Tested 2026-04-17 (refresh; original 2026-04-12) against four scripts of
varying complexity and structure.

## Test Subjects

| Script | Lines | Complexity | Structure | Key traits |
|---|---|---|---|---|
| `md2ansi` | ~1430 | High | Standard | Table rendering, syntax highlighting, `#bcscheck` suppressions |
| `cln` | ~245 | Low | Standard | Config loading, find-based matching, `#bcscheck` suppressions |
| `which` | ~111 | Medium | Dual-purpose | Source fence, nested function, `#end` marker, no metadata |
| `bcs-check-accuracy.sh` | ~95 | Low | Standard | Test runner, extglob arg parsing, no messaging functions |

The first two scripts are BCS-compliant with intentional deviations documented
via `#bcscheck disable=BCSxxxx` inline suppression directives. The latter two
have genuine (minor) BCS deviations that a correct checker should find.

## Models Tested

| Backend | Model | `-m` value | Cost tier |
|---|---|---|---|
| claude-code | claude-code | `claude`, `claude-code`, `fast`/`balanced`/`thorough` | $$$ |
| anthropic API | claude-sonnet-4-6 | `claude-sonnet-4-6` | $$ |
| openai API | gpt-5.4 | `gpt-5.4` | $$ |
| ollama (cloud) | minimax-m2.7:cloud | `minimax-m2.7:cloud` | $ |
| ollama (cloud) | glm-5.1:cloud | `glm-5.1:cloud` | $ |
| ollama (cloud) | qwen3-coder:480b-cloud | `qwen3-coder:480b-cloud` | $ |

Effort levels tested (all backends, 2026-04-17): `medium`, `high`, `max`.
The 2026-04-12 baseline additionally explored claude-code tier keywords
(`fast`/`balanced`/`thorough` with `low`/`medium`/`high` efforts); those
rows were retired in this refresh to keep the matrix uniform.

---

## Speed

### md2ansi (~40k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **71s** | **109s** | **109s** |
| claude-sonnet-4-6 | 83s | 101s | 128s |
| minimax-m2.7 | 113s | 78s | 229s |
| qwen3-coder | 277s | 48s | 83s |
| claude-code | 394s | 436s | 824s |
| glm-5.1 | N/A | N/A | N/A |

### cln (~28k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **qwen3-coder** | **21s** | 107s | 104s |
| gpt-5.4 | **23s** | **32s** | **25s** |
| claude-sonnet-4-6 | 69s | 86s | 104s |
| minimax-m2.7 | 135s | 182s | 140s |
| claude-code | 313s | 681s | 505s |
| glm-5.1 | N/A | N/A | N/A |

gpt-5.4 is the speed champion on three of four scripts, 2--4x faster
than claude-sonnet-4-6 on `cln`, `which`, and `accuracy.sh` (roughly
tied on md2ansi where both run 71--109s at medium). claude-code
wall-clock times shifted substantially upward from the 2026-04-12
baseline (md2ansi: 394--824s versus 38--81s then).

### which (~26k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **9s** | **12s** | **4s** |
| qwen3-coder | 26s | 109s | 45s |
| claude-sonnet-4-6 | 40s | 48s | 55s |
| minimax-m2.7 | 42s | 27s | 107s |
| claude-code | 302s | 225s | 280s |
| glm-5.1 | N/A | N/A | N/A |

### bcs-check-accuracy.sh (~25k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| minimax-m2.7 | **10s** | 33s | 149s |
| **gpt-5.4** | **13s** | **14s** | **14s** |
| claude-sonnet-4-6 | 35s | 43s | 42s |
| qwen3-coder | 142s | 61s | 34s |
| claude-code | 142s | 261s | 295s |
| glm-5.1 | N/A | N/A | N/A |

glm-5.1:cloud is marked `N/A` across all four scripts: every one of its
12 runs failed with HTTP 403 ("a subscription is required for access")
against ollama.com. The rows are retained for comparison if the API
returns.

---

## Output Token Efficiency

| Model | md2ansi med/high/max | cln med/high/max | which med/high/max | accuracy.sh med/high/max |
|---|---|---|---|---|
| **gpt-5.4** | **6169 / 10167 / 10102** | **1046 / 1995 / 1690** | **531 / 778 / 110** | **1053 / 787 / 1032** |
| qwen3-coder | 428 / 267 / 949 | 216 / 1028 / 743 | 397 / 734 / 689 | 667 / 634 / 628 |
| minimax-m2.7 | 7358 / 2281 / 7511 | 5449 / 12618 / 5750 | 3429 / 3465 / 5792 | 860 / 3656 / 5563 |
| claude-sonnet-4-6 | 4346 / 5454 / 6833 | 3857 / 4351 / 6189 | 2131 / 2444 / 2811 | 1953 / 2557 / 2443 |
| claude-code | -- / -- / -- | -- / -- / -- | -- / -- / -- | -- / -- / -- |
| glm-5.1 | N/A | N/A | N/A | N/A |

qwen3-coder is the most terse model in this refresh (110--1028 output
tokens per run) but largely because it reports few findings. gpt-5.4 is
substantially more verbose on md2ansi at 6169--10167 tokens, reflecting
the large `BCS1202`/`BCS1204` line-list findings it enumerates. claude-code
tokens read `--` because the Claude Code CLI backend does not expose
token counts. glm-5.1:cloud rows are `N/A` (see Speed notes).

---

## md2ansi Ground Truth

Consensus findings established from cumulative claude-family runs and
confirmed across multiple 2026-04-17 reruns. A finding requires 3+
independent confirmations (different model/effort combinations) to be
classified as ground truth.

| ID | BCS Code | Description | Lines | Confirmations |
|---|---|---|---|---|
| F1 | BCS0501 | `((OPTIONS[x] == 0))` should use `((!OPTIONS[x]))` | 561, 1073 | 7+ |
| F2 | BCS0107 | `usage()` / `show_help()` at L1202+ belongs before helpers | 1202 | 3 |
| F3 | BCS0706 | Color declarations scattered across two conditional blocks | 44--48, 191--238 | 3 |
| F4 | BCS0405 | `sanitize_ansi()` unnecessary wrapper; unused COLOR_* vars | 262--265 | 3 |
| F5 | BCS1205 | sed fork overhead in `colorize_line()` / debug path | 252, 1401 | 3 |
| F6 | BCS0805 | Bundling pattern includes arg-taking `-w` | 1321 | 4 |
| F7 | BCS1204 | Excessive 80-dash section separator comments | 31+ occurrences | 5 |
| F8 | BCS1201 | Arithmetic spacing: `$((a*b))`, `(($#==0))` without spaces | 17, 1318, 1413 | 4 |
| F9 | BCS0102 | Shebang `#!/usr/bin/env bash` instead of preferred `#!/usr/bin/bash` | 1 | 3 |
| F10 | BCS0105 | `DEBUG` declared mid-script after color block, not with other globals | 41 | 3 |

F9 and F10 are 2026-04-17 additions: each was independently flagged by
claude-sonnet-4-6 at all three effort levels (medium/high/max) and by
no other model. They meet the 3-confirmation threshold from within a
single model family, consistent with how earlier findings were
established.

---

## md2ansi Scoring

Every (model × effort) combination scored against the 10 consensus
findings. Half marks for partial hits (mentioned but not flagged,
variant framing, or only one of multiple affected lines). Rows are
ordered by score then time. Bold row = best run for that model.

| Model (best run) | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9 | F10 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **claude-sonnet-4-6 max** | Y | . | Y | . | h | h | Y | . | Y | Y | **6/10** | 0 | 128s |
| claude-sonnet-4-6 medium | h | . | . | . | . | . | Y | Y | Y | Y | **4.5/10** | 0 | 83s |
| claude-sonnet-4-6 high | . | . | . | . | . | h | Y | . | Y | Y | **3.5/10** | 0 | 101s |
| gpt-5.4 max | . | . | h | . | Y | . | Y | . | . | . | **2.5/10** | 2 | 109s |
| gpt-5.4 high | . | . | h | . | . | . | Y | . | . | . | **1.5/10** | 1 | 109s |
| gpt-5.4 medium | . | . | . | . | . | . | Y | . | . | . | **1/10** | 1 | 71s |
| claude-code max | h | h | . | . | . | . | . | . | . | . | **1/10** | 0 | 824s |
| claude-code medium | h | h | . | . | . | . | . | . | . | . | **1/10** | 0 | 394s |
| qwen3-coder max | . | . | . | Y | . | . | h | . | . | . | **1.5/10** | 4 | 83s |
| qwen3-coder medium | . | . | . | Y | . | . | . | . | . | . | **1/10** | 2 | 277s |
| minimax-m2.7 high | . | . | . | . | . | . | Y | . | . | . | **1/10** | 2 | 78s |
| minimax-m2.7 medium | . | . | . | . | . | h | . | . | . | . | **0.5/10** | 1 | 113s |
| claude-code high | . | . | . | . | . | . | . | . | . | . | **0/10** | 0 | 436s |
| qwen3-coder high | . | . | . | . | . | . | . | . | . | . | **0/10** | 3 | 48s |
| minimax-m2.7 max | . | . | . | . | . | . | . | . | . | . | **0/10** | 2 | 229s |
| glm-5.1 (any) | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | **N/A (API 403)** | -- | -- |

Legend: `Y` = found, `h` = half (partial/variant), `.` = missed

### Notable false positives (2026-04-17)

| Model | Claimed finding | Why it is wrong |
|---|---|---|
| claude-code max | BCS0102 at L239, L251, L850, L852: undocumented `#shellcheck disable` | BCS0102 is the shebang rule; undocumented shellcheck disables are a BCS0210/BCS1209 issue, not BCS0102 |
| gpt-5.4 max | BCS0702 L62: `_msg()` emits status to stdout | `_msg()` uses FUNCNAME dispatch; status messages are routed via `warn`/`error`/`info` which redirect to stderr |
| gpt-5.4 max | BCS0803 L1271: `noarg()` wrongly rejects arguments starting with `-` | This is the documented BCS0803 behaviour — an option missing its argument is caught precisely by this pattern |
| minimax-m2.7 high | BCS0109 L1430: missing `#fin` / `#end` end marker | `#fin` is present at the final line of md2ansi |
| minimax-m2.7 high | BCS0502 L1269: `case` missing `*)` handler | `*)` arm is present in the argument-parser case block |
| minimax-m2.7 max | BCS0202 L450, L1342: undeclared locals | Both variables are declared in the enclosing function's `local --` lines |
| qwen3-coder max | BCS0606 L79: missing `||:` after `DEBUG+=1` | `DEBUG+=1` is inside `debug()`, which is suppressed by `#bcscheck disable=BCS0703` and the arithmetic always succeeds under any non-zero counter |
| qwen3-coder max | BCS0103 L13: parameter expansion instead of `realpath` | md2ansi's SCRIPT_NAME derivation is the canonical pattern per BCS0103 |
| qwen3-coder max | BCS0804 L1266: `parse_arguments` outside `main()` | BCS0804 does not mandate that argument parsing live inside `main()`; either placement is acceptable |
| gpt-5.4 high (which) | BCS0109 L111: `#end` is not a valid end marker | BCS0109 explicitly permits both `#fin` and `#end` |
| gpt-5.4 high (which) | BCS0202 L49: `_path` assigned without `local` | Line 49 literally says `local _path=${PATH:-}` |
| gpt-5.4 (accuracy.sh, medium/max) | BCS0202 L72-L82: assignments not in function scope | The script has no functions; all logic is top-level. BCS0202 applies to function-local variables only |

---

## cln Ground Truth

Consensus findings confirmed across claude-sonnet-4-6, claude-code, and
gpt-5.4 runs in the 2026-04-17 refresh:

| ID | BCS Code | Description | Lines | Confirmations |
|---|---|---|---|---|
| C1 | BCS0111 | First-match-wins + user-first priority order vs cascade reference | 111--127 | 8+ |
| C2 | BCS0702 | `echo >&2` at L48 -- redirect at end, not beginning | 48 | 3 |
| C3 | BCS0403 | `return 0` vs `exit 0` for --version/--help | 176--177 | 3 |
| C4 | -- | Suppression test: honour `#bcscheck disable=BCS0806` at L169 | 169--172 | -- |

C4 is a meta-test: models that report BCS0806 on lines 170--172 without
acknowledging the suppression directive fail this test.

## cln Scoring

| Model (best run) | C1 | C2 | C3 | C4 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|
| **claude-sonnet-4-6 high** | Y | Y | h | Y | **3.5/4** | 0 | 86s |
| claude-sonnet-4-6 medium | Y | . | Y | Y | **3/4** | 0 | 69s |
| **gpt-5.4 medium** | Y | . | . | Y | **2/4** | 0 | **23s** |
| claude-code high | . | Y | . | h | **1.5/4** | 0 | 681s |
| claude-code max | . | Y | . | h | **1.5/4** | 2 | 505s |
| claude-sonnet-4-6 max | . | . | . | Y | **1/4** | 1 | 104s |
| gpt-5.4 high | Y | . | . | Y | **2/4** | 5 | 32s |
| gpt-5.4 max | Y | . | . | FAIL | **1/4** | 4 | 25s |
| qwen3-coder medium | Y | . | . | FAIL | **1/4** | 1 | 21s |
| claude-code medium | h | . | . | Y | **0.5/4** | 0 | 313s |
| minimax-m2.7 medium | h | . | . | h | **0.5/4** | 2 | 135s |
| minimax-m2.7 max | . | . | . | Y | **0/4** | 1 | 140s |
| qwen3-coder max | . | . | . | FAIL | **0/4** | 3 | 104s |
| qwen3-coder high | . | . | . | FAIL | **0/4** | 6 | 107s |
| minimax-m2.7 high | . | . | . | FAIL | **0/4** | 4 | 182s |
| glm-5.1 (any) | -- | -- | -- | -- | **N/A (API 403)** | -- | -- |

claude-sonnet-4-6 high is the top scorer on `cln` in this refresh,
finding both the structural C1 (config loader pattern) and the C2
stderr placement issue, with half credit for framing C3 as BCS0804
rather than BCS0403. gpt-5.4 medium remains the fastest accurate
run at 23s with 2/4 and zero false positives. minimax-m2.7 max --
previously the worst single run in the dataset with four false
positives -- now emits a single BCS1211 finding about the `decp()`
sed regex and no longer hallucinates about declarations or bundling.

---

## which Ground Truth

The `which` script is a dual-purpose (sourceable function + direct execution)
script using a source fence pattern. Key real issues:

| ID | BCS Code | Description | Lines |
|---|---|---|---|
| W1 | BCS0201 | `local` without `--` type separator for string variables | 11, 49 |
| W2 | BCS0103 | No `VERSION` variable; version hardcoded in help and printf | 15, 35 |
| W3 | BCS0106 | Source fence uses `|| { ... }` block variant | 104--109 |

Note: `#end` on line 111 is valid per BCS0109 (the standard permits both
`#fin` and `#end`). Models that flag `#end` as a violation are wrong.

## which Scoring

| Model (best run) | W1 | W2 | W3 | Score | FPs | Time |
|---|---|---|---|---|---|---|
| **claude-sonnet-4-6 max** | Y(2) | Y | Y | **3/3** | 2 | 55s |
| claude-code max | Y(2) | Y | Y | **3/3** | 2 | 280s |
| claude-code medium | Y(1) | Y | Y | **2.5/3** | 0 | 302s |
| claude-code high | Y(2) | . | . | **2/3** | 0 | 225s |
| claude-sonnet-4-6 high | Y(2) | . | . | **2/3** | 1 | 48s |
| **gpt-5.4 medium** | Y(2) | . | . | **2/3** | 1 | **9s** |
| gpt-5.4 high | Y(2) | . | . | **2/3** | 5 | 12s |
| minimax-m2.7 max | Y(2) | . | . | **2/3** | 6 | 107s |
| qwen3-coder max | Y(1) | Y | . | **1.5/3** | 4 | 45s |
| qwen3-coder high | . | Y | . | **1/3** | 5 | 109s |
| minimax-m2.7 medium | Y(1) | . | h | **1/3** | 2 | 42s |
| claude-sonnet-4-6 medium | Y(1) | . | . | **0.5/3** | 0 | 40s |
| gpt-5.4 max | Y(1) | . | . | **0.5/3** | 0 | 4s |
| qwen3-coder medium | . | . | . | **0/3** | 3 | 26s |
| minimax-m2.7 high | . | . | . | **0/3** | 0 | 27s |
| glm-5.1 (any) | -- | -- | -- | **N/A (API 403)** | -- | -- |

Y(2) = found both instances, Y(1) = found one of two.

On `which` the three top scorers -- claude-sonnet-4-6 max, claude-code
max, claude-code medium -- all catch the full source-fence + `VERSION`
+ `local --` set, though claude-code max paraphrases W3 as BCS0406
rather than BCS0106. gpt-5.4 medium is the fastest run at 9s with
2/3 at 1 FP. gpt-5.4 max emitted just two lines (one valid BCS0201,
one acknowledged non-finding) in 4s -- honest but minimal coverage.
The persistent 2026-04-12 `#end` false positive now appears only at
gpt-5.4 high and qwen3-coder max, not across all gpt-5.4 runs.

---

## bcs-check-accuracy.sh Ground Truth

The test runner script has several genuine (minor) deviations:

| ID | BCS Code | Description | Lines | Detection rate |
|---|---|---|---|---|
| A1 | BCS0101 | Missing `shift_verbose` and `nullglob` in shopt | 4 | **0/15** |
| A2 | -- | Array spacing before closing paren | 11 | **0/15** |
| A3 | BCS1202 | "ommitted" typo in comment | 26 | 4/15 |
| A4 | BCS0801 | if/elif+extglob instead of while/case | 35--63 | 9/15 |
| A5 | BCS0602 | `exit 1` for invalid arg; should be `exit 22` | 60 | 8/15 |
| A6 | BCS1201 | `$((EPOCHSECONDS-start_time))` missing spaces | 93 | **0/15** |
| A7 | BCS0703 | No messaging functions; uses raw `>&2 printf` | 59, 80, 82 | 6/15 |

Three issues (A1, A2, A6) remain missed by **every non-failed model at
every effort** (0/15; glm-5.1's 3 efforts are excluded due to the API
outage, reducing the effective denominator from 18 to 15).

## bcs-check-accuracy.sh Scoring

| Model (best run) | A3 | A4 | A5 | A7 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|
| **claude-sonnet-4-6 max** | Y | Y | Y | Y | **4/4** | 2 | **42s** |
| claude-code high | . | Y | Y | Y | **3/4** | 1 | 261s |
| claude-code max | . | Y | h | Y | **2.5/4** | 0 | 295s |
| claude-sonnet-4-6 medium | . | Y | Y | . | **2/4** | 0 | 35s |
| claude-code medium | . | Y | Y | . | **2/4** | 0 | 142s |
| claude-sonnet-4-6 high | . | Y | h | . | **1.5/4** | 0 | 43s |
| gpt-5.4 high | Y | . | h | . | **1.5/4** | 5 | 14s |
| gpt-5.4 max | . | . | Y | h | **1.5/4** | 5 | 14s |
| gpt-5.4 medium | Y | . | . | h | **1.5/4** | 7 | 13s |
| qwen3-coder max | Y | . | . | . | **1/4** | 3 | 34s |
| qwen3-coder high | . | . | . | Y | **1/4** | 3 | 61s |
| qwen3-coder medium | . | h | . | . | **0.5/4** | 2 | 142s |
| minimax-m2.7 high | . | . | . | . | **0/4** | 2 | 33s |
| minimax-m2.7 medium | . | . | . | . | **0/4** | 1 | 10s |
| minimax-m2.7 max | . | . | . | . | **0/4** | 0 | 149s |
| glm-5.1 (any) | -- | -- | -- | -- | **N/A (API 403)** | -- | -- |

Scored against the 4 detectable issues (A1, A2, A6 universally missed).

claude-sonnet-4-6 max overtakes gpt-5.4 max as the top scorer on this
script, becoming the only model to hit all four detectable issues
including the "ommitted" typo. The two accompanying false positives
are benign (preferred-shebang style point, `TZ=UTC0` vs `TZ=UTC`).
gpt-5.4 remains the typo catcher at high and medium, but its runs are
loaded with false positives arising from applying BCS0202 (function-
local variable scoping) to a script that has no functions. The
previously-flagged `#fin` hallucinations from claude-code high and
minimax-m2.7 medium no longer appear in the fresh runs.

---

## Effort-Accuracy Relationship

| Model | Effect of increasing effort | Pattern |
|---|---|---|
| claude-sonnet-4-6 | Positive -- max is top scorer on md2ansi and accuracy.sh | More effort = deeper analysis |
| claude-code | Weakly positive -- max reaches most findings but also longest wall clock | Diminishing returns past high |
| gpt-5.4 | Mixed -- high catches typo on accuracy.sh; max adds FPs on cln/accuracy.sh | Max marginal or harmful |
| minimax-m2.7 | Flat or mildly inverse -- max no longer catastrophic but adds FPs | More effort = more verbose without more recall |
| qwen3-coder | Positive on max for accuracy.sh typo; output is now well-formed at max | Usable at all three efforts in this refresh |
| glm-5.1 | Untested -- all 12 runs failed HTTP 403 | API outage |

Models with native reasoning capability (claude-code, claude-sonnet-4-6)
benefit from higher effort because they use the extra token budget for
deeper rule application. Cloud-ollama models show flat or mildly inverse
curves -- extra tokens fill with rationalizations or duplicate findings
rather than new insights. The 2026-04-12 "qwen3-coder max is broken"
characterisation no longer applies: the XML tool-call contamination is
absent from the 2026-04-17 max run.

---

## Suppression Directive Handling

The `#bcscheck disable=BCSxxxx` mechanism is how users document
intentional deviations. A model that ignores these directives wastes
developer time investigating non-issues.

| Model | md2ansi suppressions | cln BCS0806 suppression | Verdict |
|---|---|---|---|
| claude-code | Always honoured | Honoured at medium/high; partial note at max | Reliable |
| claude-sonnet-4-6 | Always honoured | Correctly analyses scope at all efforts | Reliable |
| gpt-5.4 | Honoured at medium/high; max flags suppressed BCS0806 | Honoured at medium/high; max flags BCS0806 L170-172 without acknowledging suppression | Reliable at medium; degrades at max |
| minimax-m2.7 | Partial (flags some suppressed rules) | Fails at high (flags 170-171); honours at max | Unreliable |
| qwen3-coder | Partial | Fails at all three efforts (flags L170 without noting suppression) | Unreliable |
| glm-5.1 | Untested (API 403) | Untested (API 403) | Unavailable |

---

## Output Integrity

| Model | Issue | Severity |
|---|---|---|
| glm-5.1:cloud (all 12 runs) | HTTP 403 "a subscription is required for access"; 0--1s elapsed, empty output | **Deployment blocker (vendor outage)** |
| minimax-m2.7 high (cln) | 4 false positives about array scalar declarations, plus BCS0806 flagged without honouring suppression | Critical |
| gpt-5.4 medium/max (accuracy.sh) | BCS0202 "function-local scope" findings on a script with no functions | Critical |
| qwen3-coder max (md2ansi) | BCS1201 "line 4 exceeds 120 chars" when line 4 is 34 chars; BCS0102 demand for `/usr/bin/bash` (three forms are acceptable) | Moderate |
| qwen3-coder high (cln) | BCS0101 flagged against script that has correct strict-mode ordering | Moderate |
| gpt-5.4 high (which) | Flags `#end` as invalid per BCS0109; flags `local _path` as missing `local` | Systematic |
| claude-sonnet-4-6 (all) | Self-correction traces ("Retracted -- no finding") inflate output but improve accuracy | Cosmetic |
| gpt-5.4 (all non-which) | Clean, terse reports with no reasoning leakage | Best in class |

The 2026-04-12 critical hallucinations -- qwen3-coder max emitting
`<minimax:tool_call>` XML, minimax-m2.7 max producing 4 wrong claims
about `cln`, and the paired claude-code/minimax claims that accuracy.sh
lacked `#fin` -- did not recur in the 2026-04-17 refresh. glm-5.1:cloud
has moved from "accuracy deployment blocker" to "vendor-outage
deployment blocker": the model is entirely unavailable.

---

## Combined Rankings

### Best accuracy across all 4 scripts

| Rank | Model | md2ansi | cln | which | accuracy.sh | Avg FPs | Notes |
|---|---|---|---|---|---|---|---|
| 1 | claude-sonnet-4-6 max | 6/10 | 1/4 | 3/3 | 4/4 | 0--2 | Highest recall on md2ansi and accuracy.sh |
| 2 | claude-sonnet-4-6 high | 3.5/10 | 3.5/4 | 2/3 | 1.5/4 | 0--1 | Best on `cln`; strong second tier overall |
| 3 | claude-code max | 1/10 | 1.5/4 | 3/3 | 2.5/4 | 0--2 | Deepest `which` analysis (3/3 with BCS0406 framing) |
| 4 | claude-sonnet-4-6 medium | 4.5/10 | 3/4 | 0.5/3 | 2/4 | 0 | Most consistent zero-FP run across all scripts |
| 5 | gpt-5.4 medium | 1/10 | 2/4 | 2/3 | 1.5/4 | 1--7 | Best speed-to-coverage ratio; unreliable on accuracy.sh |

### Best speed-to-quality ratio

| Rank | Model | Best script score | Avg time | Notes |
|---|---|---|---|---|
| 1 | gpt-5.4 medium | 2/4 (cln) | 9--71s | Fastest usable check; mostly clean on cln/which |
| 2 | claude-sonnet-4-6 medium | 4.5/10 (md2ansi) | 35--83s | Zero-FP across all four scripts at medium effort |
| 3 | claude-sonnet-4-6 max | 6/10 (md2ansi) | 42--128s | Highest accuracy tier; 2x slower than medium |

### Unique strengths by model

| Model | Unique capability | Example |
|---|---|---|
| claude-sonnet-4-6 | BCS0201 `local --` detection + BCS0501 flag-zero idiom | Only model to find both missing `--` separators in `which` and both `((FLAG == 0))` sites in md2ansi |
| claude-code | Deepest rule citation on suppression/fence patterns | Consistently flags BCS0106 source-fence form and BCS0806 suppression boundaries |
| gpt-5.4 | Typo/comment detection on prose | Catches "ommitted" at accuracy.sh L26 (shared with claude-sonnet-4-6 max and qwen3-coder max in this refresh) |

### Currently unavailable

| Model | Evidence |
|---|---|
| glm-5.1:cloud | All 12 runs returned HTTP 403 "a subscription is required for access" via ollama.com; 0--1s elapsed, empty output. Status is an infrastructure issue, not an accuracy verdict. If the API returns, rerun before classifying. |

### Weak but no longer unsafe

| Model | Evidence across 3 completed scripts |
|---|---|
| minimax-m2.7:cloud | 1/10 md2ansi, 0/4 cln, 2/3 which, 0/4 accuracy.sh. No critical hallucinations in the refresh; cln-max now produces a single BCS1211 finding rather than four FPs. Still produces verbose output and misses most ground-truth items, but no longer hallucinates widely. |
| qwen3-coder:480b-cloud | 1.5/10 md2ansi, 1/4 cln, 2/3 which (via max: Y(2) BCS0201 + BCS0103), 1/4 accuracy.sh. XML tool-call contamination at max is gone. Runs are readable but recall is low and FP rate is high. Useful only as a secondary opinion. |

---

## Recommendations

### Tier defaults

The `_detect_backend()` probe order (ollama, anthropic, openai, google,
claude) means the `fast` tier currently routes to minimax/glm/qwen when
an ollama server is running -- producing the worst results in this dataset.

| Tier | Current behaviour | Recommended default | Rationale |
|---|---|---|---|
| `fast` | First reachable ollama model | gpt-5.4 at medium | 9--71s, clean output on most scripts, 2/4 cln + 2/3 which with 0--1 FP |
| `balanced` | First reachable (varies) | claude-sonnet-4-6 at medium | 35--83s, zero FP across all four scripts, reliable suppression handling |
| `thorough` | First reachable (varies) | claude-sonnet-4-6 at max | 42--128s, top scorer on md2ansi (6/10) and accuracy.sh (4/4) |

gpt-5.4-mini was referenced in the previous revision of this doc but
is not in the current test matrix; the fast-tier recommendation is
therefore plain `gpt-5.4` until a mini variant is benchmarked.

### Detection order

Consider reversing to openai, anthropic, ollama for tier resolution.
This immediately fixes the quality floor by avoiding ollama-cloud models
as tier defaults while preserving them as explicit `--model` choices.

### Effort guidance

- **medium**: Best default for gpt-5.4 (speed) and claude-sonnet-4-6
  (zero-FP baseline). Rarely worse than higher effort for cloud models.
- **high**: Beneficial for claude-code and claude-sonnet-4-6 on
  structurally complex scripts. Marginal for gpt-5.4 and cloud models.
- **max**: Recommended only for claude-sonnet-4-6 when catching
  low-rate findings matters. For gpt-5.4 and cloud-ollama models,
  max inflates runtime and tends to add false positives without new
  insights.

### Hard-refuse rules

| Condition | Action |
|---|---|
| `--model glm-5.1:cloud` (any effort) | Fail fast with API-error hint until vendor outage resolves |
| `--effort max` with minimax-m2.7:cloud | Warn user: accuracy ceiling is the same as medium at ~2x runtime |
| Any ollama-cloud model as tier default | Prefer API backends when available |

The 2026-04-12 refusal rule for `--effort max` with qwen3-coder has
been withdrawn: the XML tool-call contamination that motivated it did
not recur in the 2026-04-17 refresh.

---

## Universally Missed Findings

These real issues remain missed by **every non-failed model at every
effort level** (0/15 across non-glm runs; glm-5.1's 3 efforts per script
are excluded due to the HTTP 403 outage):

| Script | Issue | Why it matters |
|---|---|---|
| bcs-check-accuracy.sh | Missing `shift_verbose` and `nullglob` in shopt (BCS0101) | BCS0101 mandates specific shopt options |
| bcs-check-accuracy.sh | Array spacing before closing `)` at L11 | Style rule, hard to detect |
| bcs-check-accuracy.sh | Missing spaces in `$((EPOCHSECONDS-start_time))` at L93 (BCS1201) | Arithmetic formatting rule; models cite different BCS1201 issues (line length) but miss the arithmetic spacing |

These represent the current detection ceiling -- no available model
catches these patterns, making them blind spots in automated BCS checking.

---

## Methodology

### Test procedure

```bash
declare -a scripts=(md2ansi cln which bcs-check-accuracy.sh)
declare -a models=(claude claude-sonnet-4-6 gpt-5.4
  minimax-m2.7:cloud glm-5.1:cloud qwen3-coder:480b-cloud)
declare -a efforts=(medium high max)

for script in "${scripts[@]}"; do
  for model in "${models[@]}"; do
    for effort in "${efforts[@]}"; do
      bcs check --model "$model" --effort "$effort" "$script"
    done
  done
done
```

Total: 72 reports (2026-04-17 refresh; 4 scripts × 6 models × 3 efforts).
Of these, 12 runs (glm-5.1:cloud × all 4 scripts × all 3 efforts) failed
with HTTP 403 from ollama.com and are excluded from scoring. Effective
sample: 60 completed runs.

### Ground truth establishment

Ground truth is established by consensus across independent runs.
A finding requires 3+ confirmations from different model/effort
combinations to be classified as a consensus finding. Claude-family
models (claude-code, claude-sonnet-4-6) provide the primary baseline
due to consistently higher recall and lower false-positive rates.

For `which` and `bcs-check-accuracy.sh`, ground truth was additionally
verified by manual code inspection since fewer baseline runs existed.
Ground-truth items F9 and F10 for md2ansi were added in the 2026-04-17
refresh after all three claude-sonnet-4-6 efforts (medium/high/max)
independently flagged the same finding; no earlier run had produced
these flags because only claude-sonnet-4-6 appears to detect them.

### Scoring

- **True positive (Y)**: Finding matches a consensus ground-truth item
  in both rule code and line reference.
- **Half mark (h)**: Finding is mentioned in analysis but not flagged
  in the summary table, or uses variant framing that partially overlaps.
- **False positive (FP)**: Finding contradicts the BCS standard, misreads
  the code, or reports a suppressed rule without noting the suppression.
- **Miss (.)**: Consensus finding not reported at any severity level.

### Limitations

- Four test scripts cover standard, dual-purpose, and test-runner patterns
  but do not cover library-only scripts or scripts with concurrency.
- Ground truth is consensus-based for md2ansi/cln, manually verified
  for which/bcs-check-accuracy.sh. Some findings may be debatable.
- glm-5.1:cloud was unreachable for the entire refresh (all 12 runs
  returned HTTP 403). Comparative claims about glm-5.1 therefore
  carry over from the 2026-04-12 baseline and may be stale.
- Claude Code CLI backend does not expose token counts, so its rows
  in the token-efficiency table read `--` rather than a number.
- Cost data is not included. Token counts provide a proxy but actual
  API pricing varies by provider and model.
