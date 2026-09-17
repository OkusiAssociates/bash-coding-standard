#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-check-empty-content.sh - An empty LLM completion is an anomaly, never a pass
#
# A backend that answers HTTP 200 with no text (output budget spent on
# reasoning, safety block, refusal) must end in exit 5 and must not be cached.
# We source bcs and shadow `curl` with a shell function that replays a canned
# body, so every backend code path runs without contacting anything. The API
# keys below are dummies.
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source=../bcs disable=SC1091
source "$BCS_CMD"

echo 'Testing: empty LLM completion handling'

# Per-case state: run_check() fills RC/OUT/ERR; PRE_HOOK names a command run
# inside the check subshell before cmd_check (used to stub a backend).
declare -- SANDBOX='' OUT='' ERR='' PRE_HOOK=:
declare -i RC=0
declare -x MOCK_BODY=''

# Sandbox every path cmd_check writes to (cache, response dump, policy).
trap '[[ -z $SANDBOX ]] || rm -rf -- "$SANDBOX"' EXIT
SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}"/bcs-empty.XXXXXX) \
  || die 1 'Failed to create sandbox directory'
declare -x XDG_CACHE_HOME="$SANDBOX"/cache XDG_STATE_HOME="$SANDBOX"/state \
           XDG_CONFIG_HOME="$SANDBOX"/config BCS_CONF_DIR="$SANDBOX"/conf
mkdir -p "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_CONFIG_HOME" "$BCS_CONF_DIR"
unset BCS_MODEL BCS_EFFORT BCS_STRICT BCS_JSON BCS_CACHE BCS_TIER BCS_MIN_TIER \
      BCS_DEBUG BCS_RESPONSE_DUMP

declare -x ANTHROPIC_API_KEY=test-anthropic OPENAI_API_KEY=test-openai \
           GOOGLE_API_KEY=test-google

# Read by the messaging helpers of the sourced script; not unused here.
# shellcheck disable=SC2034
VERBOSE=0

declare -r FIXTURE="$TEST_DIR"/fixtures/02-undeclared-local.sh

# Mock curl: drain the request body, replay $MOCK_BODY plus the HTTP code
# trailer that the backends split off.
curl() {
  cat >/dev/null ||:
  printf '%s\n200\n' "$MOCK_BODY"
}
declare -fx curl

# Canned bodies: HTTP 200, well-formed, no text.
declare -r OPENAI_EMPTY='{"choices":[{"message":{"role":"assistant"},"finish_reason":"length"}],
  "usage":{"prompt_tokens":31000,"completion_tokens":0}}'
declare -r GOOGLE_EMPTY='{"candidates":[{"content":{"role":"model"},"finishReason":"SAFETY"}],
  "usageMetadata":{"promptTokenCount":31000,"candidatesTokenCount":0}}'
declare -r ANTHROPIC_EMPTY='{"content":[{"type":"thinking","thinking":"..."}],
  "usage":{"input_tokens":31000,"output_tokens":5}}'
declare -r OLLAMA_EMPTY='{"message":{"role":"assistant","content":""},
  "prompt_eval_count":31000,"eval_count":0}'
declare -r FINDING='[WARN] BCS0202 line 8: variable not declared local'
declare -r OPENAI_OK='{"choices":[{"message":{"content":"[WARN] BCS0202 line 8: variable not declared local"},
  "finish_reason":"stop"}],"usage":{"prompt_tokens":31000,"completion_tokens":20}}'
declare -r GOOGLE_MULTIPART='{"candidates":[{"content":{"parts":[
  {"text":"[WARN] BCS0202 line 8: "},{"text":"variable not declared local"}]},
  "finishReason":"STOP"}],
  "usageMetadata":{"promptTokenCount":31000,"candidatesTokenCount":20}}'

# run_check BODY [cmd_check args...]
# cmd_check runs in a subshell because die() exits. The subshell is a
# background job so that errexit stays live inside it, as in production: a
# `( ... ) || RC=$?` list would switch errexit off for everything it runs.
run_check() {
  local -i pid
  MOCK_BODY=$1; shift
  RC=0
  ( "$PRE_HOOK"; cmd_check --no-shellcheck "$@" "$FIXTURE" ) \
    >"$SANDBOX"/out 2>"$SANDBOX"/err &
  pid=$!
  wait "$pid" || RC=$?
  OUT=$(< "$SANDBOX"/out)
  ERR=$(< "$SANDBOX"/err)
}

