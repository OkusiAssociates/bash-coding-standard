# BCS Check LLM Accuracy Report

Comparative analysis of LLM backends for `bcs check` compliance auditing.
Tested 2026-04-17 (refresh; original 2026-04-12) against four scripts of
varying complexity and structure.

> **Status, 2026-09-17.** Everything below the "Scorer Baseline" section is the
> April 2026 study, kept as a historical record: a hand-scored, qualitative
> comparison on four real scripts. Three things in it no longer describe
> `bcs`:
>
> - the `-m` values `claude`, `fast`, `balanced` and `thorough` were retired
>   (they now exit 22); models are named by alias or canonical ID, and the
>   backend is resolved from the model name, with no probe and no tiers;
> - `gpt-5.4` and `glm-5.1:cloud` are not in the alias map, and the twelve
>   `glm-5.1:cloud` reports, which held only an HTTP 403 message, have been
>   removed from this directory;
> - it never measured the alias and effort the fixture gate actually runs.
>
> The current, reproducible reference is the scorer baseline that follows.
> `bcs-check-accuracy.sh`, the April collector, is left exactly as it was: it
> is also one of the four scored test subjects, typo included.

---

## Corpus repairs verified (2026-09-19, bcs 2.0.8)

Fifteen fixtures were changed in the 2.0.8 round: thirteen carried a second
real defect competing with the planted one, one (24) gained a `--` the widened
BCS1005 now requires, and one (`clean/05`) the same. Re-measured afterwards
with `bcs-accuracy-score.sh -n 3` over exactly those fifteen, JSON mode,
`--no-cache`, 0 inconclusive on both models:

| Metric | `haiku` `-e medium` | `gpt5-mini` `-e medium` |
|--------|--------------------:|------------------------:|
| Recall | 0.857 | 0.881 |
| Precision | **0.973** | 0.698 |
| Stability | 0.857 | 0.929 |
| Spurious findings per clean run | **0.000** | 1.000 |
| False positives, all 45 checks | **1** | 12 |

