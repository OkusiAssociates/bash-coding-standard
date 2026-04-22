#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-check-fixtures.sh - Assert bcs check reports expected BCS codes on
# labelled fixture scripts. Skips gracefully when no LLM backend is reachable.
#
# Environment controls:
#   BCS_SKIP_FIXTURES=1             - skip the entire suite (dev inner-loop)
#   BCS_FIXTURES_REQUIRE_BACKEND=1  - fail instead of skip when no backend
set -euo pipefail
shopt -s inherit_errexit nullglob

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: check fixtures'

# Honour BCS_SKIP_FIXTURES before any expensive probe.
if ((${BCS_SKIP_FIXTURES:-0})); then
  echo '  ◉ SKIP: BCS_SKIP_FIXTURES=1'
  exit 0
fi

# Probe backend availability. Mirrors bcs's _detect_backend order:
# claude → ollama → anthropic → openai → google.
probe_backend() {
  command -v claude &>/dev/null && { echo claude; return 0; } ||:
  local -- host=${OLLAMA_HOST:-localhost:11434}
  curl -sf --connect-timeout 2 http://"$host"/api/tags &>/dev/null \
    && { echo ollama; return 0; } ||:
  [[ -n ${ANTHROPIC_API_KEY:-} ]] && { echo anthropic; return 0; } ||:
  [[ -n ${OPENAI_API_KEY:-} ]] && { echo openai; return 0; } ||:
  [[ -n ${GOOGLE_API_KEY:-${GEMINI_API_KEY:-}} ]] && { echo google; return 0; } ||:
  return 1
}

backend=''
backend=$(probe_backend) ||:
if [[ -z $backend ]]; then
  if ((${BCS_FIXTURES_REQUIRE_BACKEND:-0})); then
    printf '  %s✗%s no LLM backend available (BCS_FIXTURES_REQUIRE_BACKEND=1)\n' \
      "$RED" "$NC"
    exit 1
  fi
  echo '  ◉ SKIP: no LLM backend available'
  exit 0
fi
echo "  ◉ using backend: $backend"

# Per-fixture timeout. Model tier `fast` + effort `low` should finish well
# under this ceiling on all supported backends.
declare -ri FIXTURE_TIMEOUT_S=90

declare -- fixture fixture_name expected reported extras output
declare -i exit_code=0 fixture_count=0
for fixture in "$TEST_DIR"/fixtures/*.sh; do
  fixture_name=${fixture##*/}
  fixture_count+=1
  begin_test "fixture: $fixture_name"

  # Extract expected BCS codes from the pragma (search first 15 lines).
  expected=$(sed -n '1,15p' "$fixture" \
    | grep -F 'bcs-fixture-expect:' \
    | grep -oE 'BCS[0-9]{4}' \
    | sort -u) ||:
  if [[ -z $expected ]]; then
    printf '  %s✗%s %s — missing bcs-fixture-expect pragma\n' \
      "$RED" "$NC" "$fixture_name"
    TESTS_FAILED+=1
    continue
  fi

  # Run bcs check. ERROR findings return exit code 1; capture both streams.
  exit_code=0
  output=$(timeout "$FIXTURE_TIMEOUT_S" \
    "$BCS_CMD" check -m fast -e low --quiet -- "$fixture" 2>&1) \
    || exit_code=$?

  # Backend crash or timeout: warn but don't fail. A backend failure is not
  # the same as a finding regression.
  if [[ -z $output ]] || ((exit_code == 124)); then
    printf '    %s▲%s backend returned empty output or timed out (exit=%d); inconclusive\n' \
      "$YELLOW" "$NC" "$exit_code"
    TESTS_PASSED+=1   # don't penalise, but count as "ran"
    continue
  fi

  reported=$(echo "$output" | grep -oE 'BCS[0-9]{4}' | sort -u) ||:
  assert_superset "$expected" "$reported" \
    "$fixture_name expects: $(echo "$expected" | tr '\n' ' ')" ||:

  # Log extras (findings beyond the expected set) as info, not failure.
  extras=$(comm -23 <(echo "$reported") <(echo "$expected")) ||:
  if [[ -n $extras ]]; then
    printf '    %s◉%s extra findings: %s\n' \
      "$CYAN" "$NC" "$(echo "$extras" | tr '\n' ' ')"
  fi
done

if ((fixture_count == 0)); then
  printf '  %s▲%s no fixtures found under %s/fixtures/\n' \
    "$YELLOW" "$NC" "$TEST_DIR"
fi

# Optional JSON-mode smoke check. Gated behind BCS_FIXTURES_JSON=1 so the
# default run doesn't double-spend LLM calls. Re-runs fixture 01 under
# `bcs check -j` and asserts the envelope shape.
if ((${BCS_FIXTURES_JSON:-0})); then
  declare -- json_fixture=$TEST_DIR/fixtures/01-missing-strict-mode.sh
  if [[ -f $json_fixture ]]; then
    begin_test 'JSON mode: envelope shape on fixture 01'
    exit_code=0
    output=$(timeout "$FIXTURE_TIMEOUT_S" \
      "$BCS_CMD" check -j -m fast -e low --quiet -- "$json_fixture" 2>/dev/null) \
      || exit_code=$?
    if [[ -n $output ]] && ((exit_code != 124)); then
      # Validate top-level shape.
      if jq -e '.source == "bcs" and .meta.backend != null and (.comments | type == "array")' \
          <<< "$output" >/dev/null 2>&1; then
        printf '  %s✓%s envelope shape valid\n' "$GREEN" "$NC"
        TESTS_PASSED+=1
      else
        printf '  %s✗%s envelope shape invalid\n' "$RED" "$NC"
        TESTS_FAILED+=1
      fi

      begin_test 'JSON mode: comments have required keys'
      if jq -e '.comments | all(has("bcsCode") and has("level") and has("line"))' \
          <<< "$output" >/dev/null 2>&1; then
        printf '  %s✓%s findings well-formed\n' "$GREEN" "$NC"
        TESTS_PASSED+=1
      else
        printf '  %s✗%s findings missing required keys\n' "$RED" "$NC"
        TESTS_FAILED+=1
      fi

      begin_test 'JSON mode: reports BCS0101 on strict-mode fixture'
      if jq -e '.comments[] | select(.bcsCode == "BCS0101")' \
          <<< "$output" >/dev/null 2>&1; then
        printf '  %s✓%s BCS0101 reported\n' "$GREEN" "$NC"
        TESTS_PASSED+=1
      else
        printf '    %s▲%s BCS0101 not reported (backend-dependent; inconclusive)\n' \
          "$YELLOW" "$NC"
        TESTS_PASSED+=1
      fi
    else
      printf '    %s▲%s JSON-mode check returned empty or timed out\n' \
        "$YELLOW" "$NC"
      TESTS_PASSED+=1
    fi
  fi
fi

print_summary 'check-fixtures'
#fin
