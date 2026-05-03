<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.1 The fd table from Bash's perspective

Recap of §1.2, framed as the shell sees it. Every process has a
kernel-managed file-descriptor table: an array of small non-negative
integers mapping to *open file descriptions* (kernel structures
holding the file, current offset, and access mode). Bash inherits the
table from its parent at fork, modifies it according to the
redirection operators on the current command, and then exec's. The
modified table is what the child program receives.

### Operating principle

- **Inheritance**. Bash inherits *every* open fd at fork unless its
  `O_CLOEXEC` flag is set. The standard descriptors (0/1/2) are
  always inherited.
- **Order of operations**. For every command, Bash forks (for
  externals; for builtins it forks only when redirection demands a
  child), applies redirections in left-to-right order against the
  current table, *then* calls `execve`. The child program sees the
  table as Bash left it.
- **Compound commands**. Redirections on a `{ … }`, `( … )`, `for`,
  `while`, `if`, `case`, or function block apply for the duration of
  the block — every nested command sees the modified table.
- **Function-definition redirections**. `name() { … } > /tmp/log` is
  legal: every call to `name` redirects fd 1 to `/tmp/log`. Useful
  for centralising trace output.
- **Script-wide redirection via `exec`**. `exec >file 2>&1` (without
  a command word) redirects the *shell's own* fd 0/1/2 for the
  remainder of the script (§6.12).
- **Reservation convention**. Fds 3–9 are by convention available for
  user redirection (`exec 3<>file`); fds 10+ work but Bash may use
  them internally for redirection bookkeeping. BCS scripts stick to
  3–9 (BCS0905).

### Mini-trace — what the kernel sees

```bash
# scenario: trace fd manipulation through a single redirected pipeline
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Run under strace to see the syscalls Bash issues:
#   strace -f -e trace=open,openat,dup2,close,pipe,clone,execve \
#     bash -c 'echo hello >/tmp/x.log 2>&1'
#
# Trimmed output:
#   clone(...)                          # fork child for `echo`
#   openat(AT_FDCWD, "/tmp/x.log", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
#   dup2(3, 1)            = 1           # redirect stdout to /tmp/x.log
#   close(3)              = 0           # close the temp fd
#   dup2(1, 2)            = 2           # 2>&1: stderr follows stdout
#   execve("/bin/echo", ["echo", "hello"], envp)
#
# i.e. Bash:
#   1. opens the file on a *fresh* fd (3),
#   2. dup2's that into fd 1,
#   3. closes the temp fd,
#   4. dup2's fd 1 onto fd 2,
#   5. exec's the program — with fds 1 and 2 both pointing at /tmp/x.log.
```

This is the syscall-level evidence behind the `>file 2>&1` ordering
rule (§6.4): the operations happen in token order against the *live*
table, not as a logical "merge" of declarative intent.

### Function-level inheritance

```bash
# scenario: redirection on a function definition is per-call
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- LOGFILE=/tmp/trace.$$

# Every call to `traced` writes its own stdout to $LOGFILE
traced() {
  echo "[$(date +%T)] inside traced; arg=$1"
} >>"$LOGFILE"                       # function-definition redirection

traced one
traced two

cat -- "$LOGFILE"
# ⇒ [10:11:12] inside traced; arg=one
# ⇒ [10:11:13] inside traced; arg=two
```

The redirection lives on the function definition, so callers do not
need to remember to redirect.

### Custom fds 3–9 — the user range

```bash
# scenario: open a side-channel fd 3 to a log, leave 1/2 untouched
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r LOGFILE=/tmp/run.$$
exec 3>>"$LOGFILE"                   # fd 3 = append to log
trap 'exec 3>&-' EXIT                # close on script exit (BCS0110)

echo 'normal output to terminal'     # fd 1 unchanged
echo 'trace line' >&3                # explicit fd 3
exec 3>&-                            # explicit close (or rely on trap)
```

This is the `BASH_XTRACEFD` pattern (§19.4) and the BCS messaging
pattern (BCS0703) in miniature.

### BCS posture

- Reserve fds 3–9 for user redirection; do not use 10+ in scripts
  (BCS0905).
- Always close fds you open with `exec n<>file`, ideally via an
  EXIT trap (BCS0110).
- Prefer the parser shorthand `&>` over the manual `>file 2>&1` when
  you mean *both streams to the same destination* (§6.4); use the
  manual form when you need them on different destinations.
- Document fd reservations in a header comment when a script uses
  more than fd 3 (BCS1202).

**See also**: §1.2 (kernel fd model), §6.4 (stderr merging),
§6.6/§6.7 (duplicate / move / close), §6.11 (order of evaluation),
§6.12 (`exec` for fd manipulation), §19.4 (`BASH_XTRACEFD`).

#fin
