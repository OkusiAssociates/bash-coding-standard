<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.9 Bats setup and teardown

The lifecycle hooks.

- `setup_file` — once per file, before any test runs in that file.
- `setup` — before each test.
- `teardown` — after each test (even on failure).
- `teardown_file` — once per file, after all tests.
- Use `setup_file` for expensive shared state (database init, file generation).
- Use `setup` for per-test fixtures.
- Variables set in `setup` are visible in the test; cleared between tests.

```bash
#!/usr/bin/env bats

# scenario: setup_file vs setup — shared vs per-test state

setup_file() {
  # ⇒ runs ONCE per file. Use for expensive read-only fixtures.
  export FIXTURE_DIR
  FIXTURE_DIR="$(mktemp -d)"
  printf 'shared,data\n' >"$FIXTURE_DIR/dataset.csv"
  # build a 100MB test corpus, prime a database, etc.
}

teardown_file() {
  rm -rf -- "$FIXTURE_DIR"
}

setup() {
  # ⇒ runs before EVERY test. Use for per-test mutable state.
  TMP="$(mktemp -d)"
  cp -- "$FIXTURE_DIR/dataset.csv" "$TMP/work.csv"
}

teardown() {
  rm -rf -- "$TMP"
}

@test "first test gets fresh work.csv" {
  echo 'first' >>"$TMP/work.csv"
  run wc -l "$TMP/work.csv"
  [[ "$output" == *"2 "* ]]
}

@test "second test also gets fresh work.csv" {
  # ⇒ TMP is a NEW directory; the 'first' write from the previous test is gone
  run wc -l "$TMP/work.csv"
  [[ "$output" == *"1 "* ]]
}

#fin
```

Key invariants: `FIXTURE_DIR` is built once and shared (must be exported
to be visible inside `@test` blocks); `TMP` is rebuilt per test, so
mutations in one test cannot leak to the next. `teardown` runs even when
the assertion fails, so the cleanup is reliable.

**See also**: §21.8 (bats-core), §21.10 (run/assertions), §21.11 (mocking via PATH).

#fin
