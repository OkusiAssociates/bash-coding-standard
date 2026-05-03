<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.9 `errtrace` and trap inheritance

`set -E` (equivalently `set -o errtrace`) propagates the `ERR` trap
into shell functions, command substitutions, and subshells. `set -T`
(`functrace`) does the same for `DEBUG` and `RETURN` traps. Without
these, traps installed at the top level are silently *not* in force
inside the structures where most of the work happens, and an ERR trap
that "covers the whole script" only covers its mainline.

### The canonical BCS strict-mode contract

Every BCS-compliant script begins with this preamble verbatim
(BCS0101):

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

Each flag earns its place:

- `set -e` (errexit, §13.2) — exit on unchecked non-zero status.
- `set -u` (nounset, §13.4) — error on unset variable references.
- `set -o pipefail` (§13.5) — pipeline status reflects rightmost
  non-zero component, not just the last.
- `shopt -s inherit_errexit` (§13.6) — propagate errexit into
  command substitutions; without this, `$(…)` swallows internal
  failures.
- `shopt -s shift_verbose` — `shift` errors loudly when the count
  exceeds available positionals, instead of silently doing nothing.
- `shopt -s extglob` — extended pattern matching: `@(a|b)`, `!(...)`,
  `?(...)`, `*(...)`, `+(...)`. Required for many BCS patterns
  (notably option bundling: `-[abc]?*`).
- `shopt -s nullglob` — unmatched globs expand to nothing rather than
  the literal pattern. `for f in /etc/cron.d/*` runs zero iterations
  when the directory is empty, instead of operating on the literal
  string `/etc/cron.d/*`.

Removing any single component reintroduces a documented hazard. The
contract is normative across all BCS scripts; libraries (BCS0407)
inherit it from the sourcing script and must not weaken it.

### Adding `set -E` for ERR-trap coverage

The strict-mode contract above does *not* include `set -E`. If the
script (or library) installs an ERR trap (§13.8) and expects it to
fire from within functions, command substitutions, or subshells,
add `errtrace` explicitly:

```bash
#!/usr/bin/env bash
set -eEuo pipefail                                      # note: -eE
shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'rc=$?; printf >&2 "ERR rc=%d at %s:%d in %s\n" \
  "$rc" "${BASH_SOURCE[0]:-?}" "$LINENO" "${FUNCNAME[0]:-MAIN}"' ERR

work() {
  false                # ⇒ with set -E: trap FIRES from inside work()
}                      #    without -E: trap silent here
work
```

`set -eET -o pipefail` is the common longer form; `T` adds DEBUG /
RETURN trap inheritance for tracing libraries.

### What `errtrace` actually does

Bash maintains, per shell context (top level, function, subshell), a
table of installed traps. By default, when a function or subshell is
*entered*, the ERR trap is reset to its default (no action) for that
context. The ERR trap installed at the top level still applies to
top-level commands but not to commands run inside the function body.
`set -E` removes this reset: the ERR trap in force at function-entry
is propagated into the new context.

`set -T` (`functrace`) does the equivalent for DEBUG (fired before
each simple command) and RETURN (fired on function return / sourced-
script completion). Without `-T`, DEBUG and RETURN traps installed at
the top level are absent inside function bodies.

EXIT traps are special: they are *not* affected by `-E` or `-T`.
Each subshell can have its own EXIT trap, and an EXIT trap installed
at the top level fires only when the *top-level shell* exits.
Functions do not have their own EXIT trap; the EXIT trap installed
in the script fires once, when the script ends.

### Interaction with `inherit_errexit`

`inherit_errexit` (§13.6) and `errtrace` (§13.9) are independent. The
former determines whether `errexit` is *active* inside `$(…)`; the
latter determines whether the *ERR trap* fires when errexit triggers.
Neither implies the other. For full coverage — errors detected *and*
diagnosed everywhere — enable both.

```bash
# scenario: contract + ERR trap, end-to-end
#!/usr/bin/env bash
set -eEuo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'rc=$?; printf >&2 "ERR rc=%d cmd=[%s] at %s:%d\n" \
  "$rc" "$BASH_COMMAND" "${BASH_SOURCE[0]##*/}" "$LINENO"' ERR
trap 'rc=$?; (( rc )) && printf >&2 "EXIT rc=%d\n" "$rc"' EXIT

probe() { result=$(grep -c "$1" "$2"); echo "$result"; }

probe "alpha" /etc/hostname            # ⇒ if grep fails AND inherit_errexit
                                       #    is set AND errtrace is set,
                                       #    ERR fires inside probe(), then
                                       #    again in main; EXIT fires last.
```

### Practical guidance

The four-line preamble at the top of this chapter is mandatory in BCS
scripts. Add `set -E` (the `eE` shorthand) when ERR traps are part of
the script's diagnostic contract. Add `set -T` only when you actually
trace DEBUG/RETURN — it is a tracing tool, not a defensive setting.
Do not toggle these mid-script; the contract is a header, not a
runtime knob.

**See also**: §13.2 (errexit), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §12.6 (pseudo-signals), §12.8
(trap inheritance), BCS0101 (strict mode), BCS0110 (cleanup and
traps), BCS-bash `30_43_set.md`, BCS-bash `30_45_shopt.md`.

#fin
