<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.8 Trap inheritance

Whether a trap installed in the parent shell remains in force inside a
function, command substitution, or subshell depends on which trap and
which inheritance flag is set. The defaults are surprising — most
traps are *not* inherited — and the rules differ for real signals,
EXIT, ERR, and DEBUG/RETURN. This chapter is the canonical inheritance
matrix for the reference; §13.9 inlines the BCS strict-mode contract
that incorporates the relevant flags.

### Inheritance matrix

| Trap on | Function call | Command subst `$(…)` | Subshell `(…)` | Background `&` |
|---------|:-------------:|:--------------------:|:--------------:|:--------------:|
| Real signal (caught, e.g. `INT`) | inherited | inherited | inherited | reset to default ¹ |
| Real signal (ignored, `trap '' SIG`) | inherited | inherited | inherited | inherited |
| `EXIT` | parent only ² | subshell-local ³ | subshell-local | subshell-local |
| `ERR` | not inherited (use `set -E`) | not inherited (use `set -E`) | not inherited (use `set -E`) | not inherited (use `set -E`) |
| `DEBUG` | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) |
| `RETURN` | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) |

Notes:

1. Per `bash(1)` SIGNALS section: "When bash is waiting for an
   asynchronous command via the `wait` builtin, the reception of a
   signal for which a trap has been set will cause the `wait` builtin
   to return immediately with an exit status greater than 128,
   immediately after which the trap is executed." Background-process
   subshells reset *caught* (non-ignored) signals to default
   disposition; ignored signals (`trap '' SIG`) remain ignored.
2. Functions do not have their own EXIT trap. The script's EXIT trap
   fires once when the parent shell exits; function returns do not
   trigger EXIT (use RETURN, §12.6).
3. Each command-substitution shell has its own EXIT trap, defaulted
   to no-op. The parent's EXIT handler does *not* fire when the
   substitution ends — only when the parent itself exits.

The "use `set -E`" / "use `set -T`" cells are the actionable lever:
setting `errtrace` makes ERR cells become "inherited"; setting
`functrace` makes DEBUG and RETURN cells become "inherited".

### `set -E`, `set -T`, and `extdebug`

Three switches govern propagation of the bash-internal pseudo-signals:

| Switch | Long name | Effect |
|--------|-----------|--------|
| `set -E` | `errtrace` | ERR trap propagates to functions, command substitutions, and explicit subshells. |
| `set -T` | `functrace` | DEBUG and RETURN traps propagate to functions, command substitutions, and explicit subshells. |
| `shopt -s extdebug` | (no short flag) | Extends DEBUG: the handler's exit status can *abort* the command (return 2 means "skip this command"); also enables `BASH_ARGC`, `BASH_ARGV`, `BASH_LINENO`, `BASH_SOURCE` arrays for full call introspection; required for `bashdb`. |

`extdebug` is a tracing-only feature. Production scripts should not
enable it. It interacts with `set -T` and `set -E` cumulatively —
each adds a slice of inheritance and introspection.

### Real-signal inheritance subtlety

A real-signal trap behaves slightly differently than a pseudo-signal
trap. Inside a subshell or background process, *caught* signals are
reset to default disposition because the subshell is "asynchronous"
and the parent's handler context (e.g. shared state) may not be
appropriate. *Ignored* signals (`trap '' SIG`) remain ignored, by
POSIX rule, because resetting to default would be observable as a
behavioural change. A subshell wishing to handle a signal must
re-install its own trap.

```bash
# scenario: ERR trap propagation, with and without -E
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "ERR fired at $LINENO in ${FUNCNAME[1]:-MAIN}"' ERR

probe_no_E() { set +E; false; }        # function with -E off
probe_with_E() { set -E; false; }       # function with -E on

set +E; probe_no_E   || echo "after probe_no_E rc=$?"
# ⇒ "after probe_no_E rc=1" — ERR did NOT fire inside probe_no_E

set -E; probe_with_E || echo "after probe_with_E rc=$?"
# ⇒ "ERR fired at ... in probe_with_E"
# ⇒ "after probe_with_E rc=1"
```

The asymmetry is the entire reason `set -E` exists. Library code that
installs an ERR trap *must* set `errtrace`, or accept that the trap is
silent inside any function call.

```bash
# scenario: subshell loses the parent's EXIT trap
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "parent EXIT (pid=$$)"' EXIT

(
  echo "inside subshell (pid=$BASHPID)"
  # No EXIT trap here unless we install one explicitly.
  # Parent's EXIT will NOT fire when this subshell ends.
  exit 0
)
echo "after subshell"

# Subshell-local trap, if needed:
(
  trap 'echo "subshell EXIT (pid=$BASHPID)"' EXIT
  exit 0
)
# ⇒ "subshell EXIT (pid=...)"  — fires for the subshell only
# ⇒ "parent EXIT (pid=...)"    — fires later, when the script ends
```

### `inherit_errexit` does *not* affect trap inheritance

A common misreading: `inherit_errexit` (§13.6) propagates *errexit*
into `$(…)`, but it has *no* effect on whether the ERR trap fires
there. ERR fires only if `set -E` is also set. The two flags
collaborate but are independent: `inherit_errexit` decides "does the
substitution exit on internal failure?", `errtrace` decides "does the
ERR trap run when it does?". For full diagnostic coverage, set both.

### Practical guidance

The BCS strict-mode contract (§13.9) does not include `set -E` /
`set -T` by default — those are tracing-aware additions. When a script
installs an ERR trap that *must* fire inside library functions
(BCS0407), upgrade the contract preamble to `set -eEuo pipefail`. The
EXIT trap pattern (§12.6, BCS0110) does not need any inheritance flag;
it is installed once at top level and naturally fires on shell exit.

For subshell cleanup, install a subshell-local EXIT trap explicitly.
Do not assume the parent's trap will run.

**See also**: §12.5 (trap builtin), §12.6 (pseudo-signals), §12.7
(`trap -p`), §12.9 (trap reset on exec), §13.2 (errexit), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.9 (errtrace contract),
BCS0101 (strict mode), BCS0110 (cleanup and traps), BCS-bash
`30_43_set.md`, BCS-bash `30_45_shopt.md`.

#fin
