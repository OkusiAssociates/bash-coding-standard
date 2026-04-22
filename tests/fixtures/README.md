<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# BCS Check Fixtures

Labelled, minimal Bash scripts that each intentionally violate **one**
core-tier BCS rule. Drives `tests/test-check-fixtures.sh`, which asserts
that `bcs check` reports the expected BCS codes.

Turns the `bcs check` prompt from untested prose into a tested
specification: if a refactor of the prompt, the backend selection, or
the tier mapping regresses finding detection, a test will fail.

## Running the suite

```bash
# Runs only if a backend is reachable; otherwise SKIPs gracefully.
./tests/test-check-fixtures.sh

# Force failure when no backend is available (useful in CI that
# provisions API keys from secrets).
BCS_FIXTURES_REQUIRE_BACKEND=1 ./tests/test-check-fixtures.sh

# Skip the whole suite even when a backend is available.
BCS_SKIP_FIXTURES=1 ./tests/test-check-fixtures.sh
```

The harness also runs under `./tests/run-all-tests.sh` and `make test`
via the auto-discovery of `test-*.sh` files.

## Fixture format

Every file under `tests/fixtures/` MUST:

1. Use shebang `#!/usr/bin/env bash` (so the fixture itself parses as
   a real script; only its *body* carries the violation).
2. Carry a **`bcs-fixture-expect:`** pragma in the first 15 lines,
   listing one or more BCS codes separated by whitespace:

   ```bash
   # bcs-fixture-expect: BCS0202
   # bcs-fixture-expect: BCS0503 BCS0903
   ```

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

- **Runtime.** Twenty fixtures at ~10–30s each against a fast model
  takes 2–5 minutes. Acceptable for `make test`, not for
  tight inner-loop iteration; use `BCS_SKIP_FIXTURES=1` during
  development.
- **Backend variance.** Different backends/models produce different
  finding sets. The suite pins model tier `fast` and effort `low` so
  runs are reproducible *enough*; expect the occasional drift when
  model providers retrain.
- **No exact-match mode.** Deliberately — see Assertion model above.

#fin
