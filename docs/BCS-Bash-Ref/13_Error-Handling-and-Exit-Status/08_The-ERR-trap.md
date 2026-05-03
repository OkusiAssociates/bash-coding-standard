<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.8 The `ERR` trap

The `ERR` pseudo-signal fires whenever a command would cause `set -e`
to exit — i.e. whenever a non-zero exit status survives the exemption
matrix (§13.3). It is the canonical hook for diagnostic output before
the shell terminates.

```bash
on_err() {
  local rc=$? line=$1
  error "command failed at line $line with exit $rc: $BASH_COMMAND"
}
trap 'on_err $LINENO' ERR
```

The single-quoted handler text is mandatory: `$LINENO` must expand at
trap-fire time (when bash records the line of the failing command),
not at trap-installation time (when it would always read as the line
of the `trap` statement). See §12.5 for the broader single-vs-double
quote pitfall.

### Variables available inside the handler

| Variable | Meaning |
|----------|---------|
| `$?`              | the failing command's exit status |
| `$BASH_COMMAND`   | the literal text of the failing command |
| `$LINENO`         | line number of the failing command (must be passed positionally — see above) |
| `BASH_LINENO[]`   | call-site line numbers for each frame |
| `FUNCNAME[]`      | function names from current frame outwards (`[0]` is the trap itself) |
| `BASH_SOURCE[]`   | source files for each frame |

These together permit a full stack trace; see §13.12 for the
production-grade handler.

### Inheritance — the critical interaction with `set -E`

By default, an ERR trap is **not** inherited by functions, command
substitutions (`$(…)`), or subshells (`( … )`). The fix is `set -E`
(`errtrace`); with `errtrace` active, the ERR trap inherits into all
of the above. This is the same defect-and-fix as `inherit_errexit`
for `set -e`.

```bash
# scenario: ERR trap inheritance — default vs set -E
trap 'echo "ERR fired: $BASH_COMMAND"' ERR
inner() { false; }                         # would normally trigger ERR

inner                                      # ⇒ silent — ERR did NOT inherit
set -E                                     # turn on errtrace
inner                                      # ⇒ "ERR fired: false"
```

The strict-mode contract therefore adds `-E` whenever an ERR trap is
in use: `set -eEuo pipefail`. `set -T` (`functrace`) extends the same
inheritance to DEBUG and RETURN; BCS scripts with ERR almost always
want `set -eET` together (§13.9).

### When ERR does **not** fire

ERR honours the same exemptions as `set -e` (§13.3): left of `&&`/`||`,
condition of `if`/`while`/`until`, non-final pipeline component without
`pipefail`, inverted with `!`, or inside `$(…)` without
`inherit_errexit`. If none apply and ERR still misses, suspect missing
`set -E` (the inheritance bug above) or a later `trap … ERR` that
replaced yours.

The conventional pairing is one `ERR` for diagnostics and one `EXIT`
for cleanup. ERR runs first when the failing command's status would
trigger errexit; EXIT runs last and should `return "$rc"` to preserve
the failing exit status as the script's final status:

```bash
on_err()  { error "command failed (rc=$?) at $1: $BASH_COMMAND"; }
on_exit() { local rc=$?; cleanup_resources; return "$rc"; }
trap 'on_err $LINENO' ERR
trap on_exit EXIT
```

**See also**: §13.2 (`set -e` semantics), §13.3 (exemption matrix),
§13.9 (errtrace and trap inheritance), §13.12 (rich error output),
§12.5 (`trap` builtin), §12.6 (pseudo-signals), §12.8 (trap
inheritance), BCS0603 (trap handling), BCS-bash `30_43_set.md`,
BCS-bash `30_48_trap.md`.

#fin
