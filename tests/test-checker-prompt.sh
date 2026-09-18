#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-checker-prompt.sh - What the checker is shown of the standard
#
# Section 13 documents the bcs toolchain's own configuration and holds no
# rule, so it is cut from the copy every backend sends or points at. The
# assembled document that `bcs display` and `bcs generate` handle keeps it.
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source-path=SCRIPTDIR source=check-harness.sh
source "$TEST_DIR"/check-harness.sh

echo 'Testing: checker prompt contents'

declare -r SECTION13='# Section 13: Environment Configuration'
declare -r STANDARD="$DATA_DIR"/BASH-CODING-STANDARD.md
declare -r OPENAI_OK='{"choices":[{"message":{"content":"No BCS violations found."}}]}'
declare -r GOOGLE_OK='{"candidates":[{"content":{"parts":[{"text":"No BCS violations found."}]}}]}'
declare -r ANTHROPIC_OK='{"content":[{"type":"text","text":"No BCS violations found."}]}'
declare -r OLLAMA_OK='{"message":{"content":"No BCS violations found."}}'

# assert_prompt LABEL TEXT -> the three properties every checker copy must have
assert_prompt() {
  local -- label=$1 text=$2
  assert_not_contains "$text" "$SECTION13" "$label: Section 13 cut" ||:
  assert_contains "$text" '## BCS1213 Date and Time Formatting' "$label: last Section 12 rule kept" ||:
  assert_contains "$text" '# Compliance Checking Reference' "$label: coda kept" ||:
}

begin_test 'harness'
assert_equal "$STANDARD" "$(_find_bcs_md)" 'harness pins the repo standard, not an installed copy' ||:

# ---- The helper on its own ----
begin_test '_checker_standard'
declare -- SYNTHETIC="$SANDBOX"/synthetic.md TRIMMED=''
printf '%s\n' '# Title' '' '---' '' '# Section 12: Style' 'rule twelve' '' '---' '' \
  '# Section 13: Environment Configuration' 'BCS_MODEL default' '' '---' '' \
  '# User Rules' 'user rule' '' '---' '' '# Compliance Checking Reference' 'coda' > "$SYNTHETIC"
TRIMMED=$(_checker_standard "$SYNTHETIC") ||:
assert_not_contains "$TRIMMED" 'BCS_MODEL default' 'Section 13 body removed' ||:
assert_contains "$TRIMMED" 'user rule' 'user rules after Section 13 kept' ||:
assert_equal 3 "$(grep -c -x -- '---' <<< "$TRIMMED")" 'exactly one separator removed with it' ||:
assert_equal "$(grep -v 'Section 13\|BCS_MODEL' "$SYNTHETIC" | grep -c '')" \
  "$(($(grep -c '' <<< "$TRIMMED") + 3))" 'nothing else removed' ||:
printf '%s\n' '# Title' '' '---' '' '# Section 12: Style' 'rule twelve' > "$SYNTHETIC"
assert_equal "$(< "$SYNTHETIC")" "$(_checker_standard "$SYNTHETIC" ||:)" \
  'a document without Section 13 passes through unchanged' ||:

begin_test 'assembled standard'
assert_contains "$(< "$STANDARD")" "$SECTION13" 'bcs generate output still carries Section 13' ||:
assert_prompt 'helper on the real standard' "$(_checker_standard "$STANDARD" ||:)"

# ---- Every backend ----
begin_test 'API backends'
reset_cache; run_check "$OPENAI_OK" -m gpt-5
assert_prompt openai "$(jq -r '.messages[0].content' "$PAYLOAD_FILE")"
reset_cache; run_check "$GOOGLE_OK" -m gemini-2.5-flash
assert_prompt google "$(jq -r '.systemInstruction.parts[0].text' "$PAYLOAD_FILE")"
reset_cache; run_check "$ANTHROPIC_OK" -m claude-sonnet-4-6
assert_prompt anthropic "$(jq -r '.system[0].text' "$PAYLOAD_FILE")"
reset_cache; run_check "$OLLAMA_OK" -m qwen3.5:9b
assert_prompt ollama "$(jq -r '.messages[0].content' "$PAYLOAD_FILE")"

begin_test 'CLI backend'
reset_cache
MOCK_CLI_OUTPUT='No BCS violations found.'
run_check '' -m claude-code:haiku
assert_equal 0 "$RC" 'CLI run succeeds' ||:
assert_prompt 'CLI @file' "$(< "$CLI_STANDARD_FILE")"
assert_not_contains "$(< "$CLI_ARGV_FILE")" "@$STANDARD" \
  'CLI is not pointed at the full assembled standard' ||:

# ---- Fixture pragmas never reach the model ----
# The harness target, fixture 02, names its own answer in its header
# (`# bcs-fixture-expect: BCS0202`). Measured 2026-09-17 on gpt5-mini -e low:
# with those lines visible recall 1.000, blanked 0.546.
begin_test '_checker_script'
declare -- BLIND=''
BLIND=$(_checker_script "$CHECK_TARGET")
assert_contains "$(< "$CHECK_TARGET")" 'bcs-fixture-expect: BCS0202' 'target carries the pragma' ||:
assert_not_contains "$BLIND" 'bcs-fixture-' 'pragma lines blanked' ||:
assert_equal "$(wc -l < "$CHECK_TARGET")" "$(wc -l <<< "$BLIND")" 'line count unchanged' ||:
declare -i DEFECT_LINE=0   # the fixture's planted defect, wherever it sits
#shellcheck disable=SC2016  # literal $1: the fixture's own text
DEFECT_LINE=$(grep -n -F 'filename=$1' "$CHECK_TARGET" | cut -d: -f1)
assert_equal "$(sed -n "${DEFECT_LINE}p" "$CHECK_TARGET")" "$(sed -n "${DEFECT_LINE}p" <<< "$BLIND")" \
  "line $DEFECT_LINE still line $DEFECT_LINE" ||:
