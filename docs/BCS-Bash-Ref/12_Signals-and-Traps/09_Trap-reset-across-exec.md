<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.9 Trap reset across `exec`

`execve(2)` replaces the current process image with a new program. The
kernel's POSIX-mandated rule for what happens to the signal disposition
table at this point depends on whether each signal was *caught* or
*ignored*:

| Disposition before `exec` | After `exec` |
|--------------------------|--------------|
| **Caught** (handler installed) | **Default** (handler discarded — the new program would not know how to run it) |
| **Ignored** (`SIG_IGN`) | **Ignored** (preserved — the new program may be unable to override its parent's choice) |
| **Default**            | **Default** (unchanged) |

This asymmetry is intentional and not configurable from user space:
inherited *ignores* are how a parent shell can permanently silence a
signal across an `exec` chain (e.g. setuid wrappers ignoring SIGINT),
while inherited *handlers* would be unreloadable address-space junk.

```bash
# scenario: ignored vs caught reset on exec
trap 'echo "HUP caught"' HUP              # Caught
trap '' PIPE                              # Ignored
exec bash -c 'trap -p HUP PIPE'
# ⇒ trap -- '' SIGPIPE
# (the ignore on PIPE survived the exec; the caught handler on HUP was
#  reset to default, so `trap -p HUP` prints nothing)
```

The same rule applies to bash's `exec` builtin: handlers installed in
the wrapper are wiped on `exec realprog`, but ignores stick. A normal
`bash -c '…'` is `fork+exec` — the parent keeps its traps, only the
child loses caught handlers. `exec PROG` (no `&`) replaces the calling
shell entirely, so the calling shell's traps are gone for good.

For "child must ignore SIGINT" hardening, install the ignore in the
parent (handlers do not survive but ignores do). Library code must
re-install its own traps in the new image — it cannot rely on the
parent's.

**See also**: §12.4 (signal disposition), §12.5 (`trap` builtin), §12.7
(`trap -p` inspection), §12.8 (trap inheritance), §11.13 (environment
inheritance), BCS-bash `30_21_exec.md`, BCS-bash `30_48_trap.md`,
BCS0603 (trap handling).

#fin
