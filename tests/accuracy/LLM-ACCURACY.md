# BCS Check LLM Accuracy Report

Comparative analysis of LLM backends for `bcs check` compliance auditing.
Tested 2026-04-12 against four scripts of varying complexity and structure.

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

Effort levels tested: `medium`, `high`, `max` for API/ollama models;
`low`, `medium` (+ `high` for balanced) for claude-code tier keywords.

---

## Speed

### md2ansi (~35k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **10s** | **13s** | **35s** |
| minimax-m2.7 | 33s | 31s | 30s |
| qwen3-coder | 30s | 73s | 62s |
| claude-code | 81s | 38s | 39s |
| glm-5.1 | 47s | 197s | 115s |
| claude-sonnet-4-6 | 87s | 82s | 115s |
| claude-code fast | 856s (low) | 1454s (med) | -- |
| claude-code balanced | 382s (low) | 286s (med) | 524s (high) |
| claude-code thorough | 126s (low) | 445s (med) | -- |

### cln (~23k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **15s** | **27s** | **26s** |
| minimax-m2.7 | 24s | 27s | 82s |
| qwen3-coder | 41s | 76s | 38s |
| claude-sonnet-4-6 | 28s | 41s | 57s |
| glm-5.1 | 46s | 58s | 45s |
| claude-code | 71s | 35s | 53s |

gpt-5.4 is the speed champion at 9--35s, 3--10x faster than everything
else on the same input.

### which (~21k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **13s** | **9s** | **17s** |
| claude-code | 32s | 37s | 39s |
| claude-sonnet-4-6 | 42s | 39s | 31s |
| minimax-m2.7 | 43s | 83s | 30s |
| qwen3-coder | 49s | 36s | 98s |
| glm-5.1 | 61s | 49s | 118s |

### bcs-check-accuracy.sh (~21k input tokens)

| Model | medium | high | max |
|---|---|---|---|
| **gpt-5.4** | **18s** | **11s** | **14s** |
| claude-code | 23s | 21s | 27s |
| minimax-m2.7 | 16s | 52s | 21s |
| qwen3-coder | 39s | 66s | 25s |
| glm-5.1 | 45s | 47s | 26s |
| claude-sonnet-4-6 | 51s | 52s | 44s |

---

## Output Token Efficiency

| Model | md2ansi med/high/max | cln med/high/max | which med/high/max | accuracy.sh med/high/max |
|---|---|---|---|---|
| **gpt-5.4** | **414 / 792 / 2304** | **915 / 1722 / 1358** | **719 / 579 / 1028** | **1118 / 755 / 1034** |
| minimax-m2.7 | 3119 / 2378 / 2594 | 1349 / 1314 / 4747 | 2676 / 5323 / 1765 | 944 / 3427 / 1237 |
| qwen3-coder | 1654 / 6203 / 4678 | 3390 / 6157 / 2585 | 3067 / 1827 / 6910 | 2991 / 4118 / 1691 |
| claude-code | 8000 / 3160 / 3073 | 6702 / 2879 / 4686 | 2097 / 2023 / 2456 | 1384 / 1260 / 1836 |
| glm-5.1 | 2086 / 12794 / 7843 | 3083 / 4196 / 3068 | 3703 / 2933 / 9640 | 2156 / 2967 / 1402 |
| claude-sonnet-4-6 | 4827 / 4133 / 5835 | 1237 / 2268 / 2960 | 2024 / 2096 / 1519 | 2580 / 2671 / 2558 |

gpt-5.4 medium produces 414--1118 output tokens across all scripts --
consistently 3--12x fewer than other models. glm-5.1 at max effort on
`which` emitted 9640 tokens for zero findings.

---

## md2ansi Ground Truth

Consensus findings established from 10+ claude-family runs (claude-code
tier keywords, claude-code direct, claude-sonnet-4-6 API). A finding requires
3+ independent confirmations to be classified as ground truth.

