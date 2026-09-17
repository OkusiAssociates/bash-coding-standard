#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-fixtures-gate.sh - The accuracy gate must not pass on a dead backend
#
# Drives test-check-fixtures.sh and accuracy/bcs-accuracy-score.sh through
# their command seams (BCS_FIXTURES_CMD, BCS_SCORE_CMD) with a stub checker
# that replays canned outcomes. `curl` and `claude` are exported shell
# functions and every API key is a dummy, so no backend is ever contacted.
set -euo pipefail
shopt -s inherit_errexit nullglob

declare -rx PATH=~/.local/bin:/usr/local/bin:/usr/bin:/bin

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: fixtures gate and accuracy scorer'

declare -- SANDBOX='' OUT=''
declare -i RC=0

trap '[[ -z $SANDBOX ]] || rm -rf -- "$SANDBOX"' EXIT
SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}"/bcs-gate.XXXXXX) \
  || { >&2 echo 'Failed to create sandbox directory'; exit 1; }
declare -r STUB="$SANDBOX"/stub-bcs ARGV_LOG="$SANDBOX"/argv.log

# Stub checker: logs its argv, then replays the outcome named by STUB_MODE.
cat > "$STUB" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$STUB_ARGV_LOG"
declare -r FIXTURE=${!#}

emit_findings() {
  local -- code
  while IFS= read -r code; do
    printf '[ERROR] %s line 1: stub finding\n' "$code"
  done < <(sed -n '1,15p' "$FIXTURE" | grep -F 'bcs-fixture-expect:' | grep -oE 'BCS[0-9]{4}')
  exit 1
}

case ${STUB_MODE:-findings} in
  empty)    exit 0 ;;
  timeout)  exit 124 ;;
  apierror) >&2 echo 'bcs: ✗ OpenAI API error (HTTP 401)'; exit 5 ;;
  mixed)    if [[ ${FIXTURE##*/} == 01-* ]]; then exit 124; fi
            emit_findings ;;
  json)     echo '{"source":"bcs","meta":{},"comments":[]}' ;;
  *)        emit_findings ;;
esac
STUB
chmod +x "$STUB"

# Reachability mocks, imported by the child bash. curl answers the Ollama
# /api/tags probe; claude only has to exist for `command -v`.
curl() { ((${MOCK_OLLAMA_UP:-0})); }
claude() { :; }
declare -fx curl claude

# run_child SCRIPT STUB_MODE [VAR=value ...] [-- script args...]
# Runs SCRIPT with a scrubbed environment; fills RC and OUT.
run_child() {
  local -- script=$1 mode=$2; shift 2
  local -a env_args=() script_args=()
  while (($#)); do
    if [[ $1 == -- ]]; then shift; script_args=("$@"); break; fi
    env_args+=("$1"); shift
  done
  : > "$ARGV_LOG"
  RC=0
  env -u BCS_SKIP_FIXTURES -u BCS_FIXTURES_REQUIRE_BACKEND -u BCS_FIXTURES_MODEL \
      -u BCS_FIXTURES_JSON -u BCS_SCORE_MODEL -u OPENAI_API_KEY -u GOOGLE_API_KEY \
      -u GEMINI_API_KEY -u ANTHROPIC_API_KEY -u MOCK_OLLAMA_UP \
      BCS_FIXTURES_CMD="$STUB" BCS_SCORE_CMD="$STUB" \
      STUB_MODE="$mode" STUB_ARGV_LOG="$ARGV_LOG" "${env_args[@]}" \
      bash "$script" "${script_args[@]}" &>"$SANDBOX"/out || RC=$?
  OUT=$(< "$SANDBOX"/out)
}
run_gate() { run_child "$TEST_DIR"/test-check-fixtures.sh "$@"; }

declare -a FIXTURES=("$TEST_DIR"/fixtures/*.sh)
declare -ri FIXTURE_COUNT=${#FIXTURES[@]}

# ---- Inconclusive fixtures are not passes ----
begin_test 'every fixture empty'
run_gate empty OPENAI_API_KEY=test-openai
assert_equal 1 "$RC" 'all empty output -> suite fails' ||:
assert_contains "$OUT" "$FIXTURE_COUNT inconclusive" 'all empty output -> counted inconclusive' ||:

begin_test 'every fixture times out'
run_gate timeout OPENAI_API_KEY=test-openai
assert_equal 1 "$RC" 'all rc 124 -> suite fails' ||:
assert_contains "$OUT" "$FIXTURE_COUNT inconclusive" 'all rc 124 -> counted inconclusive' ||:

begin_test 'every fixture hits a backend error'
run_gate apierror OPENAI_API_KEY=test-openai
assert_equal 1 "$RC" 'all rc 5 -> suite fails' ||:
assert_contains "$OUT" "$FIXTURE_COUNT inconclusive" 'all rc 5 -> counted inconclusive' ||:
assert_not_contains "$OUT" 'missing:' 'backend error is not reported as a finding regression' ||:

begin_test 'healthy backend'
run_gate findings OPENAI_API_KEY=test-openai
assert_equal 0 "$RC" 'expected findings -> suite passes' ||:
assert_contains "$OUT" "$FIXTURE_COUNT passed, 0 failed" 'expected findings -> every fixture passed' ||:

begin_test 'one inconclusive fixture'
run_gate mixed OPENAI_API_KEY=test-openai
assert_equal 0 "$RC" 'one inconclusive -> suite still passes' ||:
assert_contains "$OUT" "$((FIXTURE_COUNT - 1)) passed, 0 failed" 'one inconclusive -> not counted as passed' ||:
assert_contains "$OUT" '1 inconclusive' 'one inconclusive -> reported' ||:
run_gate mixed OPENAI_API_KEY=test-openai BCS_FIXTURES_REQUIRE_BACKEND=1
assert_equal 1 "$RC" 'one inconclusive + REQUIRE_BACKEND=1 -> suite fails' ||:

# ---- Probe order: API keys, then Ollama, then the CLI ----
begin_test 'probe order'
run_gate findings OPENAI_API_KEY=k GOOGLE_API_KEY=k ANTHROPIC_API_KEY=k MOCK_OLLAMA_UP=1
assert_contains "$OUT" 'using backend: openai' 'all reachable -> openai' ||:
assert_contains "$(< "$ARGV_LOG")" '-m gpt5-mini' 'openai -> gpt5-mini' ||:
run_gate findings GOOGLE_API_KEY=k ANTHROPIC_API_KEY=k MOCK_OLLAMA_UP=1
assert_contains "$OUT" 'using backend: google' 'no openai key -> google' ||:
run_gate findings GEMINI_API_KEY=k
assert_contains "$OUT" 'using backend: google' 'GEMINI_API_KEY alone -> google' ||:
run_gate findings ANTHROPIC_API_KEY=k MOCK_OLLAMA_UP=1
assert_contains "$OUT" 'using backend: anthropic' 'anthropic key only -> anthropic' ||:
run_gate findings MOCK_OLLAMA_UP=1
assert_contains "$OUT" 'using backend: ollama' 'no keys, Ollama up -> ollama' ||:
run_gate findings
assert_contains "$OUT" 'using backend: claude' 'no keys, Ollama down -> CLI' ||:

begin_test 'BCS_FIXTURES_MODEL'
run_gate findings OPENAI_API_KEY=k BCS_FIXTURES_MODEL=flash
assert_equal "$FIXTURE_COUNT" "$(grep -c -- '-m flash ' "$ARGV_LOG" ||:)" \
  'BCS_FIXTURES_MODEL=flash honoured for every fixture, whatever was probed' ||:

# ---- Scorer: every repetition must bypass the result cache ----
begin_test 'accuracy scorer'
run_child "$TEST_DIR"/accuracy/bcs-accuracy-score.sh json -- \
  -m gpt5-mini -n 2 -o "$SANDBOX"/score "${FIXTURES[0]}" "${FIXTURES[1]}"
assert_equal 0 "$RC" 'scorer runs against the stub' ||:
assert_equal 4 "$(wc -l < "$ARGV_LOG")" 'scorer: 2 fixtures x 2 runs = 4 checker calls' ||:
assert_equal 4 "$(grep -c -- '--no-cache' "$ARGV_LOG" ||:)" 'scorer: every call passes --no-cache' ||:
run_child "$TEST_DIR"/accuracy/bcs-accuracy-score.sh json OPENAI_API_KEY=k MOCK_OLLAMA_UP=1 -- \
  -n 1 -o "$SANDBOX"/score "${FIXTURES[0]}"
assert_contains "$OUT" 'backend=openai' 'scorer probe: API key wins over Ollama and CLI' ||:

print_summary 'fixtures-gate'
#fin
