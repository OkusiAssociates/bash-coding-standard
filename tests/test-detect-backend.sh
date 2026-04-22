#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-detect-backend.sh - Unit tests for _detect_backend()
#
# _detect_backend probes claude CLI on PATH first, then Ollama via HTTP,
# then API-key presence in a fixed order. We mock `command` and `curl` to
# force each branch's result and verify every short-circuit point.

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

# Claude CLI mocks: intercept `command -v claude` only; delegate everything
# else to the real builtin so other `command` invocations keep working.
claude_absent()  { command() { [[ $1 == -v && $2 == claude ]] && return 1; builtin command "$@"; }; }
claude_present() { command() { [[ $1 == -v && $2 == claude ]] && { echo /usr/bin/claude; return 0; }; builtin command "$@"; }; }
claude_real()    { unset -f command; }

# --- Claude CLI probe (highest priority) -------------------------------

begin_test 'claude CLI wins when present, even with ollama reachable and all API keys set'
reset_env
claude_present
curl_ok
ANTHROPIC_API_KEY=a OPENAI_API_KEY=b GOOGLE_API_KEY=c
assert_equal claude "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- Ollama probe ------------------------------------------------------

begin_test 'ollama wins when claude absent and ollama reachable, even with all API keys set'
reset_env
claude_absent
curl_ok
ANTHROPIC_API_KEY=a OPENAI_API_KEY=b GOOGLE_API_KEY=c
assert_equal ollama "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- Anthropic fallback ------------------------------------------------

begin_test 'anthropic wins when claude absent, ollama unreachable, ANTHROPIC_API_KEY set'
reset_env
claude_absent
curl_fail
ANTHROPIC_API_KEY='test'
assert_equal anthropic "$(_detect_backend)"
reset_env
curl_real
claude_real

begin_test 'anthropic wins over openai/google when all three keys set'
reset_env
claude_absent
curl_fail
ANTHROPIC_API_KEY=a OPENAI_API_KEY=b GOOGLE_API_KEY=c
assert_equal anthropic "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- OpenAI fallback ---------------------------------------------------

begin_test 'openai wins when only OPENAI_API_KEY set'
reset_env
claude_absent
curl_fail
OPENAI_API_KEY='test'
assert_equal openai "$(_detect_backend)"
reset_env
curl_real
claude_real

begin_test 'openai wins over google when both set (no anthropic)'
reset_env
claude_absent
curl_fail
OPENAI_API_KEY=a GOOGLE_API_KEY=b
assert_equal openai "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- Google fallback via GOOGLE_API_KEY --------------------------------

begin_test 'google wins when only GOOGLE_API_KEY set'
reset_env
claude_absent
curl_fail
GOOGLE_API_KEY='test'
assert_equal google "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- Google fallback via GEMINI_API_KEY --------------------------------

begin_test 'google backend via GEMINI_API_KEY alone'
reset_env
claude_absent
curl_fail
GEMINI_API_KEY='test'
assert_equal google "$(_detect_backend)"
reset_env
curl_real
claude_real

# --- Nothing available -------------------------------------------------

begin_test 'detect_backend returns non-zero when nothing is available'
reset_env
claude_absent
curl_fail
if _detect_backend &>/dev/null; then
  TESTS_FAILED+=1
  printf '  %s✗%s detect_backend should fail when nothing available\n' "$RED" "$NC"
else
  TESTS_PASSED+=1
  printf '  %s✓%s detect_backend returns non-zero when nothing available\n' "$GREEN" "$NC"
fi
reset_env
curl_real
claude_real

print_summary 'detect-backend'
#fin
