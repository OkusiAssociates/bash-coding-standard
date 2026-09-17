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

▲ **The `gpt5-mini` / `low` baseline below is superseded and must not be used
as a gate.** It was measured while `bcs check` still sent each fixture's
`bcs-fixture-expect:` / `bcs-fixture-description:` header to the model, so the
model was shown the answer. The same configuration with those lines blanked
(which `bcs check` now always does) scored recall 0.546, clean false positives
51 in 18 runs, stability 0.694, against 1.000 / 0 / 1.000 here. A fresh
baseline has not been taken yet; until it is, there is no valid baseline.

| Alias / effort | Backend | State |
|----------------|---------|-------|
| `gpt5-mini` / `low` | OpenAI | ✓ measured 2026-09-17, `bcs` 2.0.2, 41 fixtures × 3 runs, 506 s. Refreshed the same day after the standard's examples were corrected and fixtures 06 and clean 01-03 changed |
| `flash` / `low` | Google | ✗ not run. The key's free tier allows 20 requests per model per day; one pass of the corpus needs 41 and a baseline needs 123 |
| `haiku` / `low` | Anthropic | ✗ not run. No `ANTHROPIC_API_KEY` on the measuring host |
| `qwen-small` / `low` | Ollama | ✗ not run. No Ollama runs were made; note that the `num_ctx` fix in 2.0.2 has itself not been exercised against a live server |

## Refreshing a baseline

```bash
./tests/accuracy/bcs-accuracy-score.sh -m gpt5-mini -e low -n 3 -o /tmp/score
jq . /tmp/score/accuracy-gpt5-mini-low.json > tests/accuracy/baseline/gpt5-mini_low.json
cp /tmp/score/accuracy-gpt5-mini-low.tsv tests/accuracy/baseline/gpt5-mini_low.tsv
```

Every check the scorer makes passes `--no-cache`, so each repetition is a fresh
LLM round-trip. Refresh only on purpose, in a commit of its own, and say in the
message what changed and why the new numbers are acceptable.

## Comparing a run against a baseline

```bash
jq -n --slurpfile b tests/accuracy/baseline/gpt5-mini_low.json \
      --slurpfile r /tmp/score/accuracy-gpt5-mini-low.json '
  ["recall", "f1", "precision", "clean_fp_rate", "stability"] | map(
    {metric: ., baseline: $b[0][.], run: $r[0][.], delta: ($r[0][.] - $b[0][.])})'
```

Recall and the clean false-positive rate are the trustworthy signals. The
checker is an LLM, so expect run-to-run movement in precision: on 2026-09-17
two runs of the byte-identical configuration gave precision 0.871 and 0.818
(F1 0.931 and 0.900), and the refreshed baseline 0.850 (F1 0.919), with recall
1.000, no clean false positive and stability 1.000 every time. The whole difference was the number of *extra* findings on
violation fixtures (16 against 24). Treat ±0.05 in precision or F1 as noise. A
fall in recall, or any clean false positive, is a regression to explain.
