<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# BCS Check Fixtures

Labelled, minimal Bash scripts that each intentionally violate **one**
core-tier BCS rule. Drives `tests/test-check-fixtures.sh`, which asserts
that `bcs check` reports the expected BCS codes.

Turns the `bcs check` prompt from untested prose into a tested
specification: if a refactor of the prompt, the backend selection, or
the tier mapping regresses finding detection, a test will fail.

## Layout

```
tests/fixtures/*.sh            gated corpus — one core-rule violation each;
                               test-check-fixtures.sh asserts each is detected
tests/fixtures/probabilistic/  scored-but-not-gated — recommended-tier rules and
                               core rules cheap models catch inconsistently
tests/fixtures/clean/          fully compliant scripts (empty expect pragma);
                               any finding is a false positive
```

The gated corpus holds 33 fixtures and covers every core-tier rule that a
script's text can violate. `clean/` holds three minimal scripts (01-03) and
three realistic ones (04-06) built from the constructs that checkers have
historically mis-flagged: locals assigned well after their declaration,
top-level logic with no functions, a `*)` case arm, argument parsing outside
`main()`, `&& ... ||:` chains, `${SCRIPT_PATH##*/}`, and a present `#fin`.

Only the top-level `*.sh` files form the `test-check-fixtures.sh` recall gate.
The `probabilistic/` and `clean/` subdirectories are read by the accuracy scorer
(`tests/accuracy/bcs-accuracy-score.sh`; see `../accuracy/README.md`). The
"MUST carry a non-empty expect pragma" rule below applies to the gated top-level
fixtures — `clean/` fixtures deliberately carry an *empty* `bcs-fixture-expect:`.

## Running the suite

```bash
# Runs only if a backend is reachable; otherwise SKIPs gracefully.
./tests/test-check-fixtures.sh

# Force failure when no backend is available (useful in CI that
# provisions API keys from secrets).
BCS_FIXTURES_REQUIRE_BACKEND=1 ./tests/test-check-fixtures.sh

# Skip the whole suite even when a backend is available.
BCS_SKIP_FIXTURES=1 ./tests/test-check-fixtures.sh

# Pin the model (skips the probe; the model name selects the backend).
BCS_FIXTURES_MODEL=gpt5-mini ./tests/test-check-fixtures.sh
```

The harness also runs under `./tests/run-all-tests.sh` and `make test-full`
via the auto-discovery of `test-*.sh` files. `make test` (an alias of
`make test-fast`) sets `BCS_SKIP_FIXTURES=1` and never calls an LLM.

## Fixture format

Every file under `tests/fixtures/` MUST:

1. Use shebang `#!/usr/bin/env bash` (so the fixture itself parses as
   a real script; only its *body* carries the violation). The one exception
   is `25-missing-shebang.sh`, whose violation *is* the absent shebang; it
   opens with `# shellcheck shell=bash` so the linter still works.
2. Carry a **`bcs-fixture-expect:`** pragma in the first 15 lines,
   listing one or more BCS codes separated by whitespace:

   ```bash
   # bcs-fixture-expect: BCS0202
   # bcs-fixture-expect: BCS0110 BCS0603
   ```

   Expect the code the standard names as **canonical** for the defect, not
   every rule that mentions it. Where rule text says "cite BCSxxxx, not this
   rule", the fixture expects BCSxxxx alone: expecting the deferring rules too
   rewards citation noise and fails a checker that follows the standard.

3. Carry a **`bcs-fixture-description:`** pragma on its own line
   explaining the intentional violation in plain English:

   ```bash
   # bcs-fixture-description: Function variables not declared local; pollutes global scope.
   ```

4. Demonstrate **one primary violation** from the expected code list.
   Extra violations are tolerated — the harness uses a superset
   assertion — but the fixture must stay minimal enough to keep the
   primary rule visible.

5. End with `#fin` — the fixture body obeys every rule *except* the
   specific rule under test.

6. Stay under ~25 lines of actual code.

## Assertion model

**Superset-only.** A fixture passes if every BCS code named in its
`bcs-fixture-expect:` pragma appears in `bcs check`'s output. Extra
findings are logged as info (`◉ extra findings: ...`) but do not fail
the test.

Rationale: LLM-based checkers are probabilistic. Requiring exact
finding sets produces noisy flap; requiring floor coverage catches the
regressions that matter (the expected rule stopped firing) without
punishing the checker for being thorough.

## Shellcheck compliance

Fixtures must pass `shellcheck -x tests/fixtures/*.sh` even though
they deliberately violate BCS rules. Where a BCS violation overlaps a
shellcheck code (BCS0206/BCS0302/BCS0303/BCS0503/BCS0504), add a
targeted `# shellcheck disable=SC####` directive above the violating
line. The disable silences shellcheck without hiding the anti-pattern
from the BCS LLM checker.

## Adding a new fixture

1. Pick a BCS code. Confirm it exists:

   ```bash
   ./bcs codes -E BCS#### | head -20
   ```

2. Create `tests/fixtures/NN-descriptive-name.sh` (NN = next number,
   zero-padded).
3. Include both pragmas at the top of the body.
4. Keep the violation obvious and the surrounding code well-formed.
5. Verify:

   ```bash
   shellcheck -x tests/fixtures/NN-*.sh
   ./tests/test-check-fixtures.sh   # with a backend
   ```

## Limitations

- **Runtime.** It depends on the backend. The September 2026 audit measured
  about 47 s per fixture on the Claude Code CLI backend, roughly 19 minutes
  for the gated corpus. API backends are far quicker, which is why the probe
  tries them first: `gpt5-mini` at `-e low` ran the then 24 fixtures in 98 s on
  2026-09-17, about 4 s each. Google's free tier allows 20 requests per model per day, fewer
  than one pass of the corpus, so a free-tier key cannot run this gate. Either way it is too slow for the inner loop, so it runs
  under `make test-full`, never under `make test`.
- **Backend variance.** Different backends/models produce different
  finding sets. The suite pins effort `low` and the cheapest alias for
  the reachable backend, probed fastest first (`gpt5-mini` for openai,
  `flash-lite` for google, `haiku` for anthropic, `qwen-small` for
  ollama, `claude-code:haiku` for the Claude CLI; `BCS_FIXTURES_MODEL`
  pins any model and skips the probe) so runs are reproducible *enough*;
  expect the occasional drift when model providers retrain.
- **Inconclusive is not a pass.** A fixture whose check times out, exits
  above 1 (API failure, missing key), or prints nothing is tallied as
  *inconclusive*: neither a finding regression nor a pass. The suite fails
  when every fixture is inconclusive, or when
  `BCS_FIXTURES_REQUIRE_BACKEND=1` and any fixture is. A dead backend can
  therefore never produce a green gate.
- **No exact-match mode.** Deliberately — see Assertion model above.

#fin
