<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.3 The errexit exemption matrix

The contexts in which `set -e` does *not* exit on a non-zero status.
Memorise this list — it is the single largest source of "set -e didn't
trigger" complaints. This chapter is the canonical reference; §13.2
establishes the underlying mechanics, and every other §13 leaf forwards
to a row here.

### The matrix

| # | Context | Errexit fires? | Why |
|---|---------|----------------|-----|
| 1 | Left of `&&` or `||` | No | The operator deliberately inspects the status |
| 2 | Condition of `if`, `elif` | No | The construct deliberately inspects the status |
| 3 | Condition of `while`, `until` | No | Same as above; loops on the test |
| 4 | `!`-prefixed command (negation) | No | Inversion implies inspection |
| 5 | Pipeline component, not the last (no `pipefail`) | No | Pipeline status is the last component |
| 6 | Pipeline component, not the last (with `pipefail`) | Pipeline-level | Errexit fires once on the pipeline's overall status |
| 7 | Command substitution `$(...)` (no `inherit_errexit`) | No | Subshell errexit is fresh-disabled |
| 8 | Command substitution `$(...)` (with `inherit_errexit`) | Yes | Subshell inherits parent's errexit |
| 9 | Function called from any exempt context (1-5, 7) | No | Exemption propagates to the call's status |
| 10 | `(( expr ))` evaluating to 0 — counts as failure | Yes (gotcha) | Arithmetic 0 is shell "false" |
| 11 | `let expr` evaluating to 0 — same | Yes (gotcha) | Same as 10 |
| 12 | `[[ ... ]]` test returning false | Yes | Exits unless wrapped per rows 1-4 |
| 13 | Command in an explicit subshell `( ... )` | Subshell-local | Subshell exits; parent then sees its status per rows 1-9 |

Rows 1-9 are the *true* exemptions: errexit cannot fire there at all
(or, for row 6, fires only once at pipeline level rather than per
component). Rows 10-12 are the *anti*-exemptions — places novice
authors expect leniency but get strictness. Row 13 is structural: a
subshell has its own errexit decision, after which the parent applies
errexit to the subshell's overall exit status.

### Worked demonstrations

Each of these scripts assumes the BCS strict-mode preamble. The
question in every case is: does errexit fire?

```bash
# scenario: row 1 — left side of && / ||
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
false && echo unreached       # ⇒ does NOT exit; left of && is exempt
false || echo "fallback"      # ⇒ does NOT exit; left of || is exempt
true && false                 # ⇒ EXITS; right of && is NOT exempt
echo "unreached"              # ⇒ never printed
```

The asymmetry on `&&`/`||` is the most-cited footgun: the *left* operand
is exempt, the *right* (final) operand is not. Chaining `cmd1 && cmd2`
does not protect `cmd2`; protect it with `cmd2 || true` or by including
the whole chain in an exempt position.

```bash
# scenario: row 2-3 — condition of if/while/until
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
if grep -q nonexistent-token /etc/hostname; then  # grep failure is NOT a script error
  echo found
else
  echo "no match — script continues despite grep rc=1"
fi
# `! cmd` in a `while` head is exempt; the negated test is exempt from errexit.
if ! mountpoint -q /mnt 2>/dev/null; then         # one-shot demo of the exemption
  echo "/mnt is not a mountpoint and we kept going"
fi
echo "ran past both"
# ⇒ no match — script continues despite grep rc=1
# ⇒ /mnt is not a mountpoint and we kept going
# ⇒ ran past both
```

The body of `if`/`while`/`until` is *not* exempt — only the test
expression. A failing command inside the body triggers errexit
normally.

```bash
# scenario: row 5-6 — pipeline non-final positions
#!/usr/bin/env bash
set -e                                 # no pipefail
false | true; echo "rc=$?"             # ⇒ rc=0 — pipeline succeeded overall
set -o pipefail
false | true                           # ⇒ EXITS at this line, status 1
```

Without `pipefail`, errexit looks only at the rightmost component. With
`pipefail`, errexit looks at the pipeline as a whole; any non-zero
component status surfaces and the script exits. See §13.5 for the full
treatment.

```bash
# scenario: row 7-8 — command substitution
#!/usr/bin/env bash
set -e                                 # NO inherit_errexit
result=$(grep nope /etc/hostname; echo "after")  # grep fails; echo runs
echo "result=$result"                  # ⇒ result=after — script keeps going
shopt -s inherit_errexit
result=$(grep nope /etc/hostname; echo "after")  # ⇒ EXITS inside $()
```

`inherit_errexit` is the fix for the canonical "my script swallowed an
error" bug: without it, command substitutions silently absorb every
internal failure (§13.6).

```bash
# scenario: row 9 — function called from an exempt context
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
f() { false; echo "f reached after-false"; }
if f; then echo "f succeeded"; else echo "f returned non-zero"; fi
# ⇒ "f reached after-false"  ⇒ "f returned non-zero"
# Inside f, set -e is dormant because the call site is the if-condition.
f                                       # ⇒ EXITS — same f, non-exempt context
```

This is the source of the "my function suddenly stopped exiting" bug
when a previously-direct call is moved under an `if`. The function
*body's* errexit is suppressed by the call-site exemption.

```bash
# scenario: rows 10-11 — arithmetic-zero gotcha
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
declare -i count=0
(( count++ ))                          # ⇒ EXITS — post-inc returns old value 0
echo "unreached"
# Fixes:
(( ++count ))                          # ⇒ pre-inc returns new value 1; safe
count+=1                               # ⇒ assignment, not arithmetic test; safe
(( count++ )) || true                  # ⇒ explicit pardon
```

`(( expr ))` and `let expr` use the result of `expr` as the command's
exit status with the convention "0 → false → exit 1, non-zero → true →
exit 0". This is *opposite* to most shell semantics. BCS0505 mandates
`+= 1` over `((var++))` precisely to avoid this trap.

```bash
# scenario: row 13 — explicit subshell
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
( false; echo "subshell after-false" )   # ⇒ subshell EXITS on false
echo "parent rc=$?"                       # ⇒ parent rc=1; parent then exits
```

A subshell is a fresh shell process; its errexit applies inside. Once
the subshell ends, its overall exit status is treated as a single
command's status by the parent shell, where rows 1-9 apply.

### Reading the matrix as a checklist

When debugging "why didn't `set -e` exit?", walk the matrix top-to-bottom:

1. Is the failing command the left of `&&`/`||`? — exempt.
2. Is it inside an `if`/`while`/`until` test? — exempt.
3. Is it `!`-prefixed? — exempt.
4. Is it a non-final pipeline component without `pipefail`? — exempt.
5. Is it inside `$(...)` without `inherit_errexit`? — exempt.
6. Is the surrounding *function call* in an exempt context? — exempt.
7. Otherwise it should have fired; check the trap (§13.8) and ensure
   `set -e` is actually in force at that line (`set -o | grep errexit`).

### Composition with strict-mode allies

The matrix is normative when the script runs the BCS strict-mode
contract. With only `set -e` and none of `pipefail`/`inherit_errexit`,
rows 6 and 8 collapse to the more-permissive variants and the script's
error-detection coverage is materially reduced. §13.9 inlines the full
contract.

**See also**: §13.2 (errexit semantics), §13.5 (pipefail), §13.6
(inherit_errexit), §13.7 (`||:` idioms), §13.9 (strict-mode contract),
§13.11 (propagating exit codes), §12.6 (ERR pseudo-signal), BCS0101,
BCS0505 (arithmetic), BCS-bash `30_43_set.md`.

#fin
