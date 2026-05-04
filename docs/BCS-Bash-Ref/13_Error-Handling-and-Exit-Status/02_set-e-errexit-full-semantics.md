<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.2 `set -e` (errexit) — full semantics

`set -e` (equivalently `set -o errexit`) is the most-misunderstood feature
in bash. It does not "exit on any error". It exits when an unchecked
*simple command*, *pipeline*, or *list* returns a non-zero status from a
context that is not exempt. The exemption matrix in §13.3 is canonical;
this chapter establishes the underlying mechanics so the matrix reads as
consequence rather than convention.

### What `errexit` actually triggers on

Bash evaluates a command and, if that command's final exit status is
non-zero, asks two questions: (1) is the command in an exempt context?
(2) is errexit *currently* in force? Only if the answer to both is "no
exempt, yes in force" does bash run the ERR trap (§13.8) and exit with
the failed command's status. Errexit is not a hook fired from the kernel
or a wrapper around `wait()`; it is a check inside bash's own command
dispatcher, which is why its rules are syntactic and rooted in how a
command was invoked rather than what it does.

The shell-level definition is: errexit exits the shell when a command's
exit status, after the shell has computed it, is non-zero — *unless* the
command is part of one of the exempt structures enumerated in §13.3.

```bash
# scenario: minimal demo — the simple-command rule
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
echo "before"
false                                # ⇒ shell exits here, $? = 1
echo "after"                         # ⇒ never printed
```

### Pipelines

A pipeline's exit status is the status of its **last** component (the
"rightmost" rule). Without `pipefail` (§13.5), a pipeline like
`false | true` returns 0, so errexit will not fire. With `pipefail`, the
pipeline returns the rightmost *non-zero* status, so the same pipeline
returns 1 and errexit fires. The check is on the pipeline's final status,
not on any intermediate component.

```bash
# scenario: pipeline status without and with pipefail
set -e                      # no pipefail
false | true; echo "$?"     # ⇒ 0  — script continues, no exit
set -o pipefail
false | true                # ⇒ exits, status 1
```

### Compound commands and lists

For `if`, `while`, `until`, `&&`, `||`, the *condition* command's failure
is examined deliberately by the construct itself. Errexit therefore must
not act on it — otherwise `if grep -q foo file; then …` would exit on
absence of `foo`. Inside the *body* of `if/while/until`, errexit is fully
active again (this is the rule readers most often forget). For `&&` and
`||`, only the **left** operand of the leftmost operator is exempt; once
the chain has resolved to a single status, errexit applies.

The bash 5.2 manual phrases this as "the shell does not exit if the
command that fails is part of the command list immediately following a
`while` or `until` keyword, part of the test in an `if` statement, part
of any command executed in a `&&` or `||` list except the command
following the final `&&` or `||`, any command in a pipeline but the last,
or if the command's return status is being inverted with `!`."

### Functions, subshells, and command substitution

When a function is invoked, its body executes with errexit's *effective*
state determined by the call site: a function called from an exempt
context (e.g. as the condition of `if`) inherits that exemption — its
internal `set -e` does not save it, because the failure status will be
absorbed by the surrounding construct. This is the single most common
"why didn't `set -e` exit my function?" complaint.

Subshells (`( ... )`) and command substitutions (`$(...)`) have their own
errexit state. By default it is *not* inherited from the parent. Bash 4.4
introduced `shopt -s inherit_errexit` (§13.6) which fixes the substitution
case; subshells must be handled by repeating `set -e` inside, or by
ensuring their parent context will detect a non-zero exit.

```bash
# scenario: function called as if-condition — errexit is dormant
fail_if_missing() {
  set -e
  test -f "$1"               # would normally exit on absence
  echo "found: $1"           # but it does NOT — errexit is dormant
}
if ! fail_if_missing /no/such/file; then
  echo "function returned non-zero, but did not exit shell"
fi
# ⇒ found: /no/such/file
# ⇒ (the `if !` branch does NOT fire — echo's exit 0 masks the test failure)
```

### Exit status that propagates

