<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.10 Bats `run` and assertions

`run` is the bats primitive that turns a *command invocation* into
*observed evidence*. It executes its argument vector in the current
shell, captures stdout, stderr, and exit code, and stows them in
predictable variables so the test can assert against them. Without
`run`, a non-zero exit halts the test on the offending line; with
`run`, the exit code is data.

```bash
@test 'greet -n NAME exits 0 and prints greeting' {
  run greet -n Alice

  # raw assertions (built-in)
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, Alice!' ]
  [ "${#lines[@]}" -eq 1 ]
}
```

The four state variables `run` populates:

| Variable | Type | Contents |
|----------|------|----------|
| `$status` | integer | exit code of the invoked command |
| `$output` | string | combined stdout+stderr (one buffer) |
| `$lines[]` | array | `$output` split on `\n`, no trailing empties |
| `$stderr` | string | stderr only — *requires* `run --separate-stderr` |
| `$stderr_lines[]` | array | `$stderr` split on `\n` |

Use `run --separate-stderr` (bats-core 1.5+) when the test must
distinguish error messaging from primary output:

```bash
@test 'greet writes errors to stderr' {
  run --separate-stderr greet --no-such-flag
  [ "$status" -eq 22 ]
  [ -z "$output" ]                              # nothing on stdout
  [[ "$stderr" == *'unknown option'* ]]
}
```

### `bats-assert` for richer assertions

The bare `[ ... ]` style is portable but verbose. `bats-assert`
(loaded in `setup_file`) provides assertion helpers that produce
diagnostic output naming the actual vs expected values when they fail:

```bash
setup_file() {
  load '/usr/lib/bats/bats-support/load.bash'
  load '/usr/lib/bats/bats-assert/load.bash'
}

@test 'greet -n NAME with bats-assert' {
  run greet -n Alice
  assert_success
  assert_output 'Hello, Alice!'
}

@test 'greet -f reads each name' {
  printf 'Alice\nBob\n' > "$BATS_TEST_TMPDIR/names.txt"
  run greet -f "$BATS_TEST_TMPDIR/names.txt"
  assert_success
  assert_line --index 0 'Hello, Alice!'
  assert_line --index 1 'Hello, Bob!'
  refute_output --partial 'Charlie'
}

@test 'greet --no-such-flag fails with exit 22' {
  run greet --no-such-flag
  assert_failure 22
  assert_output --partial 'unknown option'
}
```

The most-used helpers, paired with their bare-assertion equivalents:

| `bats-assert` | Bare equivalent |
|---------------|-----------------|
| `assert_success` | `[ "$status" -eq 0 ]` |
| `assert_failure [N]` | `[ "$status" -ne 0 ]` (or `-eq N`) |
| `assert_output STR` | `[ "$output" = "STR" ]` |
| `assert_output --partial S` | `[[ "$output" == *S* ]]` |
| `assert_output --regexp RE` | `[[ "$output" =~ $RE ]]` |
| `assert_line [-n I] STR` | `[ "${lines[I]}" = "STR" ]` |
| `refute_output [...]` | inverse of `assert_output` |
| `assert_equal A B` | `[ "$A" = "$B" ]` |

### `BATS_TEST_TMPDIR` and friends

Tests that need scratch space should use the per-test temporary
directory bats provides — it is created before the test and removed
after, so no `trap` is needed:

| Variable | Lifetime |
|----------|----------|
| `BATS_TEST_TMPDIR` | per-test |
| `BATS_FILE_TMPDIR` | per-file (survives across tests in the same file) |
| `BATS_SUITE_TMPDIR` | per-suite (survives across files in the same `bats -r` run) |

### Custom assertions

Where `bats-assert` is too coarse, write a function that exits non-zero
with a useful message:

```bash
assert_json_field() {
  local -- field=$1 want=$2 got
  got=$(jq -r ".$field" <<<"$output") || return 1
  [[ $got == "$want" ]] || {
    printf 'JSON field %s: want %q, got %q\n' "$field" "$want" "$got" >&2
    return 1
  }
}

@test 'api returns ok status' {
  run curl -s https://example.invalid/api
  assert_success
  assert_json_field status ok
}
```

A failing custom assertion produces its own message on stderr, which
bats relays into the test report — exactly the same shape as the
built-in `assert_*` helpers.

**See also**: §21.8 (bats-core basics), §21.9 (setup/teardown),
§21.11 (PATH-injection mocking), Appendix L (exit codes).

#fin
