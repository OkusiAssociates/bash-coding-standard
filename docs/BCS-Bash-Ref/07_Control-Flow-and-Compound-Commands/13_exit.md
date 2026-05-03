<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.13 `exit`

`exit` terminates the *current* shell process and returns control to
its parent. The optional argument is the exit status, taken modulo
256.

- `exit [N]` — `N` defaults to the status of the last command.
- `N` is taken modulo 256.
- `exit` triggers the EXIT pseudo-trap (§12.6) before the shell
  actually leaves.
- `exit` from within a subshell exits *only that subshell*; the
  parent shell continues.
- A subshell's `exit` does **not** run the parent's EXIT trap — each
  shell has its own trap table.

### Subshell-exit subtlety

The most common source of confusion is `(...)` versus `{...}`. A
subshell — explicit `(...)`, a pipeline element, a command
substitution `$(...)`, a backgrounded `&` job — has its own process
ID and its own trap table. `exit` inside it leaves *that process*,
not the parent.

```bash
# scenario: exit inside a subshell does NOT terminate the script.
#!/usr/bin/env bash
set -euo pipefail
echo 'before subshell'

(
  echo 'inside subshell'
  exit 7                                       # exits ONLY this subshell
  echo 'unreachable'
)
echo "subshell rc=$?"                          # ⇒ subshell rc=7 (BCS0602)
echo 'after subshell'                          # ⇒ runs normally

#fin
```

By contrast, `{ ...; }` runs in the *current* shell; an `exit`
inside it terminates the script.

### EXIT trap interaction

The EXIT trap fires whenever the shell that installed it leaves —
whether by `exit`, by reaching end of script, by a fatal signal, or
by an `errexit`-triggered failure. Each subshell starts with **no**
inherited EXIT trap (it has its own copy of the trap table that is
explicitly cleared for EXIT and DEBUG).

```bash
# scenario: EXIT trap fires once for the parent, not for the subshell.
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "PARENT exit trap (rc=$?)"' EXIT

(
  trap 'echo "SUB exit trap"' EXIT             # subshell installs its own
  echo 'in subshell'
  exit 3                                       # ⇒ fires SUB exit trap, NOT parent
)

echo "subshell rc=$?"                          # ⇒ subshell rc=3
exit 0                                         # ⇒ then parent EXIT trap fires (rc=0)

#fin
```

Output: `in subshell` / `SUB exit trap` / `subshell rc=3` /
`PARENT exit trap (rc=0)`. `exit` in the parent runs the parent's
EXIT trap; `exit` in the subshell runs the subshell's. They never
cross.

**See also**: §7.8 subshell grouping, §7.9 brace grouping, §7.12
`return`, §12.6 EXIT/ERR/DEBUG/RETURN pseudo-signals, §13.10 exit
code conventions, BCS0602 (exit codes), BCS0603 (trap handling).

#fin
