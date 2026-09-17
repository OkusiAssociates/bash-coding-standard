#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-check-exit-promotion.sh - Only a finding tagged [ERROR] promotes exit to 1
#
# Text mode promotes the exit code to 1 when the answer holds an [ERROR]
# finding. The probe is anchored to a finding header, so a sentence that merely
# mentions the tag does not fail a clean script. tests/replay/ holds real
# checker answers saved during the September 2026 audit; the rc in each file
# name is the verdict the probe must reproduce.
set -euo pipefail
shopt -s inherit_errexit nullglob

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source-path=SCRIPTDIR source=check-harness.sh
source "$TEST_DIR"/check-harness.sh

echo 'Testing: text-mode exit promotion'

# probe TEXT -> 1 when TEXT holds an [ERROR] finding, else 0
probe() { _has_error_finding "$1" && echo 1 || echo 0; }

# ---- Replay: every saved answer keeps its verdict ----
declare -- REPLAY_FILE='' WANT=''
declare -a REPLAY_FILES=("$TEST_DIR"/replay/*.rc[01].txt)
begin_test 'replay corpus present'
assert_gt "${#REPLAY_FILES[@]}" 9 "replay corpus has ${#REPLAY_FILES[@]} saved answers" ||:
for REPLAY_FILE in "${REPLAY_FILES[@]}"; do
  begin_test "replay ${REPLAY_FILE##*/}"
  WANT=${REPLAY_FILE%.txt}; WANT=${WANT##*.rc}
  assert_equal "$WANT" "$(probe "$(< "$REPLAY_FILE")")" "replay ${REPLAY_FILE##*/}" ||:
done

# ---- Genuine finding headers, in every layout the backends have produced ----
begin_test 'genuine findings'
assert_equal 1 "$(probe '[ERROR] BCS0101 line 3: strict mode missing')" 'contract format' ||:
assert_equal 1 "$(probe '  [ERROR] BCS0101 line 3: indented')" 'indented' ||:
assert_equal 1 "$(probe '- [ERROR] BCS0101 line 3: list item')" 'list bullet' ||:
assert_equal 1 "$(probe '3. [ERROR] BCS0101 line 3: numbered')" 'numbered list' ||:
assert_equal 1 "$(probe '### [ERROR] BCS0101 line 3')" 'heading' ||:
assert_equal 1 "$(probe '**[ERROR] BCS0102** (Tier: core) — Line 6')" 'bold tag first' ||:
assert_equal 1 "$(probe '**BCS1005** (Tier: core) — **[ERROR]** — Line 215')" 'bold code first' ||:
assert_equal 1 "$(probe '**BCS0409** — Tier: core — [ERROR] — Line 8')" 'code first, plain tag' ||:
assert_equal 1 "$(probe $'[WARN] BCS0301 line 2: quotes\n\n[ERROR] BCS0202 line 8: not local')" \
  'ERROR after other findings' ||:

# ---- Sentences that merely mention the tag ----
begin_test 'prose mentions'
assert_equal 0 "$(probe 'No BCS violations found.')" 'clean line' ||:
assert_equal 0 "$(probe 'There are no [ERROR] findings in this script.')" 'mid-sentence mention' ||:
assert_equal 0 "$(probe 'Severity mapping: core violations are labelled [ERROR].')" 'prompt echo' ||:
assert_equal 0 "$(probe '[WARN] BCS0301 line 4: double quotes (would be [ERROR] under --strict)')" \
  'WARN finding that mentions the tag' ||:
assert_equal 0 "$(probe 'BCS0704 is style tier, so [WARN] applies here, never [ERROR].')" \
  'code-first sentence about a WARN' ||:

# ---- Wiring through cmd_check (curl mocked, OpenAI path) ----
begin_test 'cmd_check wiring'
reset_cache
run_check "$(openai_body 'No BCS violations found.')" -m gpt-5
assert_equal 0 "$RC" 'clean line -> exit 0' ||:
assert_equal 'No BCS violations found.' "$OUT" 'clean line -> printed as the result' ||:
reset_cache
run_check "$(openai_body 'There are no [ERROR] findings in this script.')" -m gpt-5
assert_equal 0 "$RC" 'prose mention -> exit 0' ||:
reset_cache
run_check "$(openai_body '[ERROR] BCS0202 line 8: variable not declared local')" -m gpt-5
assert_equal 1 "$RC" 'genuine ERROR -> exit 1' ||:
run_check '' -m gpt-5
assert_equal 1 "$RC" 'genuine ERROR served from cache -> still exit 1' ||:

# ---- Both text-mode prompt builders ask for the clean line ----
begin_test 'clean line in prompts'
reset_cache
run_check "$(openai_body 'No BCS violations found.')" -m gpt-5
assert_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" \
  'output exactly one line: No BCS violations found.' 'API text prompt asks for the clean line' ||:
reset_cache
MOCK_CLI_OUTPUT='No BCS violations found.'
run_check '' -m claude-code:haiku
assert_equal 0 "$RC" 'CLI backend clean line -> exit 0' ||:
assert_contains "$(< "$CLI_ARGV_FILE")" \
  'output exactly one line: No BCS violations found.' 'CLI text prompt asks for the clean line' ||:
reset_cache
run_check "$(openai_body '[]')" -m gpt-5 -j
assert_not_contains "$(jq -r '.messages[1].content' "$PAYLOAD_FILE")" \
  'No BCS violations found.' 'JSON prompt keeps its own empty-array contract' ||:

print_summary 'check-exit-promotion'
#fin
