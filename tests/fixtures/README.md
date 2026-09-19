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

The gated corpus holds 30 fixtures and covers every core-tier rule that a
script's text can violate, minus three that moved to `probabilistic/` on
2026-09-18 once the fixture pragmas stopped reaching the model: BCS1206 (a
missing justification comment, found 2 of 4), BCS0106 (an executable's own
filename, which the checker never sees, so the fixture can only approximate
it through an `install` line) and BCS1104 (a missing `curl` timeout, filed
as BCS0604 or BCS0408 instead). A fixture belongs in the gate only when the
checker finds it every time. `probabilistic/06` (BCS0602, `die()` defined and
bypassed) and `07` (BCS0704, help printed through a `VERBOSE`-gated `info()`,
so `-q -h` prints nothing) were added on 2026-09-19 because neither rule had a
fixture anywhere, so nothing would have noticed a scope clause that blinded it.
Both were found 9 of 9 (`sonnet -e high`, `haiku` and `gpt5-mini -e medium`,
3 runs each); they sit here, not in the gate, because the gate is for
core-tier rules and these are recommended and style. `clean/` holds three minimal scripts (01-03) and
three realistic ones (04-06) built from the constructs that checkers have
historically mis-flagged: locals assigned well after their declaration,
top-level logic with no functions, a `*)` case arm, argument parsing outside
`main()`, `&& ... ||:` chains, `${SCRIPT_PATH##*/}`, and a present `#fin`.

The gate runs at the default effort (`-e medium`, override with
`BCS_FIXTURES_EFFORT`). It ran at `-e low` until 2026-09-18: with the pragmas
visible that passed 33 of 33, but blind it recalls 0.546 against 0.794 at
medium, so the gate was measuring the leak rather than the checker.

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

   ◉ **The checker never sees either pragma.** `bcs check` blanks every
   `# bcs-fixture-<name>:` line before the script reaches a backend (the line
   stays, empty, so line numbers hold) and the result cache is keyed on that
   blanked text. The pragmas are labels for the harness and for people; they
   cannot help the model. Measured 2026-09-17 on `gpt5-mini -e low`, 41
   fixtures x 3: with the pragmas visible recall was 1.000 and clean false
   positives 0 in 18 runs; blanked, 0.546 and 51. Do not describe the defect
   in a body comment either -- that leaks the same way and is not blanked.

4. Demonstrate **one primary violation** from the expected code list.
   Extra violations are tolerated — the harness uses a superset
   assertion — but the fixture must stay minimal enough to keep the
   primary rule visible.

5. End with `#fin` — the fixture body obeys every rule *except* the
   specific rule under test. In particular, a fixture that runs any
   external command sets `declare -rx PATH=/usr/local/bin:/usr/bin:/bin`
   right after `shopt` (BCS1002); only fixture 13, whose defect that is,
   omits it. Before this, 20 fixtures carried that unlabelled second
   defect and fixture 13 was indistinguishable from them (0 of 3 found
   blind; 3 of 3 once it was the only one).

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

## One defect, and the traps that hide it

A fixture carries exactly one planted defect, and the checker must be able to
see it. Three ways that goes wrong, all measured on fixture 31 (BCS1005) on
2026-09-18, three backends x three runs:

- **A second real defect competes.** The fixture printed `Purged %s` to stdout,
  a status message, which is a genuine BCS0702 violation. All three backends
  reported it and BCS1005 fell to 4 of 9. Removing the message took BCS1005 to
  **9 of 9**. A fixture that fails intermittently is worth re-reading before it
  is reclassified: the checker may be right about something you did not plant.
- **A nearby validation reads as *the* validation.** `local -- name=${1:?usage}`
  checks the argument is non-empty, and that appears to satisfy "validate your
  input" even though nothing validates the *path*. The same trap caught a
  comment in an earlier fixture that said the value was checked above: 3 of 3
  to 1 of 3. State no reassurance the defect does not deserve.
- **Half a rule obeyed in plain sight.** BCS1005 asks both for validation and
  for `--` before pathname operands. `rm -rf -- "$base/$name"` honours the
  second clause visibly. This was the first suspect and measurement did not
  support it -- the fixture still keeps its `--` and now scores 9 of 9 -- but
  it is worth watching in rules that carry several clauses.

Known and accepted on fixture 31: with the argument check gone, `sonnet`
reports **BCS0803** (argument validation) in about two runs of three. That is a
real finding. The obvious fix, adding a presence check, is exactly the second
trap above, so the fixture keeps the extra rather than trading a reliable
BCS1005 for an unreliable one. The gate's assertion is a superset, so an extra
finding never fails it.

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
