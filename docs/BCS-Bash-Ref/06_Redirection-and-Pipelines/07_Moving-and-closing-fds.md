<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.7 Moving and closing fds

The close form `>&-` (and `<&-`) shuts an fd; the dup-and-close form
`n>&m-` *moves* an fd — duplicates *m* onto *n* and closes *m* in a
single operation. The two forms together let a script manage fd
lifetimes precisely, which matters when launching children that should
see only the fds they need.

### Closing forms

- `>&-` — close fd 1.
- `<&-` — close fd 0.
- `n>&-` — close fd *n* (write side).
- `n<&-` — close fd *n* (read side; equivalent to `n>&-`, only the
  parser direction differs).
- `exec 4>&-` — script-wide close of fd 4.

Closing an fd that is *already* closed is silently fine. Writing to a
closed fd is *not*: the write fails with EBADF and bash reports a
"Bad file descriptor" error. Reading similarly returns EBADF.

### Move (atomic dup-and-close)

`n>&m-` and `n<&m-` perform `dup2(m, n)` followed by `close(m)`
atomically — there is no intermediate state where both fds reference the
same description. The use case is fd hygiene: a child process inherits
*every* fd that is open at exec time unless the parent has marked it
`O_CLOEXEC` or closed it, so a long-lived saved-stdout on fd 3 leaks
into every child unless explicitly cleaned up.

```bash
# scenario: redirect this whole script's stdout to a log, restore at end
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Save stdout on 3, point fd 1 at the log
exec 3>&1 >script.log

echo "this line goes to the log"
date
echo "more log output"

# Restore stdout via move: fd 1 ← fd 3, fd 3 closed atomically
exec 1>&3-
echo "this line is back on the terminal"
# ⇒ this line is back on the terminal
# (script.log now holds three lines; fd 3 is no longer dangling)
```

Without the `-` suffix on `1>&3`, fd 3 would remain open through the
rest of the script's lifetime, inherited by every child the script
spawns. The move form is the correct cleanup.

### Close-then-write and SIGPIPE-equivalent failures

Closing fd 1 and then writing to it does not raise SIGPIPE — that
signal is for *pipe* readers that have departed, not for closed fds.
Writes to a closed fd return EBADF; the calling builtin (typically
`echo`, `printf`) prints an error to fd 2 (if 2 is still open) and
returns non-zero:

```bash
# scenario: close stdout, attempt to write — observe failure mode
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

(
  exec 1>&-                     # close stdout in this subshell only
  echo "no destination"         # write to closed fd 1
) 2>&1 || echo "subshell failed: $?"
# ⇒ Bad file descriptor
# ⇒ subshell failed: 1
```

For the SIGPIPE case proper — a *living* writer feeding a *dead*
reader — see §6.13 and §13.5; the disposition is signal 13 with default
exit status 141, not EBADF.

### Practical guidance

- Always pair an `exec n>&1` save with a matching `exec 1>&n-` (move,
  not dup) restore. The trailing hyphen is the difference between
  hygienic and leaky scripts.
- For a `func() { … } 3>&1` style — fd 3 is local to the function call,
  so explicit close is unnecessary; the redirection is undone on
  return.
- When launching a long-running background child that should not
  inherit a debugging fd, `bg-cmd 3>&-` closes fd 3 just for that
  child. Without the close, the child holds the fd open and the
  description outlives the parent's intent.
- `shopt -s varredir_close` (Bash 5.2, §6.12) automates cleanup for
  fds opened via the `{var}>file` form — the fd closes when *var*
  goes out of scope. Recommended for all new code that opens custom
  fds inside a function.

**See also**: §6.6 (duplicating fds), §6.12 (`exec` and `varredir_close`),
§6.13 (pipelines and SIGPIPE), §13.5 (`pipefail` and 141), §11.2 (fd
inheritance at fork).

#fin
