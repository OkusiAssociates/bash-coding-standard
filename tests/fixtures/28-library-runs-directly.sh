#!/usr/bin/env bash
# bcs-fixture-expect: BCS0407
# bcs-fixture-description: Pure function library with no guard against direct execution; a library must reject being run per BCS0407.
# strutil.sh - string helpers. Source this file; it is not a program.

declare -rx STRUTIL_VERSION=1.0.0

strutil_upper() {
  local -- text=$1
  echo "${text^^}"
}

strutil_lower() {
  local -- text=$1
  echo "${text,,}"
}
declare -fx strutil_upper strutil_lower
#fin
