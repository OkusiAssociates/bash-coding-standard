<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.11 Order of evaluation

Bash applies redirections strictly *left-to-right* against the current
fd table, before the command is executed. Each operator either opens a
new file description (the `>file` and `<file` family) or duplicates an
existing description (`>&n`, `<&n`) — and the duplication captures
whatever the source fd points at *at that moment*, not at the end of
the redirection list. This rule is what makes `>file 2>&1` and
`2>&1 >file` produce different results.

### The rule

For each redirection, in left-to-right order:

1. Evaluate the right-hand operand (filename or fd number).
2. Apply the corresponding `dup2()` / `open()` / `close()` syscall to
   the named left-hand fd.
3. Move on to the next redirection with the fd table now updated.

The command is then exec'd with the resulting fd table inherited.

### The notorious `>file 2>&1` versus `2>&1 >file`

Both forms use exactly the same two operators. The difference is
sequence; the difference in result is total:

```bash
# scenario: trace both forms operator-by-operator against the fd table
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Form A — correct
{ echo to-stdout; echo to-stderr >&2; } >out.log 2>&1
#                                      ^^^^^^^^ step 1: open out.log on fd 1
#                                                        fd 1 → out.log
#                                                        fd 2 → terminal (unchanged)
#                                               ^^^^^^^ step 2: dup fd 1 onto fd 2
#                                                        fd 1 → out.log
#                                                        fd 2 → out.log
# ⇒ both messages in out.log

# Form B — wrong (stderr stays on terminal)
{ echo to-stdout; echo to-stderr >&2; } 2>&1 >out2.log
#                                       ^^^^ step 1: dup fd 1 onto fd 2
#                                                        fd 1 → terminal
#                                                        fd 2 → terminal (was already, copy)
#                                            ^^^^^^^^ step 2: open out2.log on fd 1
#                                                        fd 1 → out2.log
#                                                        fd 2 → terminal (still!)
# ⇒ stdout in out2.log; stderr printed to terminal
```

The mnemonic: **target before merge**. The redirect that names a file
must come before the merge that says "stderr follows stdout". Reversed,
the merge captures stale state.

### Multiple writes to the same file

Two separate `> file` operators *open the file twice*, producing two
independent fds with two independent offsets. Both write to the same
file but the kernel does not synchronise them — output may interleave
in unpredictable ways, and one fd's writes can land in bytes another
expected to occupy:

```bash
# scenario: 1>log 2>log races; 1>log 2>&1 does not
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# WRONG — two opens, two offsets, racing writers
seq 1 5 1>race.log 2>race.log >&2 &
seq 6 10 >>race.log &
wait
# ⇒ race.log content is non-deterministic; bytes from both writers interleave

# RIGHT — one open, two fds sharing the same description and offset
seq 1 5 >shared.log 2>&1 &
seq 6 10 >>shared.log &
wait
# ⇒ shared.log content is deterministic; each writer's lines appear intact
```

The `&>` shorthand and `>file 2>&1` form both produce the
single-shared-description case; `1>file 2>file` produces the racing
case. This is one of the strongest reasons to prefer the shorthand or
the explicit-merge form.

### Inside `exec`

`exec` follows the same left-to-right rule, applying every redirection
to the *shell's own* fd table:

```bash
exec 3>&1 1>log 2>&1
# step 1: dup fd 1 (terminal) onto fd 3   → fd 3 = terminal
# step 2: open log on fd 1                → fd 1 = log
# step 3: dup fd 1 (now log) onto fd 2    → fd 2 = log
# fd 3 holds the saved terminal stdout for later restoration
```

The save-then-redirect-then-merge pattern in a single `exec` is correct
*only* because of the left-to-right rule.

### Practical guidance

- Always specify the file target first, the merge second.
- Prefer `&>` (or `&>>`) when both streams want the same file — bash
  parses it as one operation, sidestepping the ordering trap entirely.
- When in doubt, mentally trace the operators against a two-row table
  (fd 1 / fd 2) and apply each in order; do not assume a "merge"
  metaphor that does not match the syscall semantics.

**See also**: §6.4 (stderr redirection and merging), §6.6 (duplicating
fds), §6.12 (`exec` for fd manipulation), §1.2 (the fd table model),
BCS0711.

#fin
