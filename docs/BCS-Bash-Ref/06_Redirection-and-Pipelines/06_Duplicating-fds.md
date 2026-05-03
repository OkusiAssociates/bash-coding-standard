<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.6 Duplicating fds

`>&` and `<&` duplicate one fd onto another. The mechanism is `dup2()`:
the destination fd ends up referring to the same open file description
as the source — same file, same offset, same status flags. Closing
either does not close the other; they are independent handles to the
shared description.

### Forms

- `n>&m` — make fd *n* a duplicate of fd *m* for writing.
- `n<&m` — same, expressed for reading (parses identically).
- `>&m` — equivalent to `1>&m`.
- `<&m` — equivalent to `0<&m`.
- `n>&m-` — duplicate-and-close: dup *m* onto *n*, then close *m*
  atomically (see §6.7).
- `n>&-` — close fd *n* (see §6.7).
- `{var}>&m` — Bash 5.0+ allocates a fresh fd, stores its number in
  *var*, and points it at *m*'s description. Useful when the script
  must not collide with a hard-coded fd number.

The two parser forms `>&` and `<&` are identical at the dup2 level —
both perform the same `dup2(m, n)` syscall regardless of whether the
operator is written for reading or writing. Bash uses the parser
direction only to decide what message to emit on error; the underlying
operation is symmetric.

The duplicated fd shares the *open file description*, not just the
target. Two consequences matter:

1. **Shared offset.** Writes through fd 1 and fd 3 (where `3>&1`) advance
   the same kernel-side offset; bytes do not interleave on a per-fd
   basis.
2. **Independent close.** `exec 1>&-` does not close fd 3 even though it
   was created by `3>&1` — both must be closed explicitly.

### Save-restore-stdout pattern

The canonical use of duplication is the "save current stdout, redirect,
restore" dance. Save fd 1 onto an unused fd (3 by convention), apply
the temporary redirection, then restore by duplicating back:

```bash
# scenario: wrap a function call so its stdout is captured to a log,
# leaving everything else on the terminal untouched
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

run_quiet_with_log() {
  local -- logfile="$1"; shift
  exec 3>&1                     # save current stdout on fd 3
  exec 1>"$logfile"             # stdout now goes to logfile
  "$@"                          # run the command — its stdout goes to log
  exec 1>&3                     # restore stdout from saved fd 3
  exec 3>&-                     # close the saved fd
}

run_quiet_with_log /tmp/build.log make all
echo "build done"               # ⇒ printed to terminal as expected
# /tmp/build.log contains only `make all` stdout
```

The two `exec` lines in the middle could collapse to `exec 3>&1 1>"$logfile"`
and the restore to `exec 1>&3 3>&-` — bash applies redirections
left-to-right within a single `exec`, so the save happens before the
overwrite. See §6.11 for the ordering rule.

### Stream-swap (the awk classic)

Sometimes a command's stdout is uninteresting but its stderr should be
captured for further pipeline processing. Naively `cmd 2>&1 | grep` only
works if both streams are wanted; to swap them — pipe stderr, leave
stdout on terminal — use a three-way dance:

```bash
# scenario: pipe stderr through a grep filter, keep stdout on terminal
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Three-fd swap: 3 ← 1 ← 2 ← 3, then close 3
{ make 3>&1 1>&2 2>&3 3>&-; } | grep -i error
# step-by-step at the brace:
#   3>&1   fd 3 ← terminal-stdout
#   1>&2   fd 1 ← terminal-stderr (so make's stdout goes to stderr)
#   2>&3   fd 2 ← saved terminal-stdout (so make's stderr goes to stdout
#                 → the pipe → grep)
#   3>&-   close the temporary
# ⇒ grep sees `make`'s stderr; `make`'s stdout still appears on terminal
```

This is the only standard idiom; memorise the four-operator form rather
than re-deriving it.

### Difference from move

`n>&m` *duplicates*: fd *m* remains open. `n>&m-` *moves*: fd *m* is
closed atomically once *n* has been pointed at the description (§6.7).
For passing exactly the fds a child process needs, the move form avoids
fd leaks.

### Why fd 3 (and not 4, 5, 9 …)

Convention reserves fds 3–9 for user code; bash itself may open higher
fds for internal bookkeeping. Within that range, fd 3 is the
overwhelmingly common choice for save-stdout, fd 4 for save-stderr.
Pick stable conventions within a script and document them in the
header comment — readers (and `bash -x` traces) become much easier to
follow when fd 3 *always* means "saved stdout" rather than rotating
between fd 3, 4, and 5.

`exec {var}>file` (Bash 5.0+) sidesteps the convention entirely: bash
allocates a free fd and stores the number in *var*. Combine with
`varredir_close` (§6.12) to make fd lifetime track variable scope.

When in doubt, write the redirection list with comments tracing each
operator's effect on the fd table — bash's terse syntax rewards
explicit narration in places where the syscall semantics matter.

**See also**: §6.7 (moving and closing fds), §6.11 (order of evaluation),
§6.12 (`exec` for fd manipulation), §1.2 (fd table from the kernel's
perspective), BCS0703 (messaging fds).

#fin
