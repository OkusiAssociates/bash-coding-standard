#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-check-fixtures.sh - Assert bcs check reports expected BCS codes on
# labelled fixture scripts. Skips gracefully when no LLM backend is reachable.
#
# Environment controls:
#   BCS_SKIP_FIXTURES=1             - skip the entire suite (dev inner-loop)
#   BCS_FIXTURES_REQUIRE_BACKEND=1  - fail instead of skip when no backend, and
#                                     fail when any fixture is inconclusive
#   BCS_FIXTURES_MODEL=<alias|id>   - check with this model; skips the probe,
#                                     the model name selects the backend
#   BCS_FIXTURES_CMD=<path>         - checker to run instead of ./bcs (test seam
#                                     for tests/test-fixtures-gate.sh)
set -euo pipefail
shopt -s inherit_errexit nullglob

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: check fixtures'

declare -r FIXTURES_CMD=${BCS_FIXTURES_CMD:-$BCS_CMD}

# Honour BCS_SKIP_FIXTURES before any expensive probe.
if ((${BCS_SKIP_FIXTURES:-0})); then
  echo '  ◉ SKIP: BCS_SKIP_FIXTURES=1'
  exit 0
fi

# Probe backend availability, fastest first: an API key (openai → google →
# anthropic), then a local Ollama server, then the Claude Code CLI, which
# takes minutes per fixture. bcs itself never probes -- it resolves the
# backend from the model name -- so this order belongs to the test alone.
probe_backend() {
  [[ -n ${OPENAI_API_KEY:-} ]] && { echo openai; return 0; } ||:
  [[ -n ${GOOGLE_API_KEY:-${GEMINI_API_KEY:-}} ]] && { echo google; return 0; } ||:
  [[ -n ${ANTHROPIC_API_KEY:-} ]] && { echo anthropic; return 0; } ||:
  local -- host=${OLLAMA_HOST:-localhost:11434}
  curl -sf --connect-timeout 2 http://"$host"/api/tags &>/dev/null \
    && { echo ollama; return 0; } ||:
  command -v claude &>/dev/null && { echo claude; return 0; } ||:
  return 1
}

declare -- backend=''
if [[ -n ${BCS_FIXTURES_MODEL:-} ]]; then
  backend='(from BCS_FIXTURES_MODEL)'
else
  backend=$(probe_backend) ||:
fi
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

# Pick the cheapest model alias that routes to the probed backend. We avoid
# `-m haiku` for everyone -- haiku alias-expands to claude-haiku-4-5 which
# always routes to anthropic, so an env that only has Claude CLI on PATH (no
# ANTHROPIC_API_KEY) would fail. The claude-code:haiku sentinel keeps the
# Claude CLI path while still asking for the haiku model.
declare -- fixture_model=haiku
case $backend in
  claude)    fixture_model=claude-code:haiku ;;
  ollama)    fixture_model=qwen-small ;;
  openai)    fixture_model=gpt5-mini ;;
  google)    fixture_model=flash-lite ;;
  anthropic) fixture_model=haiku ;;
  *)         fixture_model=$BCS_FIXTURES_MODEL ;;
esac
echo "  ◉ using model:   $fixture_model"

# Per-fixture timeout. The cheapest alias on the chosen backend at effort
# `low` should finish well under this ceiling.
declare -ri FIXTURE_TIMEOUT_S=90

declare -- fixture fixture_name expected reported extras output
declare -i exit_code=0 fixture_count=0 inconclusive=0
declare -ri REQUIRE_BACKEND=${BCS_FIXTURES_REQUIRE_BACKEND:-0}
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
  # $fixture_model was chosen above to match the probed backend so the test
  # works with whatever credentials/CLI the host has.
  exit_code=0
  output=$(timeout "$FIXTURE_TIMEOUT_S" \
    "$FIXTURES_CMD" check --no-cache -m "$fixture_model" -e low --quiet -- "$fixture" 2>&1) \
    || exit_code=$?

  # bcs check exits 0 (clean) or 1 (ERROR findings) when the backend
  # answered. Anything else (5 API failure, 18 missing key, 124 timeout) or
  # an empty answer says nothing about the fixture: inconclusive. That is
  # neither a finding regression nor a pass -- the tally below decides
  # whether the suite as a whole is still trustworthy.
  if [[ -z $output ]] || ((exit_code > 1)); then
    printf '  %s▲%s %s — inconclusive (exit=%d): %s\n' \
      "$YELLOW" "$NC" "$fixture_name" "$exit_code" "${output:-no output}"
    inconclusive+=1
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

# A gate that asserted nothing must not be green: fail when no fixture gave a
# verdict at all, or when a backend was demanded and any fixture lacked one.
if ((inconclusive)); then
  if ((inconclusive == fixture_count)); then
    printf '  %s✗%s %d inconclusive of %d: the backend never answered\n' \
      "$RED" "$NC" "$inconclusive" "$fixture_count"
    TESTS_FAILED+=1
  elif ((REQUIRE_BACKEND)); then
    printf '  %s✗%s %d inconclusive of %d (BCS_FIXTURES_REQUIRE_BACKEND=1)\n' \
      "$RED" "$NC" "$inconclusive" "$fixture_count"
    TESTS_FAILED+=1
  else
    printf '  %s▲%s %d inconclusive of %d (not counted as passed)\n' \
      "$YELLOW" "$NC" "$inconclusive" "$fixture_count"
  fi
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
      "$FIXTURES_CMD" check -j --no-cache -m "$fixture_model" -e low --quiet -- "$json_fixture" 2>/dev/null) \
      || exit_code=$?
    if [[ -n $output ]] && ((exit_code <= 1)); then
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
        printf '    %s▲%s BCS0101 not reported (backend-dependent; not counted as passed)\n' \
          "$YELLOW" "$NC"
      fi
    else
      printf '    %s▲%s JSON-mode check returned empty or timed out (not counted as passed)\n' \
        "$YELLOW" "$NC"
      ((REQUIRE_BACKEND)) && TESTS_FAILED+=1 ||:
    fi
  fi
fi

print_summary 'check-fixtures'
#fin
