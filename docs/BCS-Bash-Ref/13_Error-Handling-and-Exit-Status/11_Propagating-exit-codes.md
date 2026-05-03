<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.11 Propagating exit codes

A function or pipeline must surface a meaningful exit code to its
caller. Bash's defaults — last command's status as the function's
status, last component's status as the pipeline's — are mostly right
but several patterns silently destroy the information. This chapter
covers the canonical capture-and-propagate forms, including the
`local x=$(failing)` error-eating gotcha that bites every bash author.

### Bash's exit-status conventions

Bash's own definition (BCS-bash `23_EXIT-STATUS.md`): a command's exit
status is an 8-bit integer (0-255). Zero means success; non-zero means
failure. Selected codes have customary meaning:

| Code | Meaning | Origin |
|------|---------|--------|
| 0 | Success | universal |
| 1 | General error | universal default |
| 2 | Usage error | BCS0602; some POSIX utilities |
| 3 | File not found | BCS0602 |
| 5 | I/O error | BCS0602 |
| 13 | Permission denied | BCS0602; mirrors `EACCES` |
| 18 | Missing dependency | BCS0602 |
| 22 | Invalid argument | BCS0602; mirrors `EINVAL` |
| 24 | Timeout | BCS0602 |
| 126 | Found but not executable | bash convention |
| 127 | Command not found | bash convention |
| 128+N | Killed by signal N | bash convention (e.g. 130 = SIGINT) |

Choose the closest match from BCS0602; reserve 1 for genuinely
"general" errors that do not fit a more specific code. Wrappers such
as `die 5 "io error: $path"` (BCS0703 messaging) use these directly.

### The `local x=$(failing)` error-eating gotcha

This is the canonical demo every bash author needs to see at least
once:

```bash
# scenario: WRONG — local masks the substitution's exit status
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

probe() {
  local -- result=$(grep -c nonexistent /etc/hostname)   # BUG
  # local's own exit status is 0 (the assignment succeeded).
  # The substitution's failure is invisible to errexit.
  echo "result=$result"
}
probe                                  # ⇒ "result=0" — keeps going!
```

`local x=$(cmd)` (or `declare`, `readonly`, `export` with an
assignment) is a *single command* whose exit status is the status of
the builtin (`local`/`declare`/etc.), not of the right-hand side.
`local` succeeds as long as the variable name is valid, so the
substitution's failure is silently absorbed. `inherit_errexit`
(§13.6) does not save you here, because the substitution *did* exit
with status 1 — but that status was overwritten by `local`'s own 0.

The fix is to *split* declaration from assignment:

```bash
# scenario: RIGHT — declare first, assign separately
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

probe() {
  local -- result                      # declare; rc=0 trivially
  result=$(grep -c nonexistent /etc/hostname)   # rc propagates; errexit fires
  echo "result=$result"                # ⇒ unreached
}
probe
echo "unreached"
```

After splitting, the assignment statement's exit status *is* the
substitution's exit status (with `inherit_errexit`), and errexit
catches it. This pattern (declare first, assign second) is BCS0201
canon for any command-substitution capture.

The same hazard applies to `readonly`, `export`, and `declare` with an
assignment. The same fix applies: declare alone, then assign.

### Capturing exit codes deliberately

When a non-zero status is *expected* and must be inspected, capture it
into a variable immediately. The capture must be the very next
statement — even an `[[ ]]` test will overwrite `$?`.

```bash
# scenario: capture rc immediately, branch on it
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

run_probe() {
  local -i rc=0
  some_probe --quiet || rc=$?          # || disables errexit; rc holds status
  case $rc in
    0)  return 0 ;;
    3)  warn "probe missing — continuing"; return 0 ;;
    24) die 24 "probe timed out" ;;
    *)  die 5 "probe failed: rc=$rc" ;;
  esac
}
```

`cmd || rc=$?` is the canonical form: it disables errexit for that
command (matrix row 1), captures the status, and lets the next
statement act on it. Followed by an explicit `case` or `if`, it gives
the caller full control while still surfacing a meaningful exit code.

### Pipelines

The pipeline's overall exit status is in `$?` immediately after the
pipeline; per-component statuses are in `PIPESTATUS[]` (§13.5).
`PIPESTATUS[]` is overwritten by the next pipeline (and by most other
commands). Snapshot first:

```bash
# scenario: pipeline rc + per-component rc — captured before clobber
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
process() {
  local -i rc=0
  curl -sf "$1" | jq -e '.records[]' | head -50 || rc=$?
  local -ai rcs=("${PIPESTATUS[@]}")   # snapshot intact
  if (( rcs[0] )); then return 5; fi   # curl
  if (( rcs[1] )); then return 22; fi  # jq — invalid input
  return $rc
}
```

### Background jobs

For `cmd & pid=$!`, the background job's exit status is recovered with
`wait "$pid"`; the wait's return value is the job's status. Without
`wait`, the status is lost when the job's bookkeeping is reaped.
`wait -n` returns the next-completing job's status; `wait` (no args)
waits for all and returns the last's status. See §11 (concurrency).

### Functions and `return`

A function's implicit exit status is its last command's status. To
propagate explicitly, use `return $rc` after a capture, or arrange
the last command to be the one whose status you want surfaced.
`return` *requires* a non-negative integer 0-255; a string or negative
value triggers a syntax error (or, in some bash versions, silently
becomes 255).

The BCS template for functions that may fail:

```bash
do_thing() {
  local -- input="${1:?do_thing: input required}"
  local -i rc=0
  some_command --in "$input" || rc=$?
  if (( rc )); then
    error "some_command failed: rc=$rc"
    return $rc
  fi
  return 0
}
```

### Through `||` and `&&`

`cmd || cleanup; return $?` is a common bug: `cleanup`'s status
overwrites `cmd`'s. Capture first:

```bash
cmd || { rc=$?; cleanup; return $rc; }
```

Inside the `{ ... }` block, `cleanup`'s exit is irrelevant; only `rc`
matters. This is the canonical "rescue" idiom and the only correct
shape when cleanup has its own non-zero potential.

### Practical guidance

Three rules cover 95% of cases:

1. Never assign a command substitution on the same line as `local`,
   `declare`, `readonly`, or `export` (BCS0201).
2. Capture `$?` and `PIPESTATUS[]` immediately, before any other
   command runs.
3. Choose the exit code from BCS0602 that best describes the failure;
   reserve 1 for the residue.

**See also**: §13.2 (errexit), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.10 (exit-code conventions),
§13.12 (rich error output), §11 (concurrency / wait), BCS0201
(declarations), BCS0602 (exit codes), BCS0703 (messaging),
BCS-bash `23_EXIT-STATUS.md`.

#fin