When errexit fires, the shell exits with the *failing command's* status,
not 1. This is load-bearing: callers can switch on the exit code to
distinguish e.g. usage error (2) from I/O failure (5) from missing
dependency (18) (§13.10). Inside an ERR trap (§13.8), `$?` holds the
failing status and `$BASH_COMMAND` holds the literal command text.

### Toggling errexit

`set +e` disables errexit; `set -e` re-enables. The common idiom is to
disable around a block where individual exit codes are inspected
manually, then re-enable:

```bash
# scenario: targeted disable for code-by-code inspection
set +e
output=$(some_command --probe)
rc=$?
set -e
case $rc in
  0)  : ok ;;
  3)  warn "probe missing — continuing" ;;
  *)  die 5 "probe failed: rc=$rc" ;;
esac
```

The `||` idiom (§13.7) is normally cleaner: `output=$(some_command || true)`.

### Interaction with `return` and `exit`

`return N` from a function yields exit status `N` for the function call.
If the call is in an unexempted context and `N` is non-zero, errexit will
fire. `exit N` ends the *current* shell (or subshell) immediately,
regardless of errexit. Inside a subshell, `exit` ends the subshell; the
parent's errexit then applies to the subshell's exit status as a normal
simple-command failure.

### What errexit does **not** do

- It does not catch errors *inside* command substitutions unless
  `inherit_errexit` is set (§13.6). `result=$(grep foo file)` happily
  swallows `grep`'s exit status by default.
- It does not catch errors that the syntax marks as deliberately
  inspected (the exemption matrix in §13.3).
- It does not run the ERR trap on `exit N` calls — those bypass errexit
  entirely. The EXIT trap (§12.6) does fire on `exit`.
- It does not survive arithmetic that evaluates to zero. `(( count++ ))`
  when `count==0` returns status 1 and triggers errexit — this is a
  documented gotcha. Use `count+=1` or `(( ++count ))` (BCS0505).
- It does not unwind nested function calls cleanly: each function frame
  collapses with the failing status, and the shell exits at the
  outermost frame. Cleanup must be done via the EXIT trap (§12.6) or
  per-frame ERR handlers.

### Diagnosing "errexit didn't fire"

Run through this short checklist when a non-zero command failed to halt
the script:

1. Confirm `set -e` is actually in force at that line. `set -o |
   grep errexit` (or `[[ $- == *e* ]]`) reports the current state.
   `set +e` or a sourced helper that toggles errexit may have left it
   off.
2. Inspect the surrounding syntax. Is the failing command in any of
   the rows of the §13.3 matrix? Most "didn't fire" reports collapse
   to row 1 (left of `&&`/`||`), row 5 (non-final pipeline component
   without `pipefail`), or row 7 (inside `$(...)` without
   `inherit_errexit`).
3. Check function-call context. If the command is inside a function
   and the function was called from an exempt position, errexit is
   suspended for the duration.
4. Check for `local x=$(failing)` — this single-line pattern destroys
   the substitution's exit status (§13.11). The fix is to declare and
   assign on separate lines.

If none of the above explains it, the failing command may have a
non-obvious exemption — `(( expr ))` evaluating to zero is the prime
suspect (§13.3 row 10).

### Practical guidance

`set -e` alone is brittle. The BCS strict-mode contract pairs it with
`set -u` (§13.4), `set -o pipefail` (§13.5), `inherit_errexit` (§13.6),
and an ERR trap or EXIT trap for diagnostics (§13.8, §12.6). Together
they form a defensible error-detection regime; alone, errexit invites
the cargo-cult complaint that "`set -e` is broken". It is not broken —
it is precise, and the exemption matrix (§13.3) is its specification.

For functions intended to fail loudly even when called as conditions,
prefer explicit checks: `result=$(cmd) || die 5 "cmd failed"`. For
library code, see §13.11 for the canonical exit-code propagation
patterns.

**See also**: §13.3 (exemption matrix), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.11 (propagating exit codes),
§12.6 (EXIT and ERR pseudo-signals), BCS0101 (strict mode), BCS0601
(exit on error), BCS0505 (arithmetic gotchas), BCS-bash `30_43_set.md`.

#fin