| ID | BCS Code | Description | Lines | Confirmations |
|---|---|---|---|---|
| F1 | BCS0501 | `((OPTIONS[x] == 0))` should use `((!OPTIONS[x]))` | 557, 1073 | 7+ |
| F2 | BCS0107 | `usage()` at L1202 belongs before helpers (layer 2) | 1202 | 3 |
| F3 | BCS0706 | Color declarations scattered across two conditional blocks | 44--48, 191--238 | 3 |
| F4 | BCS0405 | `sanitize_ansi()` unnecessary wrapper; unused COLOR_* vars | 262--265 | 3 |
| F5 | BCS1205 | sed fork overhead in `colorize_line()` hot path | 252, 282--316 | 3 |
| F6 | BCS0805 | Bundling pattern includes arg-taking `-w` | 1321 | 4 |
| F7 | BCS1204 | Excessive 80-dash section separator comments | 31 occurrences | 5 |
| F8 | BCS1201 | Arithmetic spacing: `(($#==0))`, `>1` without spaces | 1318, 1413 | 4 |

---

## md2ansi Scoring

Each model's **best single run** scored against the 8 consensus findings.
Half marks for partial hits (mentioned but not flagged, or variant framing).

| Model (best run) | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|---|---|---|---|
| claude-code balanced-high | Y | Y | Y | Y | . | . | Y | . | **5/8** | 0 | 524s |
| claude-code thorough-medium | Y | . | . | Y | Y | . | . | Y | **4/8** | 0 | 445s |
| claude-code balanced-medium | Y | Y | Y | . | . | . | . | Y | **4/8** | 0 | 286s |
| claude-sonnet-4-6 max | Y | . | . | . | h | . | Y | Y | **3.5/8** | 1 | 115s |
| **gpt-5.4 high** | . | . | . | . | . | Y | Y | . | **2/8** | 0 | **13s** |
| gpt-5.4 medium | . | . | . | . | . | . | Y | Y | **2/8** | 0 | **10s** |
| gpt-5.4 max | . | . | . | . | h | . | Y | . | **1.5/8** | 2 | 35s |
| claude-code max | . | . | . | . | . | . | . | . | **0/8** | 1 | 39s |
| glm-5.1 medium | . | . | . | . | . | h | . | . | **0.5/8** | 0 | 47s |
| qwen3-coder high | . | . | . | . | . | . | . | . | **~0.5/8** | 1 | 73s |
| minimax-m2.7 (any) | . | . | . | . | . | . | . | . | **0/8** | 1--3 | ~30s |
| qwen3-coder max | . | . | . | . | . | . | . | . | **BROKEN** | -- | 62s |

Legend: `Y` = found, `h` = half (partial/variant), `.` = missed

### Notable false positives

| Model | Claimed finding | Why it is wrong |
|---|---|---|
| claude-sonnet-4-6 max | BCS0101: `shift_verbose` not a valid shopt option | It is valid in Bash 5.2 |
| gpt-5.4 max | BCS0203: `PS4` is a shell built-in name conflict | PS4 is the *intended* xtrace variable; BCS1207 recommends setting it |
| gpt-5.4 max | BCS0203: `DEBUG` reuses shell internals | DEBUG is the BCS-standard flag name per BCS0208/BCS1207 |
| minimax-m2.7 high | BCS0702: `debug()` missing stderr redirect | Suppressed by `#bcscheck disable=BCS0703` at L72 |
| minimax-m2.7 max | BCS0109: blank line before `#fin` | All claude runs verify `#fin` correct |
| qwen3-coder medium | BCS1002: PATH should include `~/.local/bin` | Inverts the rule -- BCS1002 mandates a locked-down PATH |
| qwen3-coder max | Hallucinated `<minimax:tool_call>` XML | Model emitted tool-call syntax from training data, no report produced |
| gpt-5.4 (all, which) | BCS0109: `#end` is not a valid end marker | BCS0109 explicitly permits both `#fin` and `#end` |
| gpt-5.4 high (which) | BCS0702: stderr redirect missing on lines 63/85 | Both lines already use `>&2` at command start (correct form) |
| gpt-5.4 max (which) | BCS1002: trusting `$PATH` is a security violation | A `which` command must use PATH by design |
| gpt-5.4 max (which) | BCS0202: `_path` assigned without `local` | Line 49 literally says `local _path=...` |
| claude-code high (accuracy.sh) | BCS0109: missing `#fin` | `#fin` IS present at line 95 |
| minimax-m2.7 med (accuracy.sh) | BCS0109: missing `#fin` | Same hallucination as above |

