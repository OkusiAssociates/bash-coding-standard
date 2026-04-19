# Trim Utilities Test Suite

A comprehensive test framework for validating the Bash string trim utilities.

## Overview

This test suite ensures the correctness and reliability of all trim utilities through unit tests for individual functions and integration tests for combined usage scenarios. Tests cover basic functionality, edge cases, input/output methods, and command-line options.

## Test Directory Structure

```
./test/
├── run-tests.sh                # Main test runner script
├── utils.sh                    # Common test utilities and assertion functions
├── fixtures/                   # Test data files
│   ├── input/                  # Input test files with various content types
│   ├── expected/               # Expected output files for verification
│   └── tmp/                    # Temporary files created during test execution
├── unit/                       # Individual utility tests
│   ├── test-trim.sh            # Tests for trim utility
│   ├── test-ltrim.sh           # Tests for ltrim utility
│   ├── test-rtrim.sh           # Tests for rtrim utility
│   ├── test-trimv.sh           # Tests for trimv utility
│   ├── test-trimv-advanced.sh  # Advanced trimv scenarios
│   ├── test-trimall.sh         # Tests for trimall utility
│   ├── test-squeeze.sh         # Tests for squeeze utility
│   ├── test-error-handling.sh  # Error handling across all utilities
│   ├── test-unicode.sh         # Unicode and special character handling
│   ├── test-binary-safety.sh   # Binary safety and non-printable characters
│   └── test-line-endings.sh    # Line ending preservation (LF, CRLF, CR)
├── integration/                # Tests for combined usage scenarios
│   ├── test-pipes.sh           # Tests for piping between utilities
│   ├── test-sourced.sh         # Tests for utilities when sourced into scripts
│   └── test-complex-pipelines.sh  # Multi-stage pipeline scenarios
├── security/                   # Security tests
│   └── test-injection.sh       # Command injection prevention
└── stress/                     # Stress and performance tests
    └── test-large-inputs.sh    # Large input handling (100K+ chars, 10K+ lines)
```

## Running the Tests

The test suite supports running all tests or specific categories:

```bash
# Run the complete test suite
./test/run-tests.sh

# Run only unit tests
./test/run-tests.sh unit

# Run only integration tests
./test/run-tests.sh integration
```

## Test Coverage

The test suite provides comprehensive coverage across multiple dimensions:

1. **Core Functionality**
   - Basic whitespace trimming operations for all 6 utilities
   - String and stream processing
   - Command argument handling and option parsing

2. **Edge Cases**
   - Empty strings and input
   - Whitespace-only content
   - Mixed whitespace characters (spaces, tabs)
   - Multiline content, line endings (LF, CRLF, CR)
   - Binary safety and non-printable characters

3. **Features**
   - Escape sequence processing with `-e` flag
   - Variable assignment with `trimv -n`
   - Stream processing via stdin/stdout
   - Unicode preservation (emoji, RTL, combining characters)

4. **Integration Scenarios**
   - Pipeline usage between utilities
   - Sourced function behavior
   - Complex multi-stage pipelines (sort, uniq, grep, wc)

5. **Security**
   - Command injection prevention via variable names
   - Input content safety (command substitution literals)

6. **Stress Testing**
   - Very long lines (100K+ characters)
   - High line counts (10K+ lines)
   - Large whitespace-only inputs

## Test Utilities

The `utils.sh` script provides helper functions for all tests:

| Function | Purpose |
|----------|---------|
| `assert_equals` | Compare two strings and report success/failure |
| `assert_file_equals` | Compare contents of two files with diff reporting |
| `create_temp_file` | Generate temporary file with specified content |
| `create_temp_multiline_file` | Create multiline temp files from stdin |
| `cleanup_temp_files` | Remove temporary test artifacts |

## Adding New Tests

To extend the test coverage:

### Creating a New Unit Test

1. Create a new test script in the `unit/` directory
2. Follow the existing pattern:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   # Source test utilities
   TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
   source "$TEST_DIR/../utils.sh"
   
   # Define test functions
   test_feature_one() {
     # Test implementation
     assert_equals "actual" "expected" "Description"
   }
   
   # Run tests
   test_feature_one
   # Additional tests...
   
   echo "All tests passed!"
   exit 0
   ```
3. Make it executable: `chmod +x test/unit/test-newfeature.sh`

### Creating a New Integration Test

1. Create a script in the `integration/` directory
2. Test interactions between multiple utilities
3. Focus on real-world usage scenarios

### Adding Test Fixtures

For tests requiring input/output files:

1. Add input files to `fixtures/input/`
2. Create corresponding expected output in `fixtures/expected/`
3. Use clear naming that reflects the test purpose
4. Ensure all fixture files end with a newline

## Test Maintenance

When modifying the utilities:

1. Run the full test suite to ensure changes don't break existing functionality
2. Add new tests for any added features or fixed bugs
3. Update expected output files if the intended behavior changes

#fin