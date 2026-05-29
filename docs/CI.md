<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Continuous Integration & Local Hooks

How to gate code on BCS in CI and at commit/push time. Two layers:

1. **Fast, free, deterministic** — `shellcheck` + the BCS test suite. Runs on
   every push/PR with no API keys.
2. **Slow, paid, probabilistic** — `bcs check` (the LLM grader). Run it
   deliberately: at pre-push locally, or as a manual CI job.

> ◉ The flagship `bcs check` is an LLM and is non-deterministic. Treat it as a
> reviewer, not a unit test. The repo ships an accuracy scorer
> (`tests/accuracy/bcs-accuracy-score.sh`) precisely so you can measure its
> precision/recall before trusting it as a gate.

## GitHub Actions

### `ci.yml` — push / PR (no secrets)

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) runs on `ubuntu-24.04`
(Bash 5.2) and:

- installs `shellcheck` + `jq`;
- `shellcheck -x` over `bcs`, the shims, every test, every fixture, and the
  accuracy scripts;
- runs `./tests/test-self-compliance.sh` (the "bcs obeys its own standard" invariant);
- runs `./tests/run-all-tests.sh`.

It sets `BCS_SKIP_FIXTURES=1`, so the one LLM-dependent suite
(`test-check-fixtures.sh`) skips cleanly — **no API keys, no cost, no flakiness**.
A fork with zero secrets goes green.

### `accuracy.yml` — manual, secret-gated

[`.github/workflows/accuracy.yml`](../.github/workflows/accuracy.yml) is
`workflow_dispatch` only. Add one of `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, or
`GOOGLE_API_KEY` to the repo secrets, then dispatch it (optionally choosing
model/effort/runs). It runs the scorer over the labelled corpus and uploads the
`accuracy-*.tsv` / `accuracy-*.md` reports as build artifacts. With no backend
secret it fails fast (it is `BCS_FIXTURES_REQUIRE_BACKEND=1`), telling you the
dispatch was misconfigured.

## Local pre-commit hooks

[pre-commit](https://pre-commit.com) wiring. Pair a **fast** shellcheck hook at
the commit stage with the **slow** `bcs check` hook at the push stage.

`.pre-commit-config.yaml` in your project:

```yaml
repos:
  # Fast, deterministic — runs on every commit.
  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.10.0
    hooks:
      - id: shellcheck
        args: [-x]

  # Slow, LLM-graded — runs only on push.
  - repo: https://github.com/Open-Technology-Foundation/bash-coding-standard
    rev: v2.0.1   # pin a tag
    hooks:
      - id: bcs-check        # bcs check --strict --tier core, per changed shell file
        # args: [--model, haiku]   # uncomment to pin a cheap model
```

Install both stages:

```bash
pip install pre-commit          # or: pipx install pre-commit
pre-commit install                              # commit-stage hooks (shellcheck)
pre-commit install --hook-type pre-push         # push-stage hook (bcs-check)
```

Now `shellcheck` runs on each commit, and the BCS LLM gate runs once per push
over the shell files you changed. Requires `bcs` on `PATH` (`sudo make install`)
and a configured backend (`~/.config/bcs/bcs.conf`).

## Backend cost & latency

`bcs check` latency and price depend on backend, model alias, effort, and file
size. Rough per-file figures at `-e low` (your mileage will vary):

| Backend | Cheapest alias | Per-file latency | Cost | Notes |
|---------|----------------|------------------|------|-------|
| Google | `flash-lite` | ~5–10s | very low / free tier | Free tier rate-limits bursts |
| Anthropic | `haiku` | ~5–15s | low | Reliable; needs `ANTHROPIC_API_KEY` |
| OpenAI | `gpt5-mini` | ~10–20s | low | Needs `OPENAI_API_KEY` |
| Ollama | `qwen-small` | ~5–30s | free (local compute) | Quality varies by local model |
| Claude Code CLI | `claude-code:haiku` | ~15–25s | per your Claude plan | No API key; needs `claude` on PATH |

Effort scales latency and cost up sharply: `-e high`/`xhigh`/`max` and larger
models (`sonnet`, `opus`, `gpt5`, `pro`) can take **30–600s** per file. For a
pre-push gate, prefer the cheapest alias at `-e low` and `--tier core` so only
correctness-critical rules block the push.

## Quantify before you trust

Before relying on `bcs check` as a hard gate, measure it on your chosen backend:

```bash
./tests/accuracy/bcs-accuracy-score.sh -m haiku -e low -n 3
```

Read recall (planted-violation detection) and the clean-fixture false-positive
rate from the generated `accuracy-haiku-low.md`. See
[`tests/accuracy/README.md`](../tests/accuracy/README.md).

#fin