---

## cln Ground Truth

Consensus findings from claude-sonnet-4-6 (3 runs) and gpt-5.4 (3 runs):

| ID | BCS Code | Description | Lines | Confirmations |
|---|---|---|---|---|
| C1 | BCS0111 | First-match-wins vs cascade; user-first priority order | 111--127 | 6+ |
| C2 | BCS0702 | `echo >&2` at L48 -- redirect at end, not beginning | 48 | 2 |
| C3 | BCS0403 | `return 0` vs `exit 0` for --version/--help | 176--177 | 5 |
| C4 | -- | Suppression test: honour `#bcscheck disable=BCS0806` at L169 | 169--172 | -- |

C4 is a meta-test: models that report BCS0806 on lines 170--172 without
acknowledging the suppression directive fail this test.

## cln Scoring

| Model (best run) | C1 | C2 | C3 | C4 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|
| **gpt-5.4 medium** | Y | Y | Y | Y | **4/4** | 0 | **15s** |
| claude-sonnet-4-6 medium | Y | Y | Y | Y | **4/4** | 0 | 28s |
| claude-sonnet-4-6 high | Y | . | Y | Y | **3/4** | 0 | 41s |
| gpt-5.4 high | Y | . | Y | Y | **3/4** | 0 | 27s |
| claude-code high | Y | . | . | Y | **2/4** | 0 | 35s |
| claude-code max | Y | . | . | Y | **2/4** | 0 | 53s |
| qwen3-coder high | Y | . | . | . | **1/4** | 0 | 76s |
| minimax-m2.7 high | h | . | . | -- | **0.5/4** | 0.5 | 27s |
| glm-5.1 high | . | . | . | FAIL | **0/4** | 1 | 58s |
| qwen3-coder medium | . | . | . | FAIL | **0/4** | 1 | 41s |
| **minimax-m2.7 max** | . | . | . | -- | **0/4** | **4** | 82s |

minimax-m2.7 max produced 4 hallucinated false positives against easily
verifiable facts: claimed `SCRIPT_NAME` lacked `declare -r` (it has it),
claimed `DELETE_FILES` lacked `declare -a` (wrong), claimed `-L` missing
from bundling class (it is present), and misread `read_conf()` semantics.
This is the worst single run in the dataset.

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
| claude-sonnet-4-6 medium | Y(2) | Y | Y | **3/3** | 1 soft | 42s |
| claude-sonnet-4-6 max | Y(2) | . | Y | **2/3** | 1 | 31s |
| claude-code high | . | Y | . | **1/3** | 0 | 37s |
| gpt-5.4 medium | Y(1) | . | . | **0.5/3** | 1 | 13s |
| gpt-5.4 max | Y(1) | h | . | **1/3** | 2 | 17s |
| minimax-m2.7 high | . | h | . | **0.5/3** | 0 | 83s |
| qwen3-coder max | . | Y | . | **1/3** | 0 | 98s |
| glm-5.1 medium | . | . | h | **0.5/3** | 0 | 61s |
| gpt-5.4 high | . | . | . | **0/3** | **3** | 9s |
| minimax-m2.7 max | . | . | . | **0/3** | 0 | 30s |
| glm-5.1 max | . | . | . | **0/3** | 0 | 118s |

Y(2) = found both instances, Y(1) = found one of two.

