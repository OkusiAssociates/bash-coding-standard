<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.5 `set -o pipefail`

`set -o pipefail` changes a pipeline's exit status from "status of the
last component" to "status of the rightmost non-zero component, or zero
if all succeed". Without it, `false | true` returns 0 and errexit never
sees the failure. With it, the same pipeline returns 1 and errexit
fires. This chapter covers the rule, the `PIPESTATUS[]` array used to
inspect every component, and the SIGPIPE corner case that surprises
everyone the first time.

### The rightmost-non-zero rule

A pipeline `A | B | C | D` produces four exit statuses, one per
component, available in the array `PIPESTATUS[]` as `${PIPESTATUS[0]}`
through `${PIPESTATUS[3]}`. The pipeline's overall status is then:

- Without `pipefail`: `${PIPESTATUS[3]}` (the last component).
- With `pipefail`: 0 if all are 0; otherwise `${PIPESTATUS[k]}` where
  `k` is the *highest* index whose status is non-zero — that is, the
  *rightmost* failure.

"Rightmost non-zero" is the rule literally; do not read it as
"first failure". A pipeline `false | false-2 | false-3` returns the
status of `false-3`, even though `false` failed first. If you need
"first failure" semantics, inspect `PIPESTATUS[]` manually after the
pipeline.

```bash
# scenario: three pipelines under pipefail; observe overall status and PIPESTATUS
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# All-success
true | true | true
echo "all-ok rc=$? PIPESTATUS=${PIPESTATUS[*]}"   # ⇒ rc=0 PIPESTATUS=0 0 0

# Middle fails
true | false | true
echo "mid-fail rc=$? PIPESTATUS=${PIPESTATUS[*]}" # ⇒ rc=1 PIPESTATUS=0 1 0

# Multiple fail — rightmost wins
false | false | (exit 7)
echo "many-fail rc=$? PIPESTATUS=${PIPESTATUS[*]}" # ⇒ rc=7 PIPESTATUS=1 1 7
```

(Above runs without `set -e` so we can read all three; under `set -e`
the script would exit at the first non-zero pipeline.)

### `PIPESTATUS[]` discipline

`PIPESTATUS[]` is overwritten by the *next* pipeline (and by most
single commands too — it gets reset to a one-element array holding
`$?`). Capture immediately after the pipeline:

```bash
# scenario: capture full pipeline status before it is clobbered
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

curl -sf "$url" | jq -e '.records[]' | head -50
declare -ai rcs=("${PIPESTATUS[@]}")          # snapshot now or lose it

if (( rcs[0] != 0 )); then
  die 5 "curl failed: rc=${rcs[0]}"
elif (( rcs[1] != 0 )); then
  die 5 "jq failed: rc=${rcs[1]}"
elif (( rcs[2] != 0 )); then
  die 5 "head failed: rc=${rcs[2]}"
fi
```

Even a trivial-looking command on the very next line — `[[ -n $x ]]` —
will replace `PIPESTATUS[]` with `[0]=0`, losing the upstream
information. Snapshot first, decide second.

### SIGPIPE and `head | sort | …` interactions

SIGPIPE (signal 13) is delivered to a pipeline component when its
downstream reader closes. The default disposition is "terminate", and
the resulting exit status is 128+13 = 141. Under `pipefail`, this 141
becomes the pipeline's status — `cat huge.log | head -1` exits 141 if
`cat` is killed by SIGPIPE after `head` quits.

```bash
# scenario: SIGPIPE poisons pipefail unless guarded
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
yes | head -1 >/dev/null
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=141 PIPESTATUS=141 0   — yes was killed by SIGPIPE
```

This is "correct" behaviour but inconvenient: the pipeline did exactly
what was asked, yet the script exits 141 under `set -e -o pipefail`.
Mitigations:

- Tolerate it: `cat file | head -1 || (( $? == 141 ))` — accept 141
  as success.
- Restructure: `head -1 file` instead of `cat file | head`.
- Suppress per-component: `{ trap '' PIPE; cat file; } | head -1`
  installs `SIG_IGN` on PIPE for the producer; `cat` then sees a write
  error and exits non-zero with errno EPIPE rather than dying on
  signal. Status becomes 1 (or whatever `cat` reports), still surfaced
  by pipefail.
- Capture and check: snapshot `PIPESTATUS[]` and treat 141 specially.

Most idiomatic bash chooses the first or second option. The third is
necessary only when a long-running producer needs to remain alive
after the consumer quits.

### Interaction with `errexit`

`pipefail` *does not* by itself exit on failure; it only re-defines the
pipeline's exit status. Errexit then sees that status as it would any
other and applies the matrix (§13.3). The combination is:

- `set -e` alone: pipelines fail only on last-component failure.
- `set -e -o pipefail`: pipelines fail on any component failure.
- `set +e -o pipefail`: pipelines have correct status, but errexit
  ignores it; the script must inspect `$?` or `PIPESTATUS[]` manually.

`pipefail` applies inside command substitutions, subshells, and
function bodies — it is a shell option, inherited along with the rest
of strict-mode state.

### Pipelines vs lists

`A; B; C` is a *list*, not a pipeline. `pipefail` does not apply.
Errexit visits each command in turn and exits on the first non-zero
that is not in an exempt context.

`A && B && C` is also not a pipeline. Each is a separate command;
errexit sees them per the matrix (§13.3 row 1).

### Practical guidance

Always pair `pipefail` with `errexit` and `inherit_errexit`. The BCS
strict-mode preamble does this. Without `pipefail`, error-detection
through pipes is silently broken, and bugs migrate from the producing
side to whatever happens to read its output last. With it, every
pipeline component is a first-class participant in error handling.

When inspecting `PIPESTATUS[]`, snapshot immediately. When SIGPIPE is
expected, plan for 141 explicitly — do not silently `|| true` it,
because that mask hides every other pipeline failure too.

**See also**: §13.2 (errexit semantics), §13.3 (exemption matrix row
6), §13.6 (inherit_errexit), §13.9 (strict-mode contract), §13.11
(propagation), §12.3 (uncatchable signals — SIGPIPE catchability),
BCS0101 (strict mode), BCS0601 (exit on error), BCS-bash
`30_43_set.md`.

#fin
