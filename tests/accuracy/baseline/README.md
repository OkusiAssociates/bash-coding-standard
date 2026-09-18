<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# Scorer baselines

One committed measurement per gate alias and effort, produced by
`../bcs-accuracy-score.sh` over the labelled corpus in `tests/fixtures/`.
A change to the checker prompt, the standard, or the default effort is judged
against these numbers, not against memory.

| File | What it is |
|------|------------|
| `<alias>_<effort>.json` | Aggregate precision / recall / F1, clean false positives, stability, per-rule recall, plus the `bcs` version, model, effort and run count |
| `<alias>_<effort>.tsv` | Per (fixture, rule) hit-rate over the repetitions |

## Status

| Alias / effort | Backend | State |
|----------------|---------|-------|
| `gpt5-mini` / `medium` | OpenAI | ✓ measured 2026-09-18, `bcs` 2.0.2, 41 fixtures × 3 runs, model `gpt-5-mini` |
| `flash` / `medium` | Google | ✗ not run. The key's free tier allows 20 requests per model per day; one pass of the corpus needs 41 and a baseline needs 123 |
| `haiku` / `medium` | Anthropic | ✓ measured 2026-09-18, `bcs` 2.0.2, 41 fixtures × 3 runs, model `claude-haiku-4-5` |
| `sonnet` / `medium` | Anthropic | ✓ measured 2026-09-18, `bcs` 2.0.2, 41 fixtures × 3 runs, model `claude-sonnet-5`. 122 of 123 scored; 1 inconclusive |
| `qwen-small` / `medium` | Ollama | ✗ not run. No Ollama runs were made; note that the `num_ctx` fix in 2.0.2 has itself not been exercised against a live server |

Each JSON carries both `model` (the alias as typed) and `model_id` (the
canonical ID the checks actually ran against, read back from the checker's own
JSON envelope). Compare on `model_id`: an alias is not portable. On the
measuring host `/etc/bcs.conf` sets `MODEL_ALIASES[sonnet]=claude-sonnet-5`,
while `bcs`'s built-in map says `claude-sonnet-4-6`, so a baseline recording
only `sonnet` could be refreshed elsewhere against a different model under the
same filename.

The earlier `gpt5-mini` / `low` baseline (recall 1.000, clean FP 0, stability
1.000) has been deleted rather than kept for comparison. It was measured while
`bcs check` still sent each fixture's `bcs-fixture-expect:` header to the
model, so it recorded how well the checker reads an answer it was given. The
same configuration blind scored recall 0.546 and 51 clean false positives.
Numbers taken before 2026-09-18 are not comparable with these.

## Refreshing a baseline

```bash
./tests/accuracy/bcs-accuracy-score.sh -m gpt5-mini -e medium -n 3 -o /tmp/score
jq . /tmp/score/accuracy-gpt5-mini-medium.json > tests/accuracy/baseline/gpt5-mini_medium.json
cp /tmp/score/accuracy-gpt5-mini-medium.tsv tests/accuracy/baseline/gpt5-mini_medium.tsv
```

Every check the scorer makes passes `--no-cache`, so each repetition is a fresh
LLM round-trip. Refresh only on purpose, in a commit of its own, and say in the
message what changed and why the new numbers are acceptable.

## Comparing a run against a baseline

```bash
jq -n --slurpfile b tests/accuracy/baseline/gpt5-mini_medium.json \
      --slurpfile r /tmp/score/accuracy-gpt5-mini-medium.json '
  ["recall", "f1", "precision", "clean_fp_rate", "stability"] | map(
    {metric: ., baseline: $b[0][.], run: $r[0][.], delta: ($r[0][.] - $b[0][.])})'
```

Recall and the clean false-positive rate are the trustworthy signals. The
checker is an LLM, so expect run-to-run movement: treat ±0.05 in precision or
F1 as noise. A fall in recall is a regression to explain.

Aggregate precision (0.770 `haiku`, 0.566 `gpt5-mini`, 0.548 `sonnet`)
understates the checker: every *extra* finding on a violation fixture counts as
a false positive, and many are genuine secondary issues the fixture did not
plant. Read it as a verbosity signal, not as accuracy.

The clean false-positive rate is the honest measure of noise, because a clean
fixture has no true finding to report: **1** finding in 18 runs for `haiku`, 5
in 18 for `gpt5-mini`, **17 in 17** for `sonnet`. The three lie on a
recall/noise curve -- `sonnet` has the best recall (0.924) and by far the most
noise, `haiku` the least of both.

Because `sonnet` is `bcs check`'s default model, that last figure is the one to
know: about one spurious finding per compliant file, 17x `haiku`'s rate. Prefer
a cheaper alias for anything that blocks a commit.

All three were retaken on 2026-09-18 after two corpus defects were fixed: the
pragma blinding emptied each `bcs-fixture-*` line instead of substituting a
bare `#`, wedging two consecutive blank lines into every fixture and provoking
a correct BCS1203 finding about a defect no fixture contains; and clean fixture
06 carried a bare `#shellcheck disable=SC2015` with no reason, a real BCS1206
violation the scorer was counting against the checker. **Nothing measured
before 2026-09-18 is comparable with these.** See
[`../LLM-ACCURACY.md`](../LLM-ACCURACY.md) for what the fixes changed.

See [`../LLM-ACCURACY.md`](../LLM-ACCURACY.md) for the per-rule comparison, and
for why a rule that a cheap model misses is not thereby a bad rule.
