#!/usr/bin/env bash
# test-load-policy.sh - Unit tests for _load_policy()
#
# Overrides _policy_search_paths to point at test fixtures, verifies
# cascade precedence (later wins), warning behaviour on malformed lines,
# and correct handling of disabled/unknown-tier values.

set -euo pipefail
shopt -s inherit_errexit

#shellcheck source=tests/test-helpers.sh
source "$(dirname "$0")"/test-helpers.sh
#shellcheck source=bcs
source "$BCS_CMD"   # source guard keeps main() from running

echo 'Testing: _load_policy'

# Fixture layout mirrors the real cascade: system -> user -> project.
declare -- FIXTURE_ROOT
FIXTURE_ROOT=$(mktemp -d) || { echo 'mktemp failed' >&2; exit 1; }
trap 'rm -rf "$FIXTURE_ROOT"' EXIT

declare -- SYS_CONF="$FIXTURE_ROOT"/system/policy.conf
declare -- USR_CONF="$FIXTURE_ROOT"/user/policy.conf
declare -- PRJ_CONF="$FIXTURE_ROOT"/project/policy.conf

mkdir -p "${SYS_CONF%/*}" "${USR_CONF%/*}" "${PRJ_CONF%/*}"

# Override the cascade helper to emit our fixture paths instead of
# /etc/..., $XDG_CONFIG_HOME/... etc.
_policy_search_paths() {
  printf '%s\n' "$SYS_CONF" "$USR_CONF" "$PRJ_CONF"
}

# Reset policy state so _load_policy re-reads each time.
reset_policy() {
  _policy_loaded=0
  BCS_POLICY=()
}

# --- Single-file loading ------------------------------------------------

begin_test 'single file: one entry'
: > "$SYS_CONF" "$USR_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
BCS0101 = style
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal style "${BCS_POLICY[BCS0101]:-UNSET}"

begin_test 'single file: multiple entries'
: > "$SYS_CONF" "$USR_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
BCS0101 = style
BCS0301 = disabled
BCS1001 = core
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal style    "${BCS_POLICY[BCS0101]:-UNSET}" "BCS0101 loaded"
assert_equal disabled "${BCS_POLICY[BCS0301]:-UNSET}" "BCS0301 loaded"
assert_equal core     "${BCS_POLICY[BCS1001]:-UNSET}" "BCS1001 loaded"

# --- Cascade precedence (later wins) -----------------------------------

begin_test 'user overrides system'
cat > "$SYS_CONF" <<'EOF'
BCS0101 = recommended
EOF
cat > "$USR_CONF" <<'EOF'
BCS0101 = style
EOF
: > "$PRJ_CONF"
reset_policy
_load_policy 2>/dev/null
assert_equal style "${BCS_POLICY[BCS0101]:-UNSET}" 'user should win over system'

begin_test 'project overrides user'
cat > "$SYS_CONF" <<'EOF'
BCS0101 = recommended
EOF
cat > "$USR_CONF" <<'EOF'
BCS0101 = style
EOF
cat > "$PRJ_CONF" <<'EOF'
BCS0101 = disabled
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal disabled "${BCS_POLICY[BCS0101]:-UNSET}" 'project should win over user'

begin_test 'unique keys merge across layers'
cat > "$SYS_CONF" <<'EOF'
BCS0101 = style
EOF
cat > "$USR_CONF" <<'EOF'
BCS0301 = disabled
EOF
cat > "$PRJ_CONF" <<'EOF'
BCS1001 = core
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal style    "${BCS_POLICY[BCS0101]:-UNSET}" 'system key preserved'
assert_equal disabled "${BCS_POLICY[BCS0301]:-UNSET}" 'user key preserved'
assert_equal core     "${BCS_POLICY[BCS1001]:-UNSET}" 'project key preserved'

# --- Comment and whitespace handling ------------------------------------

begin_test 'comments and blank lines ignored'
: > "$SYS_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
# leading comment

BCS0101 = style   # trailing comment

  BCS0301  =  disabled

# final comment
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal style    "${BCS_POLICY[BCS0101]:-UNSET}" 'trailing comment stripped'
assert_equal disabled "${BCS_POLICY[BCS0301]:-UNSET}" 'leading/trailing whitespace stripped'

# --- Malformed lines: warn, do not abort --------------------------------

begin_test 'invalid tier warns and skips'
: > "$SYS_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
BCS0101 = bogus
BCS0301 = style
EOF
reset_policy
# Run _load_policy in the current shell (so BCS_POLICY mutations persist),
# capturing stderr to a file for inspection.
_load_policy 2>"$FIXTURE_ROOT"/err.log
err=$(< "$FIXTURE_ROOT"/err.log)
assert_contains "$err" 'invalid tier' 'warning emitted for invalid tier'
assert_equal 'UNSET'  "${BCS_POLICY[BCS0101]:-UNSET}" 'bogus tier not loaded'
assert_equal style    "${BCS_POLICY[BCS0301]:-UNSET}" 'valid entry after bad one still loaded'

begin_test 'malformed line warns and skips'
: > "$SYS_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
this is not valid
BCS0101 = style
EOF
reset_policy
# Run _load_policy in the current shell (so BCS_POLICY mutations persist),
# capturing stderr to a file for inspection.
_load_policy 2>"$FIXTURE_ROOT"/err.log
err=$(< "$FIXTURE_ROOT"/err.log)
assert_contains "$err" 'malformed policy line' 'warning emitted for malformed line'
assert_equal style "${BCS_POLICY[BCS0101]:-UNSET}" 'valid line still loaded'

# --- All four tier values accept --------------------------------------

begin_test 'all four tier values accepted'
: > "$SYS_CONF" "$PRJ_CONF"
cat > "$USR_CONF" <<'EOF'
BCS0001 = core
BCS0002 = recommended
BCS0003 = style
BCS0004 = disabled
EOF
reset_policy
_load_policy 2>/dev/null
assert_equal core        "${BCS_POLICY[BCS0001]:-UNSET}"
assert_equal recommended "${BCS_POLICY[BCS0002]:-UNSET}"
assert_equal style       "${BCS_POLICY[BCS0003]:-UNSET}"
assert_equal disabled    "${BCS_POLICY[BCS0004]:-UNSET}"

# --- No files: no error, empty policy -----------------------------------

begin_test 'no files: load succeeds silently with empty policy'
rm -f "$SYS_CONF" "$USR_CONF" "$PRJ_CONF"
reset_policy
_load_policy 2>/dev/null
assert_equal 0 "${#BCS_POLICY[@]}" 'policy remains empty when no files present'

print_summary 'load-policy'
#fin
