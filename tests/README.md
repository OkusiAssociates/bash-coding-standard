# BCS Test Suite

Comprehensive test suite for the `bcs` toolkit covering all 13 subcommands, 8 workflow scripts, and core functionality.

**Statistics:** 34 test files | 600+ tests | 21 assertion types

---

## Test Structure

```
tests/
├── README.md                           # This file
├── run-all-tests.sh                    # Main test runner
├── test-helpers.sh                     # Assertion functions (21 types)
├── coverage.sh                         # Test coverage analyzer
│
├── # Subcommand Tests (13)
├── test-subcommand-about.sh            # bcs about
├── test-subcommand-check.sh            # bcs check (AI-powered)
├── test-subcommand-codes.sh            # bcs codes
├── test-subcommand-compress.sh         # bcs compress (AI-powered)
├── test-subcommand-decode.sh           # bcs decode
├── test-subcommand-default.sh          # bcs default
├── test-subcommand-dispatcher.sh       # Subcommand routing
├── test-subcommand-display.sh          # bcs display
├── test-subcommand-generate.sh         # bcs generate
├── test-subcommand-generate-rulets.sh  # bcs generate-rulets
├── test-subcommand-search.sh           # bcs search
├── test-subcommand-sections.sh         # bcs sections
├── test-subcommand-template.sh         # bcs template
│
├── # Workflow Tests (8)
├── test-workflow-add.sh                # 01-add-rule.sh
├── test-workflow-modify.sh             # 02-modify-rule.sh
├── test-workflow-delete.sh             # 03-delete-rule.sh
├── test-workflow-interrogate.sh        # 04-interrogate-rule.sh
├── test-workflow-compress.sh           # 10-compress-rules.sh
├── test-workflow-generate.sh           # 20-generate-canonical.sh
├── test-workflow-validate.sh           # 30-validate-data.sh
├── test-workflow-check-compliance.sh   # 40-check-compliance.sh
│
├── # Integration & System Tests (7)
├── test-integration.sh                 # Cross-component integration
├── test-execution-modes.sh             # Direct vs sourced execution
├── test-environment.sh                 # Environment conditions
├── test-tier-system.sh                 # Four-tier documentation
├── test-data-structure.sh              # data/ directory validation
├── test-self-compliance.sh             # BCS self-compliance
├── test-get-default-tier.sh            # Default tier detection
│
├── # Core Function Tests (6)
├── test-argument-parsing.sh            # CLI argument handling
├── test-bash-coding-standard.sh        # Legacy compatibility
├── test-bcs-check-alignment.sh         # AI check alignment
├── test-error-handling.sh              # Error handling patterns
└── test-find-bcs-file.sh               # File discovery
```

---

## Running Tests

### Run All Tests

```bash
./tests/run-all-tests.sh
```

### Run Individual Test Suite

```bash
# Subcommand tests
./tests/test-subcommand-display.sh
./tests/test-subcommand-template.sh

# Workflow tests
./tests/test-workflow-validate.sh

# Integration tests
./tests/test-data-structure.sh
```

### Run Test Categories

```bash
# All subcommand tests
for t in tests/test-subcommand-*.sh; do bash "$t"; done

# All workflow tests
for t in tests/test-workflow-*.sh; do bash "$t"; done
```

### Check Coverage

```bash
./tests/coverage.sh
```

---

## Test Categories

### Subcommand Tests (13 files)

Each of the 13 `bcs` subcommands has a dedicated test file:

| Test File | Subcommand | Key Tests |
|-----------|------------|-----------|
| `test-subcommand-display.sh` | `display` | Output formats, viewer detection, legacy options |
| `test-subcommand-about.sh` | `about` | Stats output, JSON format, links |
| `test-subcommand-template.sh` | `template` | 4 template types, placeholders, executable flag |
| `test-subcommand-check.sh` | `check` | AI compliance, formats, filtering (requires Claude) |
| `test-subcommand-compress.sh` | `compress` | Tier generation, size limits (requires Claude) |
| `test-subcommand-codes.sh` | `codes` | Code listing, count verification |
| `test-subcommand-generate.sh` | `generate` | Tier generation, canonical rebuild |
| `test-subcommand-generate-rulets.sh` | `generate-rulets` | Rulet extraction (requires Claude) |
| `test-subcommand-search.sh` | `search` | Pattern matching, context lines |
| `test-subcommand-decode.sh` | `decode` | Code resolution, tier selection, print mode |
| `test-subcommand-sections.sh` | `sections` | Section listing, count verification |
| `test-subcommand-default.sh` | `default` | Tier switching, symlink management |
| `test-subcommand-dispatcher.sh` | (routing) | Command routing, unknown command handling |

### Workflow Tests (8 files)

Tests for the maintenance scripts in `workflows/`:

