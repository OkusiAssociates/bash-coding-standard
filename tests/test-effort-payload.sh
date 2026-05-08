#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-effort-payload.sh - Verify effort -> API parameter wiring
#
# We source bcs (source guard keeps main() from running) and mock `curl` so
# every _llm_* call captures its outgoing JSON payload to a known file. We
# never actually contact a remote API, so this suite is hermetic and runs
# regardless of whether keys are set.
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source=../bcs disable=SC1091
source "$BCS_CMD"

echo 'Testing: effort -> API parameter wiring'

# ---------------------------------------------------------------------
# Mock curl: read stdin via -d @-, dump body to $PAYLOAD_FILE, then emit
# a minimal "successful" response that satisfies each backend's parser
# (jq -r '.content[0].text', '.choices[0].message.content',
# '.candidates[0].content.parts[0].text', '.message.content') plus a
# trailing HTTP code so the API-failure check passes.
# ---------------------------------------------------------------------
PAYLOAD_FILE=$(mktemp /tmp/bcs-payload.XXXXXX)
trap 'rm -f "$PAYLOAD_FILE"' EXIT

curl() {
  local -- arg body=''
  for arg in "$@"; do
    if [[ $body == '__pending__' ]]; then
      [[ $arg == '@-' ]] && body=$(cat) || body=$arg
      break
    fi
    [[ $arg == '-d' ]] && body='__pending__' ||:
  done
  printf '%s' "$body" > "$PAYLOAD_FILE"
  printf '%s\n200\n' '{"content":[{"text":"[]"}],
                       "choices":[{"message":{"content":"[]"}}],
                       "candidates":[{"content":{"parts":[{"text":"[]"}]}}],
                       "message":{"content":"[]"},
                       "usage":{"input_tokens":1,"output_tokens":1,
                                "prompt_tokens":1,"completion_tokens":1},
                       "usageMetadata":{"promptTokenCount":1,
                                        "candidatesTokenCount":1},
                       "prompt_eval_count":1,"eval_count":1}'
}
export -f curl

# Required env so _llm_* don't bail on key absence.
export ANTHROPIC_API_KEY=test-anthropic
export OPENAI_API_KEY=test-openai
export GOOGLE_API_KEY=test-google

# Suppress info noise from inner calls. Read by bcs's own messaging
# helpers via the sourced script; not unused here.
# shellcheck disable=SC2034
VERBOSE=0

# ---------------------------------------------------------------------
# Helpers: invoke a backend, then assert the captured payload matches a jq
# filter (truthy) or does NOT match (falsy).
# ---------------------------------------------------------------------
run_backend() {
  local -- backend=$1 model=$2 effort=$3
  : > "$PAYLOAD_FILE"
  case $backend in
    anthropic) _llm_anthropic "$model" "$effort" 'sys' 'usr' >/dev/null ;;
    openai)    _llm_openai    "$model" "$effort" 'sys' 'usr' >/dev/null ;;
    google)    _llm_google    "$model" "$effort" 'sys' 'usr' >/dev/null ;;
    ollama)    _llm_ollama    "$model" "$effort" 'sys' 'usr' >/dev/null ;;
  esac
}

# Pretty-print payload truncated to 400 chars on failure for debug.
_dump_payload() { head -c 400 "$PAYLOAD_FILE"; echo; }

assert_payload_match() {
  local -- backend=$1 model=$2 effort=$3 jq_filter=$4 msg=$5
  begin_test "$msg"
  run_backend "$backend" "$model" "$effort"
  if jq -e "$jq_filter" "$PAYLOAD_FILE" &>/dev/null; then
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
  else
    printf '  %s✗%s %s\n' "$RED" "$NC" "$msg"
    printf '    filter: %s\n' "$jq_filter"
    printf '    payload: '; _dump_payload
    TESTS_FAILED+=1
  fi
}

assert_payload_no_match() {
  local -- backend=$1 model=$2 effort=$3 jq_filter=$4 msg=$5
  begin_test "$msg"
  run_backend "$backend" "$model" "$effort"
  if jq -e "$jq_filter" "$PAYLOAD_FILE" &>/dev/null; then
    printf '  %s✗%s %s (filter unexpectedly matched)\n' "$RED" "$NC" "$msg"
    printf '    filter: %s\n' "$jq_filter"
    printf '    payload: '; _dump_payload
    TESTS_FAILED+=1
  else
    printf '  %s✓%s %s\n' "$GREEN" "$NC" "$msg"
    TESTS_PASSED+=1
  fi
}

