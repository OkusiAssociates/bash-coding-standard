#!/usr/bin/env bash
# test-detect-backend.sh - Unit tests for _detect_backend()
#
# _detect_backend probes Ollama via HTTP then checks API key presence
# in a fixed order. We mock curl() to force the Ollama probe's result,
# manipulate env vars to drive the fallback order, and verify each
# short-circuit point.

set -euo pipefail
shopt -s inherit_errexit

#shellcheck source=tests/test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source=bcs
source "$BCS_CMD"   # source guard keeps main() from running

echo 'Testing: _detect_backend'

# Reset all relevant env vars to a known state before each test.
# Note: simple `VAR=val command $(inner_cmd)` does NOT set VAR during
# the command-substitution expansion -- bash expands args BEFORE applying
# the temp env. We therefore assign env vars in the current shell.
reset_env() {
  unset ANTHROPIC_API_KEY OPENAI_API_KEY GOOGLE_API_KEY GEMINI_API_KEY
  unset OLLAMA_HOST
}

# Ollama unreachable (curl fails).
curl_fail() { curl() { return 1; }; }
# Ollama reachable (curl succeeds).
curl_ok()   { curl() { return 0; }; }
# Remove the override.
curl_real() { unset -f curl; }

# --- Ollama probe ------------------------------------------------------

begin_test 'ollama reachable wins even with all API keys set'
reset_env
curl_ok
ANTHROPIC_API_KEY=a OPENAI_API_KEY=b GOOGLE_API_KEY=c
assert_equal ollama "$(_detect_backend)"
reset_env
curl_real

# --- Anthropic fallback ------------------------------------------------

begin_test 'anthropic wins when ollama unreachable and ANTHROPIC_API_KEY set'
reset_env
curl_fail
ANTHROPIC_API_KEY='test'
assert_equal anthropic "$(_detect_backend)"
reset_env
curl_real

begin_test 'anthropic wins over openai/google when all three keys set'
reset_env
curl_fail
ANTHROPIC_API_KEY=a OPENAI_API_KEY=b GOOGLE_API_KEY=c
assert_equal anthropic "$(_detect_backend)"
reset_env
curl_real

# --- OpenAI fallback ---------------------------------------------------

begin_test 'openai wins when only OPENAI_API_KEY set'
reset_env
curl_fail
OPENAI_API_KEY='test'
assert_equal openai "$(_detect_backend)"
reset_env
curl_real

begin_test 'openai wins over google when both set (no anthropic)'
reset_env
curl_fail
OPENAI_API_KEY=a GOOGLE_API_KEY=b
assert_equal openai "$(_detect_backend)"
reset_env
curl_real

# --- Google fallback via GOOGLE_API_KEY --------------------------------

begin_test 'google wins when only GOOGLE_API_KEY set'
reset_env
curl_fail
GOOGLE_API_KEY='test'
assert_equal google "$(_detect_backend)"
reset_env
curl_real

# --- Google fallback via GEMINI_API_KEY --------------------------------

begin_test 'google backend via GEMINI_API_KEY alone'
reset_env
curl_fail
GEMINI_API_KEY='test'
assert_equal google "$(_detect_backend)"
reset_env
curl_real

# --- Claude CLI fallback (system-dependent) ----------------------------
# Only meaningful given the current system state (whether `claude` is on PATH).

begin_test 'claude CLI is final fallback when nothing else available'
reset_env
curl_fail
if command -v claude &>/dev/null; then
  assert_equal claude "$(_detect_backend)" 'claude CLI picked up'
else
  # Truly nothing available.
  if _detect_backend &>/dev/null; then
    TESTS_FAILED+=1
    printf '  %s✗%s detect_backend should fail when nothing available\n' "$RED" "$NC"
  else
    TESTS_PASSED+=1
    printf '  %s✓%s detect_backend returns non-zero when nothing available\n' "$GREEN" "$NC"
  fi
fi
curl_real

print_summary 'detect-backend'
#fin
