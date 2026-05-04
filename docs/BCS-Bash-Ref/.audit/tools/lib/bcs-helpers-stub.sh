#!/usr/bin/env bash
# shellcheck shell=bash
# bcs-helpers-stub.sh — minimal BCS messaging helpers for the audit sandbox.
#
# Sourced by run-blocks.bash before each block executes. Provides stand-ins
# for die/info/success/warn/error/noarg/vecho/yn so corpus blocks that call
# them don't crash with `command not found` under env -i.
#
# Contract intentionally tracks the BCS standard helpers' visible behaviour
# but with no ANSI colours and no log-level prefix. info/success/warn/error
# all go to stderr (so they never pollute stdout that # ⇒ annotations match
# against). vecho honours VERBOSE; info/success do not — pedagogy blocks
# expect them to print regardless of the (unset) VERBOSE in the sandbox.
#
# This file is not intended to be executed; do not give it strict-mode
# preamble — sourcing it must not alter the caller's set-options.

_msg() {
  >&2 printf '%s: %s\n' "${SCRIPT_NAME:-bcs-audit-stub}" "$*"
}

info()    { _msg "$@"; }
success() { _msg "$@"; }
warn()    { _msg "$@"; }
error()   { _msg "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg()   { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }
vecho()   { ((${VERBOSE:-0})) || return 0; printf '%s\n' "$*"; }
yn()      { [[ "${1:-}" =~ ^[Yy]$ ]]; }