assert_equal "$(< "$TEST_DIR"/accuracy/cln)" "$(_checker_script "$TEST_DIR"/accuracy/cln)" \
  'a script without pragmas passes through unchanged' ||:

begin_test 'pragmas hidden from API backends'
# assert_blind LABEL -> the request body neither names the pragma nor its code
assert_blind() {
  assert_not_contains "$(< "$PAYLOAD_FILE")" 'bcs-fixture-' "$1: no pragma in the request" ||:
  assert_not_contains "$(< "$PAYLOAD_FILE")" 'pollutes global scope per BCS0202' \
    "$1: no fixture description in the request" ||:
}
reset_cache; run_check "$OPENAI_OK" -m gpt-5
assert_blind openai
#shellcheck disable=SC2016  # literal $1: the fixture's own defect line
assert_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" "$(printf '%4d:   filename=$1' "$DEFECT_LINE")" \
  'openai: script still numbered from the original lines' ||:
reset_cache; run_check "$GOOGLE_OK" -m gemini-2.5-flash;      assert_blind google
reset_cache; run_check "$ANTHROPIC_OK" -m claude-sonnet-4-6;  assert_blind anthropic
reset_cache; run_check "$OLLAMA_OK" -m qwen3.5:9b;            assert_blind ollama
reset_cache; run_check "$OPENAI_OK" -m gpt-5 -j;              assert_blind 'openai -j'

begin_test 'pragmas hidden from the CLI backend'
reset_cache
MOCK_CLI_OUTPUT='No BCS violations found.'
run_check '' -m claude-code:haiku
assert_not_contains "$(< "$CLI_ARGV_FILE")" "@$CHECK_TARGET" 'CLI is not pointed at the original script' ||:
assert_contains "$(< "$CLI_SCRIPT_FILE")" 'process_file()' 'CLI is pointed at a readable copy' ||:
assert_not_contains "$(< "$CLI_SCRIPT_FILE")" 'bcs-fixture-' 'CLI copy has the pragmas blanked' ||:
assert_equal "$(wc -l < "$CHECK_TARGET")" "$(wc -l < "$CLI_SCRIPT_FILE")" 'CLI copy keeps the line count' ||:

begin_test 'cache keys on what the model saw'
# A hand-blanked twin builds the same prompt, so it must hit the same entry;
# were the key still the raw file, a leak-era answer would be served again.
declare -- TWIN="$SANDBOX"/${CHECK_TARGET##*/}
sed 's/^# bcs-fixture-.*$//' "$CHECK_TARGET" > "$TWIN"   # not via the helper under test
reset_cache; run_check "$OPENAI_OK" -m gpt-5
assert_equal 1 "$(cache_count)" 'fixture run writes one entry' ||:
declare -- ORIG_TARGET=$CHECK_TARGET
CHECK_TARGET=$TWIN
run_check '' -m gpt-5
assert_equal 0 "$RC" 'blanked twin is served from that entry' ||:
assert_equal 1 "$(cache_count)" 'and writes no second entry' ||:
CHECK_TARGET=$ORIG_TARGET

# ---- Text-mode output contract: identical in both prompt builders ----
# assert_contract LABEL PROMPT
assert_contract() {
  local -- label=$1 prompt=$2
  assert_contains "$prompt" 'One finding per line, exactly: [ERROR|WARN] BCSxxxx line N:' \
    "$label: one finding per line, fixed shape" ||:
  assert_contains "$prompt" 'Never print a finding you then retract' "$label: no retractions" ||:
  assert_contains "$prompt" 'no notes on rules that pass' "$label: no pass notes" ||:
  assert_contains "$prompt" 'output exactly one line: No BCS violations found.' "$label: clean line kept" ||:
  assert_contains "$prompt" '#bcscheck disable=' "$label: suppression instruction kept" ||:
}

begin_test 'output contract'
reset_cache; run_check "$OPENAI_OK" -m gpt-5
assert_contract 'API text' "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")"
reset_cache; run_check "$OPENAI_OK" -m gpt-5 --strict
assert_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" 'STRICT MODE' 'API text --strict: strict line kept' ||:
reset_cache; run_check '' -m claude-code:haiku
assert_contract 'CLI text' "$(< "$CLI_ARGV_FILE")"
reset_cache; run_check '{"choices":[{"message":{"content":"{\"findings\": []}"}}]}' -m gpt-5 -j
assert_not_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" 'One finding per line' \
  'JSON mode keeps its own array contract' ||:

begin_test 'effort guidance governs coverage, not length'
reset_cache; run_check "$OPENAI_OK" -m gpt-5 -e xhigh
assert_not_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" 'detailed reasoning' \
  '-e xhigh no longer asks for prose the contract forbids' ||:

# ---- Default effort: medium, on evidence ----
# -e low is 4-5x faster and perfect on the fixture corpus, but on a compliant
# real-size script it raised false [ERROR] findings in 5 of 5 runs (medium: 0
# of 5). See tests/accuracy/LLM-ACCURACY.md, "Effort: low against medium".
begin_test 'default effort'
reset_cache; run_check "$OPENAI_OK" -m gpt-5
assert_equal '8000 low' \
  "$(jq -r '"\(.max_completion_tokens) \(.reasoning_effort)"' "$PAYLOAD_FILE")" \
  'no -e -> medium (8000 output tokens, reasoning_effort=low)' ||:

print_summary 'checker-prompt'
#fin
