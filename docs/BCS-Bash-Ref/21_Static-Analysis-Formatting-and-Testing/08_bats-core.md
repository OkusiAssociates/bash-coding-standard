<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.8 bats-core

`bats-core` (<https://github.com/bats-core/bats-core>) is the standard
test framework for bash. It parses files with the `.bats` extension,
treats each `@test 'description' { ... }` block as one test case, and
runs them with TAP-compatible output. A test passes when the block
exits zero; failure is any non-zero exit, optionally annotated by
helper assertions from the companion `bats-assert` and `bats-support`
libraries (§21.10).

A complete, runnable test file looks like this — note the strict-mode
preamble belongs in the *script under test*, not the `.bats` file
(bats provides its own error handling):

```bash
#!/usr/bin/env bats
# tests/greet.bats — exercise bin/greet

setup_file() {
  # one-time setup for all tests in this file
  export FIXTURE_DIR
  FIXTURE_DIR="$(mktemp -d)"
  printf 'Alice\n' > "$FIXTURE_DIR/users.txt"
}

teardown_file() {
  rm -rf -- "$FIXTURE_DIR"
}

setup() {
  # runs before every test
  PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
}

@test 'greet prints hello with default name' {
  run greet
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, world!' ]
}

@test 'greet -n NAME prints hello NAME' {
  run greet -n Alice
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, Alice!' ]
}

@test 'greet reads names from file' {
  run greet -f "$FIXTURE_DIR/users.txt"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Hello, Alice!' ]
}

@test 'greet exits 22 on bad option' {
  run greet --no-such-flag
  [ "$status" -eq 22 ]
}
```

Run it from the project root:

```bash
# scenario: run a single test file with TAP output
bats tests/greet.bats
# ⇒  ✓ greet prints hello with default name
#    ✓ greet -n NAME prints hello NAME
#    ...
#    4 tests, 0 failures

# scenario: run an entire suite recursively, parallelised
bats -r --jobs 4 tests/
```

### Lifecycle

| Hook | Runs | Use for |
|------|------|---------|
| `setup_file` | once before any test in the file | expensive fixtures, mock daemons |
| `setup` | before each test | per-test PATH or env tweaks |
| `teardown` | after each test | undo per-test mutations |
| `teardown_file` | once after all tests in the file | tear down expensive fixtures |

`setup_file` runs in a *separate* shell from individual tests; export
anything tests must read (`export FIXTURE_DIR=...`) — plain assignment
will not survive (§21.9).

### `run` and the `$status` / `$output` / `$lines` variables

`run cmd args` invokes the command and *captures* its result rather
than letting it crash the test:

- `$status` — the exit code (always set, including 0)
- `$output` — combined stdout+stderr as a single string
- `$lines[]` — `$output` split on newline
- `$stderr`, `$stderr_lines` — only with `run --separate-stderr`
  (bats-core 1.5+)

Without `run`, a non-zero exit aborts the test on the failing line —
useful when you *want* the test to fail on any unexpected error, but
useless when the assertion is "exit 22 on bad option".

### Editorial conventions

- `.bats` files live under `tests/` and mirror the source layout.
- One file per script under test; one `@test` per behaviour.
- Mock external commands with PATH injection (§21.11), not by editing
  `$PATH` ad-hoc inside each test.
- For richer assertions (`assert_output --partial`, `assert_line -n 0`),
  load `bats-assert` in `setup_file` (§21.10).

**See also**: §21.9 (setup/teardown semantics), §21.10 (assertions),
§21.11 (mocking via PATH), §21.13 (coverage with kcov).

#fin
