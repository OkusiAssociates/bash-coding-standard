<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# BCS Check Accuracy Tooling

Two tools live here, with different jobs:

| Tool | Job |
|------|-----|
| `bcs-check-accuracy.sh` | **Collector.** Runs `bcs check` over sample scripts across many model×effort combinations and dumps the raw markdown output for eyeballing. No ground truth, no score. |
| `bcs-accuracy-score.sh` | **Scorer.** Runs `bcs check -j` over the *labelled* fixture corpus, compares findings against each fixture's `bcs-fixture-expect:` pragma, and computes precision / recall / F1 (aggregate + per-rule) plus a run-to-run **stability** score. |

The scorer is what turns "the LLM checker is non-deterministic and we hope it's
accurate" into numbers.

## Why a scorer

`bcs check` is the project's flagship, and it is an LLM grader: non-deterministic,
with no previously-quantified accuracy. `bcs-accuracy-score.sh` measures three
things the project used to only assume:

- **Recall** — of the violations we *planted* (the fixtures), how many does the
  checker catch? Measured on `tests/fixtures/*.sh` + `tests/fixtures/probabilistic/*.sh`.
- **Precision / false positives** — on fully-compliant scripts (`tests/fixtures/clean/*.sh`),
  *any* finding is a false positive. This is the trustworthy precision signal.
- **Stability** — re-running each fixture N times, how often does a given rule
  flip between reported and missed? A stability score below `1.0` quantifies the
  non-determinism directly.

## The corpus

```
tests/fixtures/*.sh              violation fixtures, one core rule each (also the
                                 recall gate for tests/test-check-fixtures.sh)
tests/fixtures/probabilistic/*.sh  scored, but NOT in the hard recall gate —
                                 detection is probabilistic on cheap models. Holds
                                 recommended-tier rules (BCS0210, BCS0507) and core
                                 rules cheap models inconsistently catch (BCS1104:
                                 flash-lite flags it, claude-haiku misses it — a
                                 concrete backend-variance datum).
tests/fixtures/clean/*.sh        fully BCS-compliant scripts; expected findings = none.
```

The scorer reads all three. `tests/test-check-fixtures.sh` reads only the
top-level `*.sh` (its superset assertion would hard-fail on the variance of the
`probabilistic/` fixtures and on the empty-pragma `clean/` fixtures).

Expected codes come from the same `# bcs-fixture-expect: BCSdddd ...` pragma the
fixture harness uses (see `../fixtures/README.md`). A fixture with an empty
pragma — or any fixture under `clean/` — expects zero findings.

## Running

```bash
# Whole corpus, cheapest reachable backend, 3 runs each (default).
./tests/accuracy/bcs-accuracy-score.sh

# Pin a model and effort; 5 runs for a tighter stability estimate.
./tests/accuracy/bcs-accuracy-score.sh -m flash-lite -e low -n 5

# Score just a subset (fast smoke).
./tests/accuracy/bcs-accuracy-score.sh tests/fixtures/01-*.sh tests/fixtures/clean/01-*.sh
```

Backend selection mirrors `tests/test-check-fixtures.sh`: sniff order
`claude → ollama → anthropic → openai → google`, picking the cheapest alias for
whichever is reachable (`claude-code:haiku` / `qwen-small` / `haiku` /
`gpt5-mini` / `flash-lite`). With no backend reachable it **skips gracefully**
(exit 0); set `BCS_FIXTURES_REQUIRE_BACKEND=1` to fail instead.

### Environment / flags

| Flag | Env | Default | Meaning |
|------|-----|---------|---------|
| `-m MODEL` | `BCS_SCORE_MODEL` | (sniffed) | model alias/id; pinning skips the backend sniff |
| `-e EFFORT` | `BCS_SCORE_EFFORT` | `low` | effort level |
| `-n N` | `BCS_SCORE_RUNS` | `3` | repetitions per fixture (stability) |
| `-o DIR` | `BCS_SCORE_OUTDIR` | this dir | report output directory |
| — | `BCS_SCORE_TIMEOUT` | `150` | per-check timeout (seconds) |
| — | `BCS_FIXTURES_REQUIRE_BACKEND` | `0` | fail (not skip) when no backend |

## Output

Two files per `<model>-<effort>` run, in the output dir:

- `accuracy-<model>-<effort>.tsv` — one row per expected `(fixture, code)`:
  `fixture  code  runs  hits  hitrate  stable`.
- `accuracy-<model>-<effort>.md` — aggregate precision/recall/F1, clean-fixture
  false-positive rate, stability score, and a per-rule recall table.

## Reading the numbers honestly

- **Recall** (on violation fixtures) and the **clean false-positive rate** are
  the trustworthy signals.
- The **aggregate precision** counts every "extra" finding on a violation
  fixture as a false positive — but extras are often *real* secondary issues, so
  aggregate precision understates true precision. Read precision off the clean
  fixtures.
- A run with empty/timed-out backend output is logged **inconclusive** and
  excluded from scoring (not counted as a miss) so a flaky backend doesn't
  masquerade as a recall regression.

## Cost / latency

Each fixture-run is one `bcs check` LLM call (seconds to minutes by backend).
The full corpus at `-n 3` is dozens of calls — fine on demand, not in the inner
loop. CI runs it only via the manual `accuracy.yml` workflow when a backend
secret is configured; the default test suite never calls an LLM.

#fin