| Test File | Workflow Script | Purpose |
|-----------|-----------------|---------|
| `test-workflow-add.sh` | `01-add-rule.sh` | Adding new BCS rules |
| `test-workflow-modify.sh` | `02-modify-rule.sh` | Modifying existing rules |
| `test-workflow-delete.sh` | `03-delete-rule.sh` | Deleting rules safely |
| `test-workflow-interrogate.sh` | `04-interrogate-rule.sh` | Rule inspection |
| `test-workflow-compress.sh` | `10-compress-rules.sh` | AI compression |
| `test-workflow-generate.sh` | `20-generate-canonical.sh` | Standard generation |
| `test-workflow-validate.sh` | `30-validate-data.sh` | Data validation (11 checks) |
| `test-workflow-check-compliance.sh` | `40-check-compliance.sh` | Batch compliance |

### Integration Tests (7 files)

Cross-component and system-level tests:

| Test File | Focus |
|-----------|-------|
| `test-integration.sh` | End-to-end workflows |
| `test-execution-modes.sh` | Direct execution vs sourcing |
| `test-environment.sh` | Terminal, paths, I/O handling |
| `test-tier-system.sh` | Four-tier documentation system |
| `test-data-structure.sh` | data/ directory integrity |
| `test-self-compliance.sh` | BCS scripts follow BCS |
| `test-get-default-tier.sh` | Symlink-based tier detection |

### Core Tests (6 files)

Fundamental functionality:

| Test File | Focus |
|-----------|-------|
| `test-argument-parsing.sh` | CLI option parsing, bundling |
| `test-bash-coding-standard.sh` | Legacy symlink compatibility |
| `test-bcs-check-alignment.sh` | AI check consistency |
| `test-error-handling.sh` | Exit codes, error messages |
| `test-find-bcs-file.sh` | FHS path resolution |

---

## Test Helpers

The `test-helpers.sh` library provides 21 assertion functions:

### Basic Assertions
```bash
assert_equals expected actual [test_name]
assert_not_empty value [test_name]
assert_contains haystack needle [test_name]
assert_not_contains haystack needle [test_name]
```

### Exit Code Assertions
```bash
assert_exit_code expected actual [test_name]
assert_success exit_code [test_name]
assert_failure exit_code [test_name]
```

### File Assertions
```bash
assert_file_exists file [test_name]
assert_dir_exists dir [test_name]
assert_file_executable file [test_name]
assert_file_contains file pattern [test_name]
```

### Numeric Assertions
```bash
assert_zero value [test_name]
assert_not_zero value [test_name]
assert_greater_than value threshold [test_name]
assert_less_than value threshold [test_name]
assert_lines_between output min max [test_name]
```

### Pattern Assertions
```bash
assert_regex_match string pattern [test_name]
```

### Organization
```bash
test_section "Section Name"    # Print section header
test_summary                   # Print pass/fail counts
```

### Test Counters
```bash
TESTS_RUN      # Total tests executed
TESTS_PASSED   # Successful tests
TESTS_FAILED   # Failed tests
FAILED_TESTS   # Array of failed test names
```

---

## Writing New Tests

### Template

```bash
#!/usr/bin/env bash
# Test description
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=tests/test-helpers.sh
source "$SCRIPT_DIR"/test-helpers.sh

BCS="$SCRIPT_DIR"/../bcs

test_feature_one() {
  test_section "Feature One Tests"

  local -- output exit_code
  output=$("$BCS" subcommand --option 2>&1) || exit_code=$?

  assert_success "${exit_code:-0}" "Command succeeds"
  assert_contains "$output" "expected" "Output contains expected"
}

test_feature_two() {
  test_section "Feature Two Tests"
  # More tests...
}

# Run all tests
test_feature_one
test_feature_two

test_summary

#fin
```

### Steps

1. Create `test-<category>-<name>.sh` in `tests/`
2. Source `test-helpers.sh`
3. Organize tests into functions with `test_section`
4. Use assertions to verify behavior
5. Call `test_summary` at end
6. Make executable: `chmod +x tests/test-<name>.sh`

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tests passed |
| 1 | One or more tests failed |
| 2 | Test suite error (missing dependencies) |

---

## Requirements

- **Bash 5.2+**
- **ShellCheck** (for self-compliance tests)
- **Claude CLI** (optional, for AI-powered test suites)

---

## AI-Dependent Tests

Some tests require the Claude CLI:

- `test-subcommand-check.sh`
- `test-subcommand-compress.sh`
- `test-subcommand-generate-rulets.sh`
- `test-bcs-check-alignment.sh`
- `test-workflow-compress.sh`
- `test-workflow-check-compliance.sh`

These tests are skipped gracefully when Claude is unavailable.

---

## License

Same license as BCS (CC BY-SA 4.0)

#fin