gpt-5.4 high is the worst run on `which` -- 9s but all 3 findings are
false positives (BCS0106/L101 wrong reasoning, BCS0109 `#end`, BCS0702
on lines that already use correct `>&2` placement).

Recurring FP: all three gpt-5.4 runs flagged `#end` as invalid per BCS0109.

Only claude-sonnet-4-6 found BCS0201 on **both** lines 11 and 49.

---

## bcs-check-accuracy.sh Ground Truth

The test runner script has several genuine (minor) deviations:

| ID | BCS Code | Description | Lines | Detection rate |
|---|---|---|---|---|
| A1 | BCS0101 | Missing `shift_verbose` and `nullglob` in shopt | 4 | **0/18** |
| A2 | -- | Array spacing before closing paren | 11 | **0/18** |
| A3 | BCS1202 | "ommitted" typo in comment | 26 | 2/18 |
| A4 | BCS0801 | if/elif+extglob instead of while/case | 35--63 | 8/18 |
| A5 | BCS0602 | `exit 1` for invalid arg; should be `exit 22` | 60 | 5/18 |
| A6 | BCS1201 | `$((EPOCHSECONDS-start_time))` missing spaces | 93 | **0/18** |
| A7 | BCS0703 | No messaging functions; uses raw `>&2 printf` | 59, 80, 82 | 5/18 |

Three issues (A1, A2, A6) were missed by **every model at every effort**.

## bcs-check-accuracy.sh Scoring

| Model (best run) | A3 | A4 | A5 | A7 | Score | FPs | Time |
|---|---|---|---|---|---|---|---|
| gpt-5.4 max | Y | Y | Y | Y | **4/4** | 0 | 14s |
| claude-sonnet-4-6 medium | . | Y | Y | h | **2.5/4** | 0 | 51s |
| claude-sonnet-4-6 high | . | Y | Y | Y | **3/4** | 1 | 52s |
| gpt-5.4 medium | . | Y | Y | Y | **3/4** | 2 | 18s |
| gpt-5.4 high | Y | . | . | Y | **2/4** | 2 | 11s |
| claude-sonnet-4-6 max | . | Y | Y | . | **2/4** | 0 | 44s |
| claude-code medium | . | Y | . | . | **1/4** | 1 | 23s |
| qwen3-coder max | . | Y | . | . | **1/4** | 2 | 25s |
| claude-code high | . | . | . | . | **0/4** | 3 | 21s |
| minimax-m2.7 (any) | . | . | . | . | **0/4** | 1--3 | 16--52s |
| glm-5.1 (any) | . | . | . | . | **0/4** | 0--1 | 26--47s |

Scored against the 4 detectable issues (A1, A2, A6 universally missed).

gpt-5.4 is the **only model** to catch the "ommitted" typo (A3).
claude-sonnet-4-6 high catches the most structural issues (A4, A5, A7).

---

## Effort-Accuracy Relationship

| Model | Effect of increasing effort | Pattern |
|---|---|---|
| claude-code | Positive -- balanced-high is top scorer | More effort = deeper analysis |
| claude-sonnet-4-6 | Mixed -- max finds more but adds 1 FP | Peaks at high, slight max degradation |
| gpt-5.4 | Inverse on md2ansi -- medium >= high > max | Max adds FPs, net accuracy drops |
| minimax-m2.7 | Strongly inverse -- max is catastrophic on cln | More effort = more hallucination |
| glm-5.1 | No correlation -- medium is best on md2ansi | Effort does not improve recall |
| qwen3-coder | Max is broken (XML contamination on md2ansi) | Only medium/high are usable |

Models with native reasoning capability (claude-code, claude-sonnet-4-6)
benefit from higher effort because they use the extra token budget for
deeper rule application. All other models show flat or inverse curves --
extra tokens fill with rationalizations, self-contradictions, or
hallucinations.

---

## Suppression Directive Handling

