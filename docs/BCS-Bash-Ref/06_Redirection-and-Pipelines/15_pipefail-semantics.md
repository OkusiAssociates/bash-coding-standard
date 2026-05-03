<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.15 `pipefail` semantics

`set -o pipefail` redefines a pipeline's exit status from "the
rightmost component's status" to "the rightmost *non-zero* component's
status, or zero if every component succeeded". Without it, error
detection through pipes is silently broken: `false | true` returns 0
and any subsequent `set -e` check passes blithely. With it, the same
pipeline returns 1 and `errexit` fires. `pipefail` is one third of the
strict-mode trio — `set -e -o pipefail` plus `shopt -s inherit_errexit`
— mandated for every BCS-compliant script (BCS0101).

### The rightmost-non-zero rule

A pipeline of `N` components produces `N` exit statuses, one per
component, available in `${PIPESTATUS[0]}` through
`${PIPESTATUS[N-1]}`. The pipeline's overall status is then:

- Without `pipefail`: `${PIPESTATUS[N-1]}` — only the last component.
- With `pipefail`: 0 if all are 0; otherwise `${PIPESTATUS[k]}` where
  *k* is the *highest* index whose status is non-zero — that is, the
  *rightmost* failure.

"Rightmost non-zero" is the rule literally; it is *not* "first
failure". `false | (exit 3) | (exit 7)` returns 7, not 1.

### The strict-mode trio in action

`pipefail` alone changes only the pipeline's status; it does not
trigger an exit. `errexit` then sees the new status and applies the
exemption matrix as it would for any other command. `inherit_errexit`
ensures the rule survives into command substitutions and explicit
subshells:

```bash
# scenario: the trio in action — trace pipeline status under each combination
#!/usr/bin/env bash
# (no `set -e` yet — we want to read each result)
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# All-success
true | true | true
echo "all-ok        rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ all-ok        rc=0 PIPESTATUS=0 0 0

# Middle fails — pipefail surfaces it
true | false | true
echo "mid-fail     rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ mid-fail     rc=1 PIPESTATUS=0 1 0

# Without pipefail — same pipeline appears successful
set +o pipefail
true | false | true
echo "no-pipefail  rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ no-pipefail  rc=0 PIPESTATUS=0 1 0   — failure invisible in $?

# Multiple failures — pipefail picks the rightmost
set -o pipefail
false | (exit 3) | (exit 7)
echo "many-fail    rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ many-fail    rc=7 PIPESTATUS=1 3 7
```

Once `set -e` is also active, every non-zero pipeline result aborts the
script — exactly the behaviour BCS demands.

### Interaction with `set -e`

`pipefail` *does not* by itself exit on failure. It re-defines the
pipeline's exit status; `errexit` then decides whether to abort, using
the standard exemption matrix:

| Form | Without pipefail | With pipefail (under set -e) |
|------|------------------|-------------------------------|
| `a \| b` (b succeeds) | exits 0 | exits 0 if a also succeeds, else aborts |
| `a \| b` (a fails) | exits 0 (silent loss) | aborts on a's failure |
| `a \| b \|\| handler` | handler runs only if b fails | handler runs on any failure |
| `if a \| b; then …` | tested on b's status | tested on rightmost-non-zero |

The most useful pattern is the ` \|\| handler` tail: a failed pipeline
followed by `\|\| handler` masks the failure cleanly without disabling
`pipefail` globally:

```bash
# scenario: handle expected SIGPIPE-style failures locally without disabling pipefail
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# `head` quitting after the first match causes upstream SIGPIPE → 141.
# Tolerate it for THIS pipeline only.
{ producer | filter | head -1; } || (( $? == 141 )) || die 5 "pipeline failed"
# ⇒ rc=141 accepted; any other non-zero status aborts via die

# Alternative: capture and inspect PIPESTATUS for finer control
producer | filter | head -1 || true
declare -ai rcs=("${PIPESTATUS[@]}")
(( rcs[0] == 0 || rcs[0] == 141 )) || die 5 "producer failed"
(( rcs[1] == 0 || rcs[1] == 141 )) || die 5 "filter failed"
```

The `|| (( $? == 141 ))` idiom is the standard escape hatch when a
pipeline's tail (`head`, `grep -q`, `awk 'NR==1{exit}'`) is *expected*
to terminate early.

### Pipelines vs lists

`a; b; c` is a *list*, not a pipeline; `pipefail` does not apply.
Errexit visits each command in turn. Likewise `a && b && c` is not a
pipeline — each command is separate, each subject to errexit on its own
status. `pipefail` only governs the `|`-connected case.

### Practical guidance

Always pair `pipefail` with `errexit` and `inherit_errexit` (BCS0101).
Without `pipefail`, error detection through pipes is silently broken,
and bugs migrate from the producing side to whichever component happens
to read last. With it, every component is a first-class participant in
error handling.

When SIGPIPE is expected (rc 141), plan for it explicitly — do not
silently `|| true` a pipeline, because that mask hides every other
failure too.

**See also**: §6.13 (pipelines), §6.16 (`lastpipe`), §13.2 (errexit
semantics), §13.3 (errexit exemption matrix), §13.5 (`set -o pipefail`
deep dive), §13.9 (strict-mode contract), BCS0101, BCS0601.

#fin