# ---------------------------------------------------------------------
# Anthropic: thinking.budget_tokens auto-enabled on opus + sonnet-4-6/4-7,
# silently omitted on haiku. Both fields (type + budget_tokens) required.
# ---------------------------------------------------------------------
assert_payload_match anthropic claude-opus-4-7 high \
  '.thinking.type == "enabled" and .thinking.budget_tokens == 6000' \
  'opus -e high -> thinking.budget_tokens=6000, type=enabled'

assert_payload_match anthropic claude-opus-4-7 xhigh \
  '.thinking.type == "enabled" and .thinking.budget_tokens == 12000' \
  'opus -e xhigh -> thinking.budget_tokens=12000, type=enabled'

assert_payload_no_match anthropic claude-opus-4-7 low \
  '.thinking != null' \
  'opus -e low -> thinking field omitted (budget=0)'

assert_payload_no_match anthropic claude-haiku-4-5 max \
  '.thinking != null' \
  'haiku -e max -> thinking field omitted (not in gating regex)'

assert_payload_match anthropic claude-sonnet-4-6 medium \
  '.thinking.type == "enabled" and .thinking.budget_tokens == 2000' \
  'sonnet-4-6 -e medium -> thinking.budget_tokens=2000'

# ---------------------------------------------------------------------
# OpenAI: reasoning_effort auto-enabled on gpt-5* and o[0-9]*; omitted
# on gpt-4*/gpt-4.1*/gpt-4o*.
# ---------------------------------------------------------------------
assert_payload_match openai gpt-5 high \
  '.reasoning_effort == "medium"' \
  'gpt-5 -e high -> reasoning_effort=medium'

assert_payload_match openai gpt-5 xhigh \
  '.reasoning_effort == "high"' \
  'gpt-5 -e xhigh -> reasoning_effort=high (saturates)'

assert_payload_match openai o3-mini max \
  '.reasoning_effort == "high"' \
  'o3-mini -e max -> reasoning_effort=high'

assert_payload_no_match openai gpt-4.1-mini high \
  '.reasoning_effort != null' \
  'gpt-4.1-mini -e high -> reasoning_effort omitted'

assert_payload_no_match openai gpt-4o-mini max \
  '.reasoning_effort != null' \
  'gpt-4o-mini -e max -> reasoning_effort omitted'

# ---------------------------------------------------------------------
# Google: thinkingConfig.thinkingBudget auto-enabled on *-2.5-* except
# flash-lite.
# ---------------------------------------------------------------------
assert_payload_match google gemini-2.5-pro high \
  '.generationConfig.thinkingConfig.thinkingBudget == 6000' \
  'gemini-2.5-pro -e high -> thinkingConfig.thinkingBudget=6000'

assert_payload_match google gemini-2.5-pro xhigh \
  '.generationConfig.thinkingConfig.thinkingBudget == 12000' \
  'gemini-2.5-pro -e xhigh -> thinkingConfig.thinkingBudget=12000'

assert_payload_no_match google gemini-2.5-flash-lite high \
  '.generationConfig.thinkingConfig != null' \
  'gemini-2.5-flash-lite -e high -> thinkingConfig omitted'

assert_payload_no_match google gemini-2.5-pro low \
  '.generationConfig.thinkingConfig != null' \
  'gemini-2.5-pro -e low -> thinkingConfig omitted (budget=0)'

# ---------------------------------------------------------------------
# Token budgets (max output) reach every payload regardless of model.
# ---------------------------------------------------------------------
assert_payload_match anthropic claude-haiku-4-5 medium \
  '.max_tokens == 8000' \
  'anthropic max_tokens follows EFFORT_TOKENS[medium]=8000'

assert_payload_match openai gpt-4o medium \
  '.max_completion_tokens == 8000' \
  'openai max_completion_tokens follows EFFORT_TOKENS[medium]=8000'

assert_payload_match google gemini-2.5-flash-lite high \
  '.generationConfig.maxOutputTokens == 24000' \
  'google maxOutputTokens follows EFFORT_TOKENS[high]=24000'

assert_payload_match google gemini-2.5-flash-lite xhigh \
  '.generationConfig.maxOutputTokens == 40000' \
  'google maxOutputTokens follows EFFORT_TOKENS[xhigh]=40000'

assert_payload_match anthropic claude-haiku-4-5 xhigh \
  '.max_tokens == 40000' \
  'anthropic max_tokens follows EFFORT_TOKENS[xhigh]=40000'

assert_payload_match openai gpt-4o xhigh \
  '.max_completion_tokens == 40000' \
  'openai max_completion_tokens follows EFFORT_TOKENS[xhigh]=40000'

print_summary 'effort-payload'
#fin