The `#bcscheck disable=BCSxxxx` mechanism is how users document
intentional deviations. A model that ignores these directives wastes
developer time investigating non-issues.

| Model | md2ansi suppressions | cln BCS0806 suppression | Verdict |
|---|---|---|---|
| claude-code | Always honoured | Honoured | Reliable |
| claude-sonnet-4-6 | Always honoured | Correctly analyses scope | Reliable |
| gpt-5.4 | Mostly honoured | Correctly honoured | Reliable |
| minimax-m2.7 | Broken (flagged suppressed rules) | Not tested reliably | Unreliable |
| glm-5.1 | Honoured at max, missed at high | Missed at high, honoured at max | Non-deterministic |
| qwen3-coder | Partially honoured | Missed at medium, honoured at max | Non-deterministic |

---

## Output Integrity

| Model | Issue | Severity |
|---|---|---|
| qwen3-coder max (md2ansi) | Hallucinated `<minimax:tool_call>` XML blocks; no report produced | **Deployment blocker** |
| minimax-m2.7 max (cln) | 4 factually wrong claims about code it was analysing | Critical |
| minimax-m2.7 high (accuracy.sh) | Self-contradicts: claims extglob unused in same output that acknowledges `@(...)` patterns | Critical |
| claude-code high (accuracy.sh) | Claims `#fin` missing when it is present at line 95 | Critical |
| minimax-m2.7 med (accuracy.sh) | Same `#fin` hallucination | Critical |
| glm-5.1 max (which) | 9640 output tokens for zero findings | Wasteful |
| glm-5.1 high (md2ansi) | 12794 output tokens of deliberation for 1 false positive | Wasteful |
| minimax-m2.7 max (md2ansi) | Reasoning trace leaked into output ("Wait...", "Let me re-check...") | Moderate |
| gpt-5.4 (all, which) | Persistent `#end` false positive across all 3 effort levels | Systematic |
| claude-sonnet-4-6 (all) | Self-correction traces ("Retracted -- no finding") inflate output but improve accuracy | Cosmetic |
| gpt-5.4 (all except which) | Clean, terse reports with no reasoning leakage | Best in class |

---

## Combined Rankings

### Best accuracy across all 4 scripts

| Rank | Model | md2ansi | cln | which | accuracy.sh | Avg FPs | Notes |
|---|---|---|---|---|---|---|---|
| 1 | claude-code balanced-high | 5/8 | -- | -- | -- | 0 | Deepest md2ansi analysis (tested on md2ansi only) |
| 2 | claude-sonnet-4-6 medium | 1.5/8 | 4/4 | 3/3 | 2.5/4 | 0--1 | Most consistent across all scripts |
| 3 | claude-sonnet-4-6 high | -- | 3/4 | -- | 3/4 | 0--1 | Best structural findings |
| 4 | gpt-5.4 max | 1.5/8 | -- | 1/3 | 4/4 | 0--2 | Best on accuracy.sh; only typo catcher |
| 5 | gpt-5.4 medium | 2/8 | 4/4 | 0.5/3 | 3/4 | 0--2 | Best speed/quality across all scripts |

### Best speed-to-quality ratio

| Rank | Model | Best script score | Avg time | Notes |
|---|---|---|---|---|
| 1 | gpt-5.4 medium | 4/4 (cln) | 10--18s | Fastest usable check; catches typos |
| 2 | claude-sonnet-4-6 medium | 3/3 (which) | 28--87s | Most reliable across script types |
| 3 | gpt-5.4 high | 2/4 (accuracy.sh) | 9--13s | Fast but FP-prone on dual-purpose scripts |

### Unique strengths by model

| Model | Unique capability | Example |
|---|---|---|
| claude-code | Deepest rule application | Finds function ordering (BCS0107), unused wrappers (BCS0405) |
| claude-sonnet-4-6 | BCS0201 `local --` detection | Only model to find both missing `--` separators in `which` |
| gpt-5.4 | Typo/comment detection | Only model to catch "ommitted" typo (BCS1202) |