# Replaces the OpenAI backend with one that emits only the token sentinel.
stub_openai_orphan() {
  # Invoked indirectly, by cmd_check's backend dispatch.
  #shellcheck disable=SC2329
  _llm_openai() { echo '___TOKENS___ in=1 out=0'; }
}

reset_cache() { rm -rf -- "$XDG_CACHE_HOME"/bcs; }
cache_count() { find "$XDG_CACHE_HOME" -type f | wc -l; }

# 1. OpenAI: no message.content (reasoning consumed the output budget)
begin_test 'openai empty completion'
reset_cache
run_check "$OPENAI_EMPTY" -m gpt-5
assert_equal 5 "$RC" 'openai empty -> exit 5' ||:
assert_not_contains "$OUT" '___TOKENS___' 'openai empty -> no sentinel on stdout' ||:
assert_equal 0 "$(cache_count)" 'openai empty -> nothing cached' ||:
assert_contains "$ERR" 'finish_reason=length' 'openai empty -> finish reason reported' ||:

# 2. Google: candidate without parts (safety block)
begin_test 'google empty completion'
reset_cache
run_check "$GOOGLE_EMPTY" -m gemini-2.5-flash
assert_equal 5 "$RC" 'google empty -> exit 5' ||:
assert_not_contains "$OUT" '___TOKENS___' 'google empty -> no sentinel on stdout' ||:
assert_equal 0 "$(cache_count)" 'google empty -> nothing cached' ||:
assert_contains "$ERR" 'SAFETY' 'google empty -> finish reason reported' ||:

# 3. A second identical run must not be served a poisoned cache entry
begin_test 'openai empty completion, second run'
reset_cache
run_check "$OPENAI_EMPTY" -m gpt-5
run_check "$OPENAI_EMPTY" -m gpt-5
assert_equal 5 "$RC" 'openai empty, second run -> still exit 5' ||:

# 4. JSON mode: exit 5 with a parseable empty envelope
begin_test 'openai empty completion, JSON mode'
reset_cache
run_check "$OPENAI_EMPTY" -m gpt-5 -j
assert_equal 5 "$RC" 'openai empty -j -> exit 5' ||:
assert_equal '0' "$(jq -r '.comments | length' <<< "$OUT" 2>/dev/null ||:)" \
  'openai empty -j -> parseable empty envelope' ||:
assert_equal 0 "$(cache_count)" 'openai empty -j -> nothing cached' ||:

# 5. Consumer side on its own: a backend that emits only the sentinel
begin_test 'orphan token sentinel'
reset_cache
PRE_HOOK=stub_openai_orphan
run_check '' -m gpt-5
PRE_HOOK=:
assert_equal 5 "$RC" 'orphan sentinel -> exit 5' ||:
assert_not_contains "$OUT" '___TOKENS___' 'orphan sentinel -> not printed' ||:
assert_equal 0 "$(cache_count)" 'orphan sentinel -> nothing cached' ||:

# 6. Normal completions still pass through, sentinel stripped, cached once
begin_test 'openai normal completion'
reset_cache
run_check "$OPENAI_OK" -m gpt-5
assert_equal 0 "$RC" 'openai normal -> exit 0' ||:
assert_equal "$FINDING" "$OUT" 'openai normal -> text only on stdout' ||:
assert_equal 1 "$(cache_count)" 'openai normal -> one cache entry' ||:

begin_test 'google multi-part completion'
reset_cache
run_check "$GOOGLE_MULTIPART" -m gemini-2.5-flash
assert_equal 0 "$RC" 'google multi-part -> exit 0' ||:
assert_equal "$FINDING" "$OUT" 'google multi-part -> all text parts joined' ||:

# 7. Parity guard: Anthropic and Ollama already end in exit 5 (mock only)
begin_test 'anthropic and ollama parity'
reset_cache
run_check "$ANTHROPIC_EMPTY" -m claude-sonnet-4-6
assert_equal 5 "$RC" 'anthropic thinking-only -> exit 5' ||:
assert_equal 0 "$(cache_count)" 'anthropic thinking-only -> nothing cached' ||:
reset_cache
run_check "$OLLAMA_EMPTY" -m qwen3.5:9b
assert_equal 5 "$RC" 'ollama empty -> exit 5' ||:
assert_equal 0 "$(cache_count)" 'ollama empty -> nothing cached' ||:

print_summary 'check-empty-content'
#fin
