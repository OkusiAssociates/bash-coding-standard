#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# test-cli-backend.sh - How bcs check drives the Claude Code CLI backend
#
# `claude` is a shell function from check-harness.sh that records its argv and
# replays a canned answer, so the real CLI never runs.
set -euo pipefail
shopt -s inherit_errexit

#shellcheck source-path=SCRIPTDIR source=test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source-path=SCRIPTDIR source=check-harness.sh
source "$TEST_DIR"/check-harness.sh

echo 'Testing: Claude Code CLI backend'

# arg_after FLAG -> the argv element that followed FLAG in the last CLI call
arg_after() { grep -x -A1 -- "$1" "$CLI_ARGV_FILE" | sed -n 2p; }

declare -r DUMP="$XDG_STATE_HOME"/bcs/last-response.txt
# dump_text -> contents of the response dump, empty when it was never written
dump_text() { [[ ! -f $DUMP ]] || echo "$(< "$DUMP")"; }

# ---- Invocation ----
begin_test 'CLI arguments'
reset_cache
MOCK_CLI_OUTPUT='No BCS violations found.' MOCK_CLI_STDERR='' MOCK_CLI_RC=0
run_check '' -m claude-code:haiku -e high
assert_equal 0 "$RC" 'clean answer -> exit 0' ||:
assert_equal low "$(arg_after --effort)" '-e high still runs the CLI at its lowest native effort' ||:
assert_equal 1 "$(grep -c -x -- '--strict-mcp-config' "$CLI_ARGV_FILE" ||:)" \
  '--strict-mcp-config keeps user MCP servers out of the session' ||:
assert_equal 'Read,Grep,Glob' "$(arg_after --tools)" 'read-only toolset kept' ||:
assert_equal bypassPermissions "$(arg_after --permission-mode)" 'permission mode kept' ||:
assert_equal claude-haiku-4-5 "$(arg_after --model)" 'model alias expanded' ||:
reset_cache
run_check '' -m claude-code:haiku -e low
assert_equal low "$(arg_after --effort)" '-e low -> native effort low' ||:

# ---- A failing CLI is a backend failure, not "violations found" ----
begin_test 'CLI failure'
reset_cache
MOCK_CLI_OUTPUT='' MOCK_CLI_STDERR='Invalid API key · Please run /login' MOCK_CLI_RC=1
run_check '' -m claude-code:haiku
assert_equal 5 "$RC" 'CLI exit 1 -> bcs exit 5, never the "ERROR findings" code 1' ||:
assert_contains "$ERR" 'Please run /login' 'CLI stderr reaches the user' ||:
assert_contains "$(dump_text)" 'Please run /login' 'CLI stderr kept in the response dump' ||:
assert_contains "$ERR" "$DUMP" 'dump path announced on failure' ||:
assert_equal 0 "$(cache_count)" 'failed CLI run is not cached' ||:

# ---- stderr noise on a good run stays out of the result ----
begin_test 'CLI stderr on success'
reset_cache
MOCK_CLI_OUTPUT='[WARN] BCS0301 line 4: static string in double quotes'
MOCK_CLI_STDERR='deprecation notice' MOCK_CLI_RC=0
run_check '' -m claude-code:haiku
assert_equal 0 "$RC" 'WARN only -> exit 0' ||:
assert_equal "$MOCK_CLI_OUTPUT" "$OUT" 'stdout is the answer alone' ||:
assert_contains "$(dump_text)" 'deprecation notice' 'stderr noise lands in the dump' ||:

print_summary 'cli-backend'
#fin