### Not viable for BCS checking

| Model | Evidence across 4 scripts |
|---|---|
| minimax-m2.7:cloud | 0/8 md2ansi, 0/4 cln, 0.5/3 which, 0/4 accuracy.sh. Hallucinations at max (4 FPs on cln, claimed `#fin` missing when present). |
| glm-5.1:cloud | 0.5/8 md2ansi, 0/4 cln, 0.5/3 which, 0/4 accuracy.sh. 9640 output tokens for zero findings on which-max. |
| qwen3-coder:480b-cloud | ~0.5/8 md2ansi (XML contamination at max), 0/4 cln, 1/3 which, 1/4 accuracy.sh. Non-deterministic. |

---

## Recommendations

### Tier defaults

The `_detect_backend()` probe order (ollama, anthropic, openai, google,
claude) means the `fast` tier currently routes to minimax/glm/qwen when
an ollama server is running -- producing the worst results in this dataset.

| Tier | Current behaviour | Recommended default | Rationale |
|---|---|---|---|
| `fast` | First reachable ollama model | gpt-5.4-mini at medium | 10--15s, 2/8 md2ansi, 4/4 cln, 0 FP |
| `balanced` | First reachable (varies) | claude-sonnet-4-6 at medium | 28--87s, reliable suppressions, good depth |
| `thorough` | First reachable (varies) | claude-code balanced at high | 524s, 5/8, 0 FP, deepest analysis |

### Detection order

Consider reversing to openai, anthropic, ollama for tier resolution.
This immediately fixes the quality floor by avoiding ollama-cloud models
as tier defaults while preserving them as explicit `--model` choices.

### Effort guidance

- **medium**: Best default for all models. No model tested produces
  worse results at medium than at higher effort.
- **high**: Beneficial only for claude-code and claude-sonnet-4-6.
  Marginal or harmful for all other models.
- **max**: Avoid for ollama-cloud models. Produces hallucinations
  (minimax), broken output (qwen3-coder), or wasted tokens (glm).
  Acceptable for claude-sonnet-4-6 and gpt-5.4 with caveats.

### Hard-refuse rules

| Condition | Action |
|---|---|
| `--effort max` with qwen3-coder | Refuse or downgrade to high (XML contamination risk) |
| `--effort max` with minimax | Warn user about hallucination risk |
| Any ollama-cloud model as tier default | Prefer API backends when available |

---

## Universally Missed Findings

These real issues were missed by **every model at every effort level**
(0/18 or 0/72 detection across all runs):

| Script | Issue | Why it matters |
|---|---|---|
| bcs-check-accuracy.sh | Missing `shift_verbose` and `nullglob` in shopt (BCS0101) | BCS0101 mandates specific shopt options |
| bcs-check-accuracy.sh | Array spacing before closing `)` | Style rule, hard to detect |
| bcs-check-accuracy.sh | Missing spaces in `$((EPOCHSECONDS-start_time))` (BCS1201) | Arithmetic formatting rule |

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

Additionally, some claude-code runs used tier keywords (fast/balanced/thorough)
with effort levels (low/medium/high) for md2ansi only.

Total: 78 reports (42 original + 36 new).

### Ground truth establishment

Ground truth is established by consensus across independent runs.
A finding requires 3+ confirmations from different model/effort
combinations to be classified as a consensus finding. Claude-family
models (claude-code, claude-sonnet-4-6)
provide the primary baseline due to consistently higher recall and
lower false-positive rates.

For `which` and `bcs-check-accuracy.sh`, ground truth was additionally
verified by manual code inspection since fewer baseline runs existed.

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
- Some claude-code runs used tier keywords (fast/balanced/thorough)
  with different effort levels (low/medium/high) than the API runs
  (medium/high/max). Direct effort-level comparison across backends
  is approximate.
- Cost data is not included. Token counts provide a proxy but actual
  API pricing varies by provider and model.
