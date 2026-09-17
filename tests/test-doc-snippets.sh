#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-doc-snippets.sh - Canonical fix snippets in agent docs must actually run
#
# ai-agents/commands/fix-shellcheck.md is followed verbatim by an agent, so
# its "canonical fix patterns" are code. Each `# SC#### --` snippet is
# extracted and executed under strict mode behind a small prelude of stubs.
set -euo pipefail
shopt -s inherit_errexit

declare -rx PATH=~/.local/bin:/usr/local/bin:/usr/bin:/bin

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh

echo 'Testing: documentation snippets'

declare -r DOC="$PROJECT_DIR"/ai-agents/commands/fix-shellcheck.md

# Illustrative only: the body is a literal `...` placeholder, not a command.
declare -r SKIP_CODES=' SC2181 '

# Stubs for the names the snippets refer to but do not define. Single-quoted
# on purpose: this is source text for the child bash, expanded there.
#shellcheck disable=SC2016
declare -r PRELUDE='set -euo pipefail
shopt -s inherit_errexit
some_command() { echo value; }
die() { exit "$1"; }
declare -- var="a b" dir=/ path=/dev/null
declare -a files=(one two)
'

# snippet SC#### -> the lines from that header comment up to the next blank
# line or the closing code fence
snippet() {
  awk -v hdr="# $1 --" 'index($0, hdr) == 1 {p=1} p && /^(```)?$/ {exit} p' "$DOC"
}

assert_file_exists "$DOC" 'fix-shellcheck.md present' ||:

declare -a CODES=()
readarray -t CODES < <(grep -oE '^# SC[0-9]{4} --' "$DOC" | grep -oE 'SC[0-9]{4}')
begin_test 'snippets found'
assert_gt "${#CODES[@]}" 5 "found ${#CODES[@]} fix snippets" ||:

declare -- CODE BODY ERR ALL_SNIPPETS=''
declare -i RC
for CODE in "${CODES[@]}"; do
  BODY=$(snippet "$CODE")
  ALL_SNIPPETS+=$BODY$'\n'
  [[ $SKIP_CODES != *" $CODE "* ]] || continue
  begin_test "snippet $CODE"
  RC=0
  ERR=$(bash -c "$PRELUDE$BODY" 2>&1 >/dev/null) || RC=$?
  assert_equal 0 "$RC" "$CODE snippet runs under strict mode${ERR:+ ($ERR)}" ||:
done

begin_test 'snippets obey the standard'
assert_equal 0 "$(grep -v '^#' <<< "$ALL_SNIPPETS" | grep -cE '\(\(.*(\+\+|\+= *1)' ||:)" \
  'no ((x++)) or ((x += 1)) in any fix snippet (BCS0505: use x+=1)' ||:
assert_contains "$(snippet SC2155)" 'readonly FOO' \
  'SC2155 fix ends in readonly (BCS0205 declare, assign, readonly)' ||:
assert_contains "$(snippet SC2004)" 'count+=1' 'SC2004 fix increments with count+=1' ||:

begin_test 'citations'
assert_equal 1 "$(grep -c '^## Disable Rules (BCS1206)' "$DOC" ||:)" \
  'disable-directive rules cite BCS1206 (Static Analysis Directives)' ||:
assert_equal 0 "$(grep -c 'BCS1204' "$DOC" ||:)" \
  'BCS1204 (Section Comments) is not cited for disable directives' ||:

print_summary 'doc-snippets'
#fin
