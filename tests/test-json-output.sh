#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-json-output.sh - Offline unit tests for JSON output helpers
#
# Sources the bcs script to exercise _strip_json_fences and
# _render_json_output directly with canned LLM output. No backend needed.
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source=bcs
source "$BCS_CMD"   # source guard keeps main() from running

echo 'Testing: json-output helpers'

# ---- _strip_json_fences ---------------------------------------------------

begin_test 'strip fences: bare array unchanged'
input='[{"line":1,"level":"error","bcsCode":"BCS0101"}]'
assert_equal "$input" "$(_strip_json_fences "$input")"

begin_test 'strip fences: triple-backtick wrapper'
input=$'```\n[{"a":1}]\n```'
assert_equal '[{"a":1}]' "$(_strip_json_fences "$input")"

begin_test 'strip fences: ```json wrapper'
input=$'```json\n[{"a":1}]\n```'
assert_equal '[{"a":1}]' "$(_strip_json_fences "$input")"

begin_test 'strip fences: surrounding whitespace'
input=$'   \n\n[{"a":1}]\n  \n'
assert_equal '[{"a":1}]' "$(_strip_json_fences "$input")"

begin_test 'strip fences: combined json wrapper + whitespace'
input=$'\n\n```json\n[{"x":2}]\n```\n\n'
assert_equal '[{"x":2}]' "$(_strip_json_fences "$input")"

# ---- _render_json_output: happy path -------------------------------------

begin_test 'render: valid bare array wrapped in envelope'
arr='[{"line":4,"endLine":4,"level":"error","code":101,"bcsCode":"BCS0101","tier":"core","message":"m","fixSuggestion":"f"}]'
out=$(_render_json_output "$arr" /tmp/x.sh anthropic claude-haiku-4-5 low 0 12)
if [[ -n $out ]]; then
  assert_equal 'bcs' "$(jq -r '.source' <<< "$out")" 'source=bcs'
  assert_equal '12' "$(jq -r '.meta.elapsed_s' <<< "$out")" 'elapsed_s=12'
  assert_equal 'anthropic' "$(jq -r '.meta.backend' <<< "$out")" 'backend=anthropic'
  assert_equal 'BCS0101' "$(jq -r '.comments[0].bcsCode' <<< "$out")" 'bcsCode=BCS0101'
  assert_equal '/tmp/x.sh' "$(jq -r '.comments[0].file' <<< "$out")" 'file populated'
  assert_equal 'null' "$(jq -r '.comments[0].fix' <<< "$out")" 'fix=null'
  assert_equal '1' "$(jq -r '.comments[0].column' <<< "$out")" 'default column=1'
else
  printf '  %s✗%s render produced no output\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

begin_test 'render: empty array produces envelope with zero comments'
out=$(_render_json_output '[]' /tmp/x.sh ollama qwen3.5:9b medium 1 7)
if [[ -n $out ]]; then
  assert_equal '0' "$(jq -r '.comments | length' <<< "$out")" 'no comments'
  assert_equal 'true' "$(jq -r '.meta.strict' <<< "$out")" 'strict bool preserved'
else
  printf '  %s✗%s render produced no output\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

begin_test 'render: fence-wrapped array still works'
fenced=$'```json\n[{"line":1,"level":"warning","bcsCode":"BCS0202","tier":"recommended","message":"x","fixSuggestion":"y"}]\n```'
out=$(_render_json_output "$fenced" /tmp/x.sh google gemini-2.5-flash low 0 5)
if [[ -n $out ]]; then
  assert_equal 'BCS0202' "$(jq -r '.comments[0].bcsCode' <<< "$out")" 'fenced bare array normalized'
else
  printf '  %s✗%s render produced no output\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

begin_test 'render: object wrapper with findings key is unwrapped'
wrapped='{"findings":[{"line":9,"level":"error","bcsCode":"BCS0303","tier":"core","message":"m","fixSuggestion":"f"}]}'
out=$(_render_json_output "$wrapped" /tmp/x.sh openai gpt-4.1-mini low 0 3)
if [[ -n $out ]]; then
  assert_equal 'BCS0303' "$(jq -r '.comments[0].bcsCode' <<< "$out")" 'findings unwrapped'
else
  printf '  %s✗%s render produced no output\n' "$RED" "$NC"
  TESTS_FAILED+=1
fi

begin_test 'render: default endLine derived from line'
arr='[{"line":7,"level":"warning","bcsCode":"BCS0505","tier":"style","message":"m","fixSuggestion":"f"}]'
out=$(_render_json_output "$arr" /tmp/x.sh ollama qwen low 0 1)
if [[ -n $out ]]; then
  assert_equal '7' "$(jq -r '.comments[0].endLine' <<< "$out")" 'endLine defaults to line'
fi

# ---- _render_json_output: failure cases ----------------------------------

begin_test 'render: invalid JSON returns non-zero'
if _render_json_output 'not json at all' /tmp/x.sh ollama m low 0 1 >/dev/null 2>&1; then
  printf '  %s✗%s expected failure on invalid JSON\n' "$RED" "$NC"
  TESTS_FAILED+=1
else
  printf '  %s✓%s invalid JSON rejected\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
fi

begin_test 'render: empty input returns non-zero'
if _render_json_output '' /tmp/x.sh ollama m low 0 1 >/dev/null 2>&1; then
  printf '  %s✗%s expected failure on empty input\n' "$RED" "$NC"
  TESTS_FAILED+=1
else
  printf '  %s✓%s empty input rejected\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
fi

begin_test 'render: array of objects missing required keys returns non-zero'
bad='[{"line":1,"message":"no bcsCode"}]'
if _render_json_output "$bad" /tmp/x.sh ollama m low 0 1 >/dev/null 2>&1; then
  printf '  %s✗%s expected failure on missing keys\n' "$RED" "$NC"
  TESTS_FAILED+=1
else
  printf '  %s✓%s schema-incomplete array rejected\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
fi

begin_test 'render: object without array field returns non-zero'
bad='{"nothing_useful":"here"}'
if _render_json_output "$bad" /tmp/x.sh ollama m low 0 1 >/dev/null 2>&1; then
  printf '  %s✗%s expected failure on array-less object\n' "$RED" "$NC"
  TESTS_FAILED+=1
else
  printf '  %s✓%s array-less object rejected\n' "$GREEN" "$NC"
  TESTS_PASSED+=1
fi

# ---- envelope shape assertions (shellcheck json1 compatibility) ----------

begin_test 'envelope: top level has source, meta, comments'
arr='[{"line":1,"level":"error","bcsCode":"BCS0101","tier":"core","message":"m","fixSuggestion":"f"}]'
out=$(_render_json_output "$arr" /tmp/x.sh ollama m low 0 1)
keys=$(jq -r 'keys_unsorted | sort | join(",")' <<< "$out")
assert_equal 'comments,meta,source' "$keys" 'envelope keys'

begin_test 'envelope: meta has all expected fields'
arr='[{"line":1,"level":"error","bcsCode":"BCS0101","tier":"core","message":"m","fixSuggestion":"f"}]'
out=$(_render_json_output "$arr" /tmp/x.sh anthropic claude-haiku-4-5 medium 1 42)
meta_keys=$(jq -r '.meta | keys_unsorted | sort | join(",")' <<< "$out")
assert_equal 'backend,effort,elapsed_s,file,model,strict,tool,version' "$meta_keys" 'meta keys'

print_summary 'json-output'
#fin
