#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-shims.sh - Tests for bcs<cmd> convenience shims
set -euo pipefail
shopt -s inherit_errexit
#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: shim scripts (bcsdisplay, bcstemplate, bcscodes, bcsgenerate)'

declare -A SHIM_CMDS=(
  [bcsdisplay]='display'
  [bcstemplate]='template'
  [bcscodes]='codes'
  [bcsgenerate]='generate'
)

# Make local bcs reachable to the shims (they exec `bcs ...` via PATH).
export PATH="$PROJECT_DIR:$PATH"

declare -- shim subcmd shim_path body

for shim in "${!SHIM_CMDS[@]}"; do
  subcmd=${SHIM_CMDS[$shim]}
  shim_path="$PROJECT_DIR/$shim"

  begin_test "$shim file exists"
  assert_file_exists "$shim_path" "$shim file exists" || true

  begin_test "$shim is executable"
  if [[ -x $shim_path ]]; then
    printf '  %s✓%s %s is executable\n' "$GREEN" "$NC" "$shim"
    TESTS_PASSED+=1
  else
    printf '  %s✗%s %s is not executable\n' "$RED" "$NC" "$shim"
    TESTS_FAILED+=1
  fi

  begin_test "$shim delegates to 'bcs $subcmd'"
  body=$(< "$shim_path")
  assert_contains "$body" "exec bcs $subcmd " "$shim contains 'exec bcs $subcmd'" || true

  begin_test "$shim passes shellcheck"
  assert_success "$shim shellcheck-clean" shellcheck -x "$shim_path" || true

  begin_test "$shim --help exits 0"
  assert_success "$shim --help" "$shim_path" --help || true

  begin_test "$shim --help mentions '$subcmd'"
  output=$("$shim_path" --help 2>/dev/null || true)
  assert_contains "$output" "$subcmd" "$shim --help mentions $subcmd" || true
done

# Behaviour parity: shim output matches `bcs <cmd>` for a deterministic command.
# Use `codes -p` (plain, no tier decoration, no LLM/network).
begin_test 'bcscodes output matches "bcs codes"'
expected=$("$BCS_CMD" codes -p 2>/dev/null || true)
actual=$("$PROJECT_DIR"/bcscodes -p 2>/dev/null || true)
assert_equal "$expected" "$actual" 'bcscodes -p output identical to bcs codes -p' || true

print_summary 'Shim Tests'
#fin