**Every repaired fixture returns its planted code**, 3 of 3 on both models
except where noted: BCS0206 (03; haiku 2/3), BCS0302 (04), BCS0501 (06),
BCS0504 (07 and 18, 6/6), BCS0606 (19), BCS0702 (09), BCS0901 (11), BCS0902
(12), BCS1001 (24), BCS1101 (21), BCS1103 (32). The two that miss on both are
the two known mechanical cases, both in `probabilistic/`, both unchanged by
this round: BCS0106 (the checker never sees the executable's real filename)
and BCS1104 (recorded as 0 of 9 across three backends since 2026-09-18, still
unexplained; haiku found it 1/3 here).

`haiku` raised **one** extra finding in 45 checks -- BCS0702 once on fixture
18 -- against the pre-repair state, where 14 of the 30 gated fixtures drew an
unexpected code in 2 runs of 2. Its precision of 0.973 on this set, with no
spurious finding on the clean fixture at all, is the strongest evidence that
the corpus repairs did what they were meant to.

### What the per-fixture false-positive map bought

This was the first run with `fp_per_rule.CODE.fixtures`, and it paid for
itself immediately. BCS0411 appeared three times -- twice on fixture 07, once
on 18 -- and those are precisely the two pipe-into-a-loop fixtures. A bare
count would have said "BCS0411 x3" and no more; the map named the files, which
identified it as a fifth ownership pair rather than noise. BCS0906 already
carried a sentence deferring to BCS0504 for that defect; BCS0411 did not, and
now does.

Extras remain, recorded rather than smoothed. `haiku` leaves exactly one
(BCS0702 on fixture 18). `gpt5-mini` leaves twelve, and they are worth reading
as a property of the cheaper model rather than of the corpus, since `haiku`
saw the same files and did not raise them: BCS0702 twice on fixture 06 (whether `echo 'default settings'` is that
script's data or a status message is a judgement call, and the widened BCS0702
scope makes the checker read it as status), BCS0906 twice on fixture 18
despite its deferral sentence, and seven single occurrences spread over seven
distinct rules -- the one-off pattern, not one rule to repair.

---

## Scorer Baseline (2026-09-18)

Produced by `bcs-accuracy-score.sh` over the labelled corpus in
`tests/fixtures/` (30 gated, 5 probabilistic, 6 clean), three repetitions per
fixture, every check run with `--no-cache`. Machine-readable copies are
committed under [`baseline/`](baseline/); see its README for how to refresh one
and how to compare a later run against it.

| Alias / effort | Backend | Conclusive runs | Recall | Precision | F1 | Clean FP | Stability |
|---|---|---|---|---|---|---|---|
| `gpt5-mini` / `medium` | OpenAI | 123 of 123 | **0.895** | 0.566 | 0.694 | **5** in 18 runs | 0.829 |
| `flash` / `medium` | Google | not run | | | | | |
| `haiku` / `medium` | Anthropic | 123 of 123 | **0.829** | 0.770 | 0.798 | **1** in 18 runs | 0.943 |
| `sonnet` / `medium` | Anthropic | 122 of 123 | **0.924** | 0.548 | 0.688 | **17** in 17 runs | 0.943 |
| `qwen-small` / `medium` | Ollama | not run | | | | | |

`flash` was not run because the key's free tier allows 20 requests per model
per day, fewer than one pass of the corpus. `qwen-small` was not run because no
Ollama runs were made.

All three rows were retaken on 2026-09-18 after two corpus defects were fixed
(below). `haiku` (`claude-haiku-4-5`) and `sonnet` (`claude-sonnet-5`) are the
first baselines from a second vendor, and the first independent check the
corpus has had.

| | `haiku` | `gpt5-mini` | `sonnet` |
|---|---|---|---|
| Recall | 0.829 | 0.895 | **0.924** |
| Precision | **0.770** | 0.566 | 0.548 |
| F1 | **0.798** | 0.694 | 0.688 |
| False negatives | 18 | 11 | **8** |
| Total FP | **26** | 72 | 80 |
| Clean FP | **1** in 18 runs | 5 in 18 | 17 in 17 |
| Stability | **0.943** | 0.829 | **0.943** |
| Wall per check | 25 s | **12 s** | 17 s |

They sit on a recall/noise curve: `sonnet` finds the most and says far too
much, `haiku` is much the quietest and misses the most, `gpt5-mini` is between.
Nothing here picks a winner -- it picks a use. `haiku`'s 1 spurious finding in
18 clean runs is what a commit gate wants; `sonnet`'s recall is what a review a
human reads wants.

### What the three disagree about

| Rule | Fixture | `haiku` | `gpt5-mini` | `sonnet` |
|---|---|---|---|---|
| BCS0106 | `probabilistic/04` | 0/3 | 1/3 | 0/3 |
| BCS0507 | `probabilistic/01` | 0/3 | 1/3 | 3/3 |
| BCS1104 | `probabilistic/05` | 0/3 | 0/3 | 0/3 |
| BCS1206 | `probabilistic/03` | 0/3 | 2/3 | 3/3 |
| BCS0801 | `17` (gated) | 0/3 | 2/3 | 3/3 |
| BCS1005 | `31` (gated) | 3/3 | 3/3 | 2/3 |
| BCS0110 | gated | 3/3 | 3/3 | 2/3 |
| BCS0206 | gated | 2/3 | 3/3 | 3/3 |
| BCS0406 | gated | 3/3 | 2/3 | 3/3 |
| BCS0504 | gated | 3/3 | 5/6 | 3/3 |
| BCS1002 | gated | 1/3 | 3/3 | 3/3 |

`sonnet` finds BCS0507 and BCS1206 every time where both cheaper models mostly
miss them, so those two `probabilistic/` fixtures are not ambiguous and their
rule text is not at fault -- they are simply beyond the cheap models, which is
what `probabilistic/` was always meant to mean (see the scorer's header: "core
rules cheap models miss"). **Do not weaken a rule or retire a fixture on a
cheap model's miss alone.**

Two rules defeat every backend:

- **BCS0106**, 1 hit in 9. Mechanical, not difficulty: the rule is about the
  executable's own filename and the checker is handed a copy of the script, so
  it never sees the real name. No model can pass it and no effort setting will
  change that. It is a fixture that cannot be scored, not a hard one.
- **BCS1104**, 0 hits in 9. Before the corpus fixes `sonnet` found it 3/3.
  Unexplained; one 3-run measurement either side is not enough to call it.

### ▲ Two corpus defects were fixed before these numbers (2026-09-18)

**1. The blinding manufactured false positives.** `_checker_script` blanked
each `# bcs-fixture-*:` line rather than deleting it, so reported line numbers
still matched the real file. All 41 fixtures carry exactly two pragma lines, so
every fixture the checker saw had **two consecutive blank lines wedged between
the shebang and `set -euo pipefail`** -- a construct that appears nowhere in
the fixtures as written. BCS1203 (Blank Lines) then fired, correctly, on a
defect the blinding created. It now substitutes a bare `#`, and
`tests/test-checker-prompt.sh` asserts that blinding leaves the blank-line
count unchanged.

▲ **The substitution has its own residue, smaller but not zero.** Two bare `#`
lines are themselves unusual, and `sonnet` reported
`BCS1202 lines 5,6: empty "#" comment lines convey no information` once in a
9-run sample on fixture 31. Like BCS1203 it is `style` tier, so it can never
move an exit code, and at roughly 1 run in 9 against BCS1203's 5 in 8 it is the
better trade -- but the blinding cannot be called invisible. Every option costs
something: a blank line draws BCS1203, a bare comment draws BCS1202, and
deleting the lines outright would break the line numbers the blinding exists to
preserve.

✓ **Closed 2026-09-19 (bcs 2.0.8): the labels left the files.** The fourth
option was not on that list: keep no label in the fixture at all. Expected
codes and descriptions now live in `tests/fixtures/EXPECT.tsv`, the fixtures
lost their two pragma lines, and `_checker_script` left `bcs` -- the script on
disk reaches every backend byte-for-byte (`tests/test-checker-prompt.sh`), and
`tests/test-data-structure.sh` holds the manifest to the files. The Claude CLI
backend still reads a temp-dir *copy*, for a new reason: its agent has
Read/Grep/Glob, and a fixture now sits beside the manifest that names its
defect.

**2. Clean fixture 06 was not clean.** Its `#shellcheck disable=SC2015` carried
no reason, which BCS1206 -- `core`, and tightened the same day -- makes a
finding. Every checker that reported it was right, and the scorer counted it
against them. It surfaced because `sonnet` raised an `[ERROR]` on a fixture
labelled compliant, which is the method note worth keeping: **a false positive
on a clean fixture is a hypothesis about the fixture, not only about the
model.**

What the fixes did, against the superseded rows:

| | `haiku` | `gpt5-mini` | `sonnet` |
|---|---|---|---|
| Recall | 0.876 → 0.829 | 0.905 → 0.895 | 0.962 → 0.924 |
| Precision | 0.482 → **0.770** | 0.594 → 0.566 | 0.362 → **0.548** |
| Total FP | 99 → **26** | 65 → 72 | 176 → **80** |
| Clean FP | 6 → **1** | 5 → 5 | 27 → 17 |

Two results here are worth not smoothing over.

**The fix cut Anthropic's noise and did nothing for OpenAI's.** False positives
fell by three quarters on `haiku` and by more than half on `sonnet`, while
`gpt5-mini` was unmoved (65 → 72, clean FP 5 → 5). The likely reading is that
`gpt5-mini` was largely not reporting the manufactured blank lines in the first
place, so it had nothing to gain. That was an inference, not a measurement: the
scorer counted false positives without recording **which** codes they were, so
the question could not be answered from the committed artefacts. The scorer now
tallies them by code (`fp_per_rule` in the JSON, a "False positives by rule"
table in the report, with the `clean/` share broken out), but the three
baselines above predate it and cannot be made to answer retrospectively. The
first baseline retaken on `bcs` 2.0.4 or later settles it.

**Recall fell on all three.** By 0.047, 0.010 and 0.038 -- small, but the same
direction three times out of three. Removing a defect the checker could find
for free should, if anything, have freed attention for the planted ones. No
mechanism is offered here. Each row is a single 3-run measurement, so this may
still be variance, and it should be watched rather than explained.

### What `gpt5-mini`'s clean-fixture noise is actually made of

First use of the per-code tally, `gpt5-mini -e medium`, the six `clean/`
fixtures x 3 runs (18 clean runs, 2026-09-18, `bcs` 2.0.3):

| Code | Spurious reports | Tier |
|------|-----------------:|------|
| BCS0103 | 1 | recommended |
| BCS0203 | 1 | style |
| BCS0205 | 1 | recommended |
| BCS0301 | 1 | style |
| BCS0403 | 1 | recommended |
| BCS0408 | 1 | recommended |
| BCS0601 | 1 | **core** |

Seven spurious findings, **seven distinct rules, none repeated**. That is a
different diagnosis from the pre-fix pattern, where four of five false errors
on clean files were one rule (BCS0409, whose text was then repaired). There is
no rule to fix here: the residue is one-off misreadings spread thin, and no
edit to the standard will move it.

One of the seven cites **BCS0601, a core rule**, so at least one of these 18
clean runs exited 1 on a compliant file. `-e medium` was chosen over `-e low`
precisely because `low` did that 5 times in 5 on `cln`; `medium` scored 0 in 5
there. This is the first recorded instance of `medium` doing it at all, on a
different corpus and at a far lower rate -- one run in eighteen against five in
five. It does not overturn the effort decision, and it does mean the clean-run
false-`[ERROR]` rate at `medium` is not zero, only small. The scorer records
codes, not exit codes, so which fixture it was is not recoverable from this
run; a rerun that also captured exit status would settle it.

The count (7 in 18) sits above the committed baseline's 5 in 18. Both are
single 3-run samples of the same configuration; the gap is sampling, not a
regression, and is recorded rather than averaged away.

### Where sonnet's false positives actually come from (2026-09-19)

First baseline with `fp_per_rule` (`sonnet -e high`, 41 fixtures x 3). The
noise is not diffuse — it concentrates in a few rules, and the `clean/` column
separates "probably a real secondary defect" from "certainly wrong":

| Code | Reported, not planted | of which on `clean/` | Reading |
|------|----------------------:|---------------------:|---------|
| BCS0806 | 14 | **8** | The largest single source of false alarms on compliant code |
| BCS1005 | 15 | 0 | All on violation fixtures: plausibly real secondary defects |
| BCS0702 | 11 | 0 | As above |
| BCS0602 | 10 | 2 | Mostly on violation fixtures |
| BCS0801 | 6 | **5** | Small but almost entirely wrong |
| BCS0107 | 3 | **3** | Every instance on compliant code |

A finding on a violation fixture may be a genuine defect the fixture never
declared — two such were confirmed and repaired in September 2026 — so the
`clean/` column is the one that indicts a rule. **BCS0806, BCS0801 and BCS0107
are the candidates for a text review**: they fire on code that has nothing
wrong with it. The rules with a zero clean column are not exonerated, but
nothing here shows them misfiring.

This is what the FP-by-code tally was built for. Before it, precision 0.548
was a single number with no way in.

### The three candidates, reviewed (2026-09-19)

`fp_per_rule` says which code misfires but not on which file, so the six
`clean/` fixtures were re-run in JSON mode, 2 reps each, recording fixture
against code. (A first attempt in text mode reproduced nothing: the two modes
use different prompt builders, and the baseline is measured in JSON.)

| Rule | Where it fired | Cause | Repair |
|------|----------------|-------|--------|
| BCS0801 + BCS0806 | `clean/01-03`, 4/6 and 6/6; never on 04-06 | One construct, `if [[ ${1:-} == --version ]]`. BCS0801 had no scope statement, so a single-flag test read as a missing parsing loop; BCS0806's tables read as a checklist, so a script offering only `--version` "omitted" `-V` and `-h` | Scope clauses (user decision): BCS0801 governs a loop where one exists, mandatory from two options or any option-argument, with the 1.0.2 `if`/`elif` anti-pattern restored; BCS0806 is a registry of letter meanings, absence never a finding, reassignment is |
| BCS0107 | `clean/04`, 2/2 | The rule's numbered layers put documentation before helpers; the fixture, the `complete` template and `bcs` itself all put `noarg()` before `show_help()`. The checker read the rule correctly; the rule contradicted its own project | 1.0.2 rationale restored: the binding requirement is dependency order, and layers with no dependency between them may swap |

After the edits: `clean/01`, `02`, `04` clean 2/2 each; fixture 17, the one
fixture that legitimately expects BCS0801 (two options through an `if`/`elif`
chain), still 3/3. BCS0806 had no 1.0.x ancestor -- the 2.x rewrite built it
from letters that 1.0.2 used only to illustrate the dry-run pattern.

The same pass found three more defects in fixtures labelled compliant, each
first reported by the checker as a "false positive": `clean/04` ran `mkdir`
under `DRY_RUN=1` (BCS1208); `clean/03` printed a user path raw (BCS0306) and
returned 1 for file-not-found where BCS0602's table says 3; fixture 17 used
`-f` for a file, a genuine BCS0806 reassignment and a second defect in a
one-defect fixture. With `clean/06` and fixture 31 that is now **six corpus
defects found by treating a false positive as a hypothesis about the
fixture** -- the precision figures in every committed baseline understate the
checker by that much.

Open at the time: BCS0602 fired on fixture 17 in 2 of 3 runs and 10 times in
the `-e high` baseline. Reviewed next.

### BCS0602, reviewed (2026-09-19)

All 41 fixtures were re-run in JSON mode, 2 reps each (82 checks, none
unparsed), recording line and message for every BCS0602 finding. Six findings,
on three fixtures, 2/2 each -- 09, 16 and 17 -- and every message cited the
same construct: a failing `exit N` in a script that defines no `die()`.

The rule opened, unqualified, "Use `die()` as the standard exit function". The
standard's own `# correct` version guard (BCS0409), `bcs` line 16 and the
shipped `bcscheck` wrapper all exit with `{ >&2 echo ...; exit N; }` -- the
guard has to, since it runs above every function. 1.0.2 headed the same
one-liner "Standard implementation" and listed `die 0  # (or use exit 0)`; the
2.x rewrite turned an offered implementation into an order.

BCS0602 now opens with a **Scope** paragraph: it governs which code is
reported and that a failing exit says why; BCS0703 owns whether a script
defines `die()`; where `die()` is defined, a failing exit *below the
definition* that hand-rolls `echo; exit` is the finding; code with no `die()`
to call may exit directly. Two further clauses, each with examples: the message
names the value at fault *when there is one* (`die 18 'curl required'` was
always the standard's own usage), and the table binds only where it names the
failure exactly (3, 18, 22).

That last clause was first written broadly ("use the code the table gives")
and immediately drew a false BCS0602 on `clean/05` for `die 1 "Cannot stat
..."` -- "the table provides 5, I/O error". The standard's own examples write
`die 1` for a failed `mktemp` seven times, so the clause was narrowed and the
`mktemp`/`stat` case added as a `# correct` example.

BCS0602 had no fixture anywhere in the corpus, so nothing would have noticed a
scope clause that blinded it. Four probes built from `clean/03` stood in: a
compliant control and three single-defect variants. Measured on `sonnet -e
high`, JSON mode, 3 reps:

| Subject | Before | After |
|---------|--------|-------|
| fixtures 09, 16, 17 | BCS0602 2/2 each | **0/3 each** |
| fixtures 23, `clean/06` (same construct) | 0/2 | 0/3 |
| `clean/01`-`04`, `06` | -- | no finding of any code, 3/3 |
| `clean/05` | -- | BCS0602 0/3 after the narrowing (1/3 before it) |
| probe: control | -- | BCS0602 0/6 |
| probe: `die()` defined and bypassed | -- | **3/3** |
| probe: `die 1` for a missing file | -- | **3/3** (6/6 over both rounds) |
| probe: `die 3 'File not found'` | -- | 2/3 |

Two more corpus defects surfaced, eight in total: fixture 09 exited 1 for a
missing file and braced `${file}` for no reason (BCS0207, 2/2); fixture 16
exited on a failed `mktemp` without a word. Both repaired. Still open:
fixture 16 draws BCS1005/BCS0604 beside its planted BCS0110 on every run.
`clean/05` and BCS0704 were taken next.

### BCS0704, reviewed (2026-09-19)

`clean/05` drew BCS0704 in 11 of 13 runs across the day, and no other file in
the 82-check run drew it at all. The checker's message located it: line 37,
`-h|--help) echo "Usage: ..."`, "a single inline echo string rather than a
structured heredoc". The rule said, unqualified, "Structure help text with
sections. Use heredoc with `cat`" -- and `bcs template -t basic` answers `-h`
with the same one-line `printf 'Usage: ...'`. 1.0.2 carried only the heredoc
example, with no imperative; the rewrite added the order.

BCS0704 now opens with a **Scope** paragraph: it governs help text longer than
a line; a one-line usage string for a small option set, or no help at all, is
not a finding; the findings are multi-line help assembled from a run of
`echo`/`printf` calls, and help or version sent through a messaging function.
Each has an example. The second is a bug, not taste -- the probe below prints
nothing at all for `-q -h`.

BCS0704 has no fixture either, so two single-defect probes were cut from
`clean/05`. `sonnet -e high`, JSON mode, 3 reps, 18 checks, none unparsed:

| Subject | BCS0704 |
|---------|---------|
| `clean/05` (was 11/13) | **0/3** |
| `clean/04` (heredoc `show_help`) | 0/3, no finding of any code |
| control (`clean/05` without pragmas) | 0/3, no finding of any code |
| `bcs template -t basic` output | 0/3 |
| probe: multi-line help from eight `echo` calls | **3/3** |
| probe: help through a `VERBOSE`-gated `info()` | **3/3** |

The ninth corpus defect came with it: `clean/05` declared `size` with
`local --` and used it in `((size >= MIN_SIZE))` and `total+=$size`; BCS0201's
own example reads `local -i retval=0  # local integer`. The checker had said
so since the first `sonnet` pass (as BCS0201 or BCS0505, 2 runs in 3). Now
`local -i`; gone in 3 of 3.

### Fixture 16, and the two rules with no fixture (2026-09-19)

Fixture 16 (expects BCS0110, no cleanup trap) drew BCS1005 and BCS0604 on
every run. Both were right. `cp /etc/hosts "$TEMP_DIR"/` is a bare file copy,
which BCS0604 names as a violation in so many words, with no `--` before a
variable pathname, which BCS1005 asks for. Worse, the planted defect itself
scored 1 of 3 on `sonnet -e high`: one run returned nothing and one filed the
missing trap under **BCS1006**, whose `# correct` examples all show the trap
while its prose never says who owns a missing one. BCS1006 now owns only how
the temporary name is made; a missing or late trap is BCS0110's, and both rules
say so. Same repair as BCS0303/BCS0507 on the 18th.

The 82-check run shows fixture 16 is the worst case, not the only one:
**fourteen of the thirty gated fixtures** draw some code they do not expect in
2 runs of 2. Two of them shared 16's neighbourhood and were repaired with it:
fixture 08 (expects BCS0604) staged to a hardcoded `/tmp/bcs_fixture_hosts`
-- a genuine BCS1006 -- omitted `--`, and echoed a status line to stdout
(BCS0702, reported by all three models in 9 runs of 9); fixture 15 (expects
BCS1006) had no cleanup trap at all -- a genuine BCS0110 -- and omitted `--`.
Seven real defects across three fixtures in this pass alone, each first
reported by the checker and scored against it.

After, 3 runs each on `sonnet -e high`, `haiku -e medium` and
`gpt5-mini -e medium` -- the last two being what the gate actually runs:

| Fixture | Expected code | Anything else |
|---------|---------------|---------------|
| 08 | BCS0604 **9/9**, both planted lines every time | nothing, 9/9 |
| 15 | BCS1006 **9/9** | BCS0604 once (`gpt5-mini`) |
| 16 | BCS0110 **9/9** (was 1/3 on `sonnet`) | BCS1006 once, three one-off others |
| `probabilistic/06`, new | BCS0602 **9/9** | nothing, 9/9 |
| `probabilistic/07`, new | BCS0704 **9/9** | BCS0305 twice (`gpt5-mini`, and wrong: `"${*:2}"` is one word) |

The other eleven fixtures with a persistent extra code, unexamined: 02
(BCS0201), 03 (BCS0202), 04 (BCS1213), 06 (BCS1202), 11 (BCS1005), 12
(BCS0605), 18 (BCS0605, BCS0906), 19 (BCS0702), 21 (BCS1103), and
`probabilistic/01` (BCS1205) and `/05` (BCS0408). On today's record most will
be real second defects, and each one depresses the precision figure in every
committed baseline. One of 16's one-off extras is worth its own note: BCS1202
for "two consecutive empty `#` comment lines" -- the blinded pragma lines
again, now as bare `#` rather than blanks.

Found on the way, not examined: the `basic` template's output draws BCS0403 in
3 of 3 (`VERBOSE` is never made `readonly` after parsing; neither `basic` nor
`complete` does it, though BCS0804 asks for it), and BCS0405 for the unused
`warn()` and `SCRIPT_DIR`, which a scaffold ships on purpose. `clean/05` drew
BCS1201 once in 3 for the column-aligned body of its `-m` case arm.

### `sonnet` is the default model, and it is the noisy one

▲ `bcs check` defaults to `-m sonnet`, and that configuration raised **17
spurious findings across 17 clean runs** -- one per compliant file, against
0.28 for `gpt5-mini` and **0.06 for `haiku`**. `sonnet` is 17x noisier than
`haiku` on compliant code. Its recall is the best measured (0.924, 8 misses in
122 checks), so this is the expected recall/precision trade rather than a
defect, but it decides how the tool should be used.

Not every spurious finding blocks. In a sampled pass over the six clean
fixtures, `sonnet`'s extra findings were mostly `[WARN]`s -- `show_help`
ordering, help-text structure, an untyped `size` variable -- and only findings
tagged `[ERROR]` promote the exit code. One of the two `[ERROR]`s it did raise
turned out to be correct, and is what exposed the clean-fixture defect above.
Six checks is not a rate; the clean-FP column is the figure to plan against.

**Use a cheaper alias for anything that gates a commit, and keep `sonnet` for a
review a human reads.** On these numbers `haiku` is the gate candidate: 1
spurious finding in 18 clean runs, precision 0.770, at the cost of the lowest
recall of the three.

`sonnet` has now produced an empty completion in both of its runs -- fixture 16
in the first, a clean fixture in the second -- each scored **inconclusive**,
not passed, by the exit-5 empty-completion path. That is 2 in 245 checks; no
other backend has produced one. Worth watching, not yet a pattern.

▲ **Numbers recorded before 2026-09-18 are not comparable with these.** Until
that date `bcs check` sent the whole fixture file to the model, including the
`bcs-fixture-expect:` header naming the rule the fixture plants. The previous
baseline (recall 1.000, clean FP 0, stability 1.000, at `-e low`) therefore
measured how well the checker repeats an answer it was given. `bcs` now blanks
those lines for every backend. Blind on `gpt5-mini`, the same `-e low`
configuration scores recall 0.546 with 51 clean false positives; `-e medium`,
the default and what the table above measures, scores 0.895 with 5.

No gated rule is missed by all three backends, and the seven that flap
(BCS0110, 0206, 0406, 0504, 0801, 1002, 1005) each flap on one backend only,
with the vendor differing per rule. One row therefore understates what the
corpus can detect.

The exception to watch is **BCS0801 on `haiku`: 0/3 here, in JSON mode**, while
the live text-mode gate found it in all 30 of its checks. The gate and the
scorer send different prompts. That is the standing question of whether JSON
mode costs recall, and it is not settled -- both gate runs on record
(`gpt5-mini` and `haiku`, 30/30 each) were made before the corpus fixes, so no
post-fix gate run exists on any backend and none has been run on `sonnet` at
all.

Reading the table: **recall** and the **clean false-positive rate** are the
trustworthy signals. Aggregate precision counts every extra finding on a
violation fixture as a false positive, although most are genuine secondary
issues, so it understates true precision. **Stability** is the share of
expected (fixture, rule) pairs that were reported on either every run or none.

### Fixture gate, post-fix, all three backends (2026-09-18)

`tests/test-check-fixtures.sh` over the 30 gated fixtures, text mode, **one
check per fixture**, at the default `-e medium`:

| Model | Result | Wall | Missed |
|---|---|---|---|
| `gpt5-mini` | ✓ 30/30 | 341 s | -- |
| `sonnet` | ✗ 29/30 | 564 s | fixture 31 (BCS1005) |
| `haiku` | ✗ 28/30 | 640 s | fixture 27 (BCS0406), fixture 31 (BCS1005) |

No inconclusives on any backend, so `sonnet`'s two empty completions did not
recur here.

**This disconfirms the "JSON mode costs recall" hypothesis.** It was raised
because `haiku` scored 0/3 on BCS0801 in the JSON scorer while an older
text-mode gate found it 30/30. Running both modes on the same post-fix corpus,
the discrepancies go in *both* directions:

| Fixture / rule | Model | JSON, 3 runs | Text, 1 run |
|---|---|---|---|
| 17 / BCS0801 | `haiku` | 0/3 | ✓ found |
| 27 / BCS0406 | `haiku` | 3/3 | ✗ missed |
| 31 / BCS1005 | `haiku` | 3/3 | ✗ missed |
| 31 / BCS1005 | `sonnet` | 2/3 | ✗ missed |

A mode that systematically cost recall could not produce the first row. What is
left is per-check variance, which is what an LLM checker is.

### ▲ The gate's own design is the bigger finding

The gate asserts that **one** check finds every planted rule across **30**
fixtures. That is a demanding shape for a probabilistic checker: even at a
genuine 0.99 detection rate per fixture, a run goes red about a quarter of the
time; at 0.95, three runs in four. `gpt5-mini`'s 30/30 is therefore not
evidence that it is better than `sonnet` at 29/30 -- the difference is within
what one sample produces.

So a red gate is not by itself a regression, and a green one is not proof.

**A second run settled it.** With fixture 31 repaired (below) the gate was run
again on both Anthropic backends:

| Run | `haiku` misses | `sonnet` misses |
|---|---|---|
| First | 27 (BCS0406), 31 (BCS1005) | 31 (BCS1005) |
| Second | 03 (BCS0206), 17 (BCS0801) | 08 (BCS0604) |

`haiku`'s two miss sets are **disjoint**: everything it failed the first time it
passed the second, and vice versa. That is sampling noise, not a corpus defect,
and no amount of fixture repair will remove it.

The gate therefore now carries a **failure budget**:
`BCS_FIXTURES_MAX_FAIL`, default 2. Misses within it are named and forgiven;
over it, the suite fails. Both backends are green under it -- `haiku` at 2
misses, `sonnet` at 1 -- with the fixture names still printed, because the
budget forgives a *count*, not an identity. The same fixture missing run after
run is a regression whatever the tally. Set `BCS_FIXTURES_MAX_FAIL=0` to demand
a clean sweep. `tests/test-fixtures-gate.sh` proves the behaviour hermetically
against a stub checker.

**Fixture 31 (BCS1005) was the one result not explained by variance** -- missed
by both Anthropic backends and the chronic flapper in every earlier
measurement. The cause was not the one first proposed. The fixture printed
`Purged %s` to stdout, a status message, which is a real BCS0702 violation:
all three backends reported it, and the fixture had therefore been carrying two
defects while declaring one. Removing the message, and the `${1:?usage}` whose
non-empty check reads as validation of the path, took BCS1005 from 4 of 9 to
**9 of 9** across three backends. It passed both gates above. The first
hypothesis -- that `rm -rf --` visibly honouring the rule's `--` clause
suppressed its validation clause -- was not supported: the `--` is still there.
See `tests/fixtures/README.md` for the fixture-design rules this produced.

### Effort: low against medium (2026-09-17)

Question: can `-e low` become the default? Answer: **no**. `gpt5-mini`, `bcs`
2.0.2 with the output contract; Google, Anthropic and Ollama not measured.

On the labelled corpus the two looked indistinguishable, and low was 2.6 times
quicker:

| Effort | Recall | Clean false positives | Stability | Wall (123 checks) |
|--------|--------|-----------------------|-----------|-------------------|
| `low` | 1.000 | 0 in 18 runs | 1.000 | 457 s |
| `medium` | 1.000 | 8 in 18 runs | 1.000 | 1217 s |

**That comparison was worthless and is kept only as a record of the mistake.**
Both columns read 1.000 because every fixture told the model which rule it
planted. Re-measured blind on 2026-09-18, the two efforts are not close:

| Effort | Recall | Clean false positives | Stability |
|--------|--------|-----------------------|-----------|
| `low` | 0.546 | 51 in 18 runs | 0.694 |
| `medium` | 0.905 | 5 in 18 runs | 0.886 |

The real-script evidence below reached the right answer for the wrong reason:
`low` was blamed on script length, when the corpus simply could not show the
failure because it was leaking the answer.

On real scripts the picture reverses. Five runs each:

| Script | Effort | Avg time | Avg output tokens | False exit 1 | `[ERROR]` per run |
|--------|--------|----------|-------------------|--------------|-------------------|
| `cln` (compliant, 243 lines) | `low` | 4.9 s | 186 | **5 of 5** | 3.8 |
| `cln` | `medium` | 22.3 s | 1624 | 0 of 5 | 0.0 |
| `cln`, CI recipe `--strict -T core` | `low` | 3.7 s | | **5 of 5** | |
| `cln`, CI recipe `--strict -T core` | `medium` | 17.2 s | | 0 of 5 | |
| `which` (111 lines) | `low` | 3.9 s | 159 | | 2-4 codes, little agreement between runs |
| `which` | `medium` | 16.7 s | 1198 | | BCS0109 in 5 of 5 |

At `reasoning_effort=minimal` the model has no budget in which to reject a
candidate finding, so it prints it, sometimes contradicting itself within the
line ("readarray from process substitution is correct but ..."), still tagged
`[ERROR]`. The corpus is blind to this: its scripts run to 17-90 lines.
`medium` therefore stays the default, `tests/test-checker-prompt.sh` pins it,
and the CI guide no longer recommends gating on `low`.

Open follow-up: a `real/` corpus class whose assertion is "no `[ERROR]`",
seeded with `cln`, scored rather than gated (medium is not perfectly quiet
either), so that a later prompt or effort change is measured on real-size
input as well.

---

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

The `-m` values are those in use in April 2026; `claude` and the tier keywords
have since been retired (see the status note above).

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

### Default model

*Rewritten 2026-09-17. The April text recommended per-tier defaults and a
reversed `_detect_backend()` probe order; both the tier keywords and the probe
have since been removed from `bcs`, which made that advice unactionable.*

`bcs check` has one default, the `sonnet` alias, and resolves the backend from
the model name alone. What the April data still supports:

| Need | Choice | April evidence |
|---|---|---|
| Fastest useful answer | `-m gpt5 -e medium` | gpt-5.4: 9--71 s, clean output on most scripts, 2/4 cln and 2/3 which with 0--1 FP |
| Default | `-m sonnet -e medium` | claude-sonnet-4-6: 35--83 s, zero FP across all four scripts, reliable suppression handling |
| Deepest pass | `-m sonnet -e max` | 42--128 s, top scorer on md2ansi (6/10) and accuracy.sh (4/4) |

The one April recommendation that was acted on is the order in which the
*test suite* looks for a backend: `tests/test-check-fixtures.sh` and the scorer
now try API keys first (openai, google, anthropic), then a local Ollama, then
the Claude Code CLI. Ollama cloud models remain an explicit `-m` choice and are
never a default.

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
| `--model glm-5.1:cloud` (any effort) | April: fail fast with an API-error hint. Moot since: the model needs a paid Ollama subscription and its reports were removed |
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
  carry over from the 2026-04-12 baseline and may be stale. The twelve
  error-only report files were removed on 2026-09-17.
- The study never ran `-e low`, nor any of the cheap aliases the fixture
  gate uses. The scorer baseline at the top of this document fills that gap.
- Claude Code CLI backend does not expose token counts, so its rows
  in the token-efficiency table read `--` rather than a number.
- Cost data is not included. Token counts provide a proxy but actual
  API pricing varies by provider and model.
