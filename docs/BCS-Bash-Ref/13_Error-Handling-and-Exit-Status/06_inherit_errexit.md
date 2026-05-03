<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.6 `inherit_errexit`

`shopt -s inherit_errexit` (bash 4.4+) propagates `errexit` into command
substitutions. Without it, every `$(...)` is a fresh subshell with
`set -e` *off*, regardless of the parent's setting. This is the
single most-confusion-causing default in bash strict mode, and the
reason a script with the textbook `set -e` line still silently
swallows errors.

### The bug magnet

`$(...)` runs its body in a subshell. By long-standing default, that
subshell's errexit state is reset to off, even when the parent has
`set -e`. The result: a command substitution that *contains* a
failing pipeline, sequence, or simple command runs to completion and
returns whatever the *last* command of the substitution produced. The
parent script sees only the resulting string and the substitution's
overall exit status (last command's status), and has no way to know
that an interior command failed.

This is why "I have `set -e` and my script still ignores errors!" is
the most-asked bash question on every Q&A site. The answer is almost
always: "the failure was inside `$(...)`."

### Before-and-after demo

```bash
# scenario: WRONG — without inherit_errexit, $() swallows interior failures
#!/usr/bin/env bash
set -euo pipefail                         # NOTE: no shopt -s inherit_errexit

result=$(grep nonexistent /etc/hostname; echo "fallback")
echo "result=[$result]"
# ⇒ result=[fallback]
# grep failed (rc=1), but the substitution kept running, ran echo,
# and the substitution's overall status is echo's status (0).
# Parent set -e never sees the grep failure.
```

```bash
# scenario: RIGHT — with inherit_errexit, $() exits on interior failure
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

result=$(grep nonexistent /etc/hostname; echo "fallback")
# ⇒ EXITS at the assignment line; the substitution's grep failed,
# the substitution-shell exits with grep's status (1), the parent
# sees rc=1 from $(...), and errexit fires on the assignment.
echo "unreached"
```

The two scripts differ only by the `shopt -s inherit_errexit` line.
The behavioural divergence is total: the first happily proceeds with a
nonsense value, the second halts loudly. BCS strict mode requires the
second.

### What `inherit_errexit` changes

The shopt enables `set -e` *inside* the subshell created for command
substitution. It does not affect:

- Explicit subshells `( ... )`. Those receive errexit by inheritance
  already in modern bash; the default was changed long before
  `inherit_errexit` was introduced.
- Pipeline component subshells. Each component runs in its own
  subshell; pipefail handles those, not `inherit_errexit`.
- Background `&` subshells. Those run independently; their status is
  observed via `wait`.
- Process substitutions `<(...)` / `>(...)`. Those run in subshells
  too, and have *no* status-propagation mechanism back to the parent.
  This is a known limitation of process substitution; see §11 (Process
  Substitution) for workarounds.

### Why it is not the default

Historical bash (pre-4.4) ran every command substitution with errexit
off because POSIX did not require otherwise and many scripts relied
on the leniency. Making `inherit_errexit` the default would break those
scripts. Bash therefore ships it as opt-in, with the BCS contract
(§13.9) opting in unconditionally. There is no scenario in
greenfield strict-mode bash where the default-off behaviour is
desirable.

### Idioms that need adjustment

A few patterns that worked under the old default are wrong under
`inherit_errexit`:

- `result=$(maybe_fail || echo "default")` — fine; the `||` provides
  the exemption (§13.3 row 1).
- `result=$(grep -c foo file)` where 0 matches is acceptable — needs
  `result=$(grep -c foo file || true)` because grep returns 1 on no
  match, and now propagates.
- `result=$(cmd 2>&1)` where `cmd` may legitimately fail and you want
  the diagnostic — same: append `|| true` (or capture rc explicitly:
  `if result=$(cmd 2>&1); then ...; else rc=$?; ...; fi`).

The general migration rule: any command substitution whose contents
may legitimately exit non-zero must say so with `|| true`, `||` plus a
fallback, or an explicit `if` capture.

### Interaction with traps

The ERR trap (§13.8) fires for the failure inside `$(...)` *if*
`errtrace` (`set -E`) is also set (§13.9). The EXIT trap fires for
the substitution-shell as it ends, but does not fire the parent's EXIT
trap — only the parent's own exit does that.

### Practical guidance

Treat `inherit_errexit` as load-bearing. Removing it from a strict-mode
contract reintroduces the canonical "silently ignored error" footgun.
The BCS contract (§13.9) makes it mandatory; every BCS template ships
with it.

**See also**: §13.2 (errexit semantics), §13.3 (exemption matrix row
7-8), §13.5 (pipefail), §13.8 (ERR trap), §13.9 (strict-mode
contract), §13.11 (propagation), BCS0101 (strict mode), BCS-bash
`30_45_shopt.md`.

#fin
