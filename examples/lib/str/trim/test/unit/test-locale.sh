#!/usr/bin/env bash
# Unit tests for locale sensitivity of [:blank:] character class

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
source "$TEST_DIR/../utils.sh"

# Source all utilities
source "$ROOT_DIR/trim.bash"
source "$ROOT_DIR/ltrim.bash"
source "$ROOT_DIR/rtrim.bash"
source "$ROOT_DIR/squeeze.bash"
source "$ROOT_DIR/trimall.bash"

echo "Testing locale sensitivity..."

declare -i passed=0 failed=0

# Test trim under LC_ALL=C
test_trim_lc_c() {
  local -- result
  result=$(LC_ALL=C trim "  hello world  ")

  if [[ "$result" == "hello world" ]]; then
    echo -e "${GREEN}Test passed${NC}: trim under LC_ALL=C"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: trim under LC_ALL=C (got: ${result@Q})"
    ((++failed))
  fi
}

# Test trim under LC_ALL=en_US.UTF-8 (if available)
test_trim_lc_utf8() {
  if ! locale -a 2>/dev/null | grep -qi 'en_US.utf-\?8'; then
    echo -e "${YELLOW}Skipped${NC}: en_US.UTF-8 locale not available"
    ((++passed))
    return
  fi

  local -- result
  result=$(LC_ALL=en_US.UTF-8 trim "  hello world  ")

  if [[ "$result" == "hello world" ]]; then
    echo -e "${GREEN}Test passed${NC}: trim under LC_ALL=en_US.UTF-8"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: trim under LC_ALL=en_US.UTF-8 (got: ${result@Q})"
    ((++failed))
  fi
}

# Verify [:blank:] does NOT match non-breaking space in any locale
test_nbsp_not_trimmed() {
  local -- nbsp=$'\xc2\xa0'  # UTF-8 encoded U+00A0
  local -- input="${nbsp}hello${nbsp}"

  # Under C locale
  local -- result_c
  result_c=$(LC_ALL=C trim "$input")
  if [[ "$result_c" == "$input" ]]; then
    echo -e "${GREEN}Test passed${NC}: NBSP not trimmed under LC_ALL=C"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: NBSP trimmed under LC_ALL=C (got: ${result_c@Q})"
    ((++failed))
  fi

  # Under UTF-8 locale (if available)
  if locale -a 2>/dev/null | grep -qi 'en_US.utf-\?8'; then
    local -- result_utf8
    result_utf8=$(LC_ALL=en_US.UTF-8 trim "$input")
    if [[ "$result_utf8" == "$input" ]]; then
      echo -e "${GREEN}Test passed${NC}: NBSP not trimmed under LC_ALL=en_US.UTF-8"
      ((++passed))
    else
      echo -e "${RED}Test failed${NC}: NBSP trimmed under en_US.UTF-8 (got: ${result_utf8@Q})"
      ((++failed))
    fi
  fi
}

# Test consistency across locales: C vs UTF-8 produce same results
test_locale_consistency() {
  if ! locale -a 2>/dev/null | grep -qi 'en_US.utf-\?8'; then
    echo -e "${YELLOW}Skipped${NC}: en_US.UTF-8 locale not available"
    ((++passed))
    return
  fi

  local -- input=$'\t  mixed \t whitespace \t  '

  local -- result_c result_utf8
  result_c=$(LC_ALL=C trim "$input")
  result_utf8=$(LC_ALL=en_US.UTF-8 trim "$input")

  if [[ "$result_c" == "$result_utf8" ]]; then
    echo -e "${GREEN}Test passed${NC}: trim produces consistent results across locales"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: locale inconsistency (C: ${result_c@Q}, UTF-8: ${result_utf8@Q})"
    ((++failed))
  fi
}

# Test squeeze under different locales
test_squeeze_locale() {
  local -- input="hello    world"

  local -- result_c
  result_c=$(LC_ALL=C squeeze "$input")

  if [[ "$result_c" == "hello world" ]]; then
    echo -e "${GREEN}Test passed${NC}: squeeze under LC_ALL=C"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: squeeze under LC_ALL=C (got: ${result_c@Q})"
    ((++failed))
  fi
}

# Test trimall under different locales
test_trimall_locale() {
  local -- input="  hello    world  "

  local -- result_c
  result_c=$(LC_ALL=C trimall "$input")

  if [[ "$result_c" == "hello world" ]]; then
    echo -e "${GREEN}Test passed${NC}: trimall under LC_ALL=C"
    ((++passed))
  else
    echo -e "${RED}Test failed${NC}: trimall under LC_ALL=C (got: ${result_c@Q})"
    ((++failed))
  fi
}

# Run all tests
test_trim_lc_c
test_trim_lc_utf8
test_nbsp_not_trimmed
test_locale_consistency
test_squeeze_locale
test_trimall_locale

echo
echo "=== Summary: $passed passed, $failed failed ==="

((failed == 0)) && echo "All locale tests passed!" && exit 0
echo "Locale tests FAILED" && exit 1

#fin
