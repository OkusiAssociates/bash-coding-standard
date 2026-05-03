<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.13 Tempdir lifecycle

Use this whenever a script needs scratch space — extracting a tarball,
staging files for atomic publish, accumulating intermediate output
across functions. Reach for `mktemp -d` plus an `EXIT` trap, never
hand-rolled `/tmp/$$`-style paths: predictable names are a security
hole (BCS1006), and an `EXIT` trap guarantees cleanup on every exit
path including signals, errors, and ordinary returns.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='tempdir-demo'
declare -- TEMP_DIR=''

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT          # disarm to prevent recursion
  [[ -z $TEMP_DIR ]] || rm -rf -- "$TEMP_DIR"
  exit "$exitcode"
}

main() {
  # Install the trap BEFORE creating the resource. If mktemp fails,
  # cleanup runs with TEMP_DIR='' and the [[ -z ]] guard makes it a no-op.
  trap 'cleanup $?' SIGINT SIGTERM EXIT

  TEMP_DIR=$(mktemp -d -t "$SCRIPT_NAME.XXXXXX") \
    || die 1 'mktemp -d failed'

  # ... use $TEMP_DIR throughout the script ...
  printf 'header\n' >"$TEMP_DIR"/work.txt
  process_things "$TEMP_DIR"

  # No explicit `rm -rf` here. The EXIT trap handles success and failure
  # paths uniformly; sprinkling cleanup code mid-script is the bug, not
  # the feature.
}

process_things() {
  local -- workdir=$1
  # ... operate on files inside $workdir ...
  printf 'processed in %s\n' "$workdir"
}

main "$@"
#fin
```

The order of operations is load-bearing. The trap is installed *before*
`mktemp` runs, so even a failed `mktemp` triggers `cleanup` (which
no-ops because `TEMP_DIR` is still empty). The trap captures `$?` at
the call site, not inside `cleanup`, because `trap - … EXIT` clobbers
`$?` with its own exit status. Disarming the trap as the first line of
`cleanup` prevents recursion if `rm -rf` itself somehow generates a
signal. The double-dash on `rm -rf -- "$TEMP_DIR"` defends against the
near-impossible but catastrophic case where `mktemp` returns a path
beginning with `-`.

`mktemp -d -t TEMPLATE` honours `$TMPDIR` when set, falling back to
`/tmp`; on systemd-managed services this often points to a per-service
private tmpfs that vanishes when the unit stops, which is exactly what
you want. Avoid hardcoding `/tmp`.

**Common bug: cleaning up mid-script.**

```bash
# wrong — multiple cleanup sites that disagree on exit paths.
TEMP_DIR=$(mktemp -d)
do_step_one "$TEMP_DIR" || { rm -rf "$TEMP_DIR"; exit 1; }
do_step_two "$TEMP_DIR" || { rm -rf "$TEMP_DIR"; exit 1; }
do_step_three "$TEMP_DIR"          # forgot the cleanup on this path
rm -rf "$TEMP_DIR"

# correct — single trap, single cleanup site, every exit path covered.
trap 'rm -rf -- "$TEMP_DIR"' EXIT
TEMP_DIR=$(mktemp -d)
do_step_one "$TEMP_DIR"
do_step_two "$TEMP_DIR"
do_step_three "$TEMP_DIR"
```

**See also**: §12.13 for the full discussion of temp-resource
lifecycles, multi-resource cleanup composition, and why a *single*
cleanup function beats stacked traps. BCS0110 (cleanup-and-traps),
BCS0603 (trap handling), and BCS1006 (temporary-file handling) state
the rule-level requirements.

#fin
