<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.2 The file descriptor model

A file descriptor is a small non-negative integer that indexes the kernel's per-process open-file table. Every redirection in Bash is ultimately a manipulation of this table via `dup2(2)`, `open(2)`, and `close(2)`.

### The three-level mapping

```
process A                   kernel                       on-disk
+---------+              +---------------------+      +---------+
| fd 0  --|------+       | open file desc OFD1 |      |         |
| fd 1  --|---+  |       |  offset, flags ----------> |  inode  |
| fd 2  --|-+ |  |       +---------------------+      |         |
| fd 3  --|+| | +------> | OFD2  offset, flags ---->  +---------+
+---------+|| |          +---------------------+
            ||  +-------> | OFD3  offset, flags ---->  /dev/tty
            |+----------> | OFD2  (shared)
            +-----------> | OFD1  (shared via dup)
```

A process holds an array of fd entries. Each entry points to a kernel **open file description** (OFD) that owns the file offset and access flags. `dup2(newfd, oldfd)` aliases two fds onto the same OFD; closing one does not close the other. `fork(2)` duplicates the fd array but the children share OFDs with the parent — the offset is a single shared cursor. `execve(2)` keeps every fd that does not have `O_CLOEXEC` set.

### Conventional descriptors

`0` (stdin), `1` (stdout), `2` (stderr) are convention only — the kernel has no opinion. Bash inherits whatever the parent provided and re-points them via redirection. `>` is `dup2(open(file, O_WRONLY|O_CREAT|O_TRUNC), 1)` plus a close; `2>&1` is `dup2(1, 2)`.

### Inspecting fds at runtime

```bash
# scenario: list every fd held by the current shell
ls -l /proc/$$/fd                                # symlinks → real targets
exec 3>"/tmp/log.$$"                             # open new fd
ls -l /proc/$$/fd/3                              # ⇒ 3 -> /tmp/log.NNN
exec 3>&-                                        # close it (BCS0905)
```

`/proc/PID/fdinfo/N` exposes the OFD's current offset and flags — useful for debugging hung pipelines. `lsof -p $$` produces the same information in human-readable form and works without `/proc`.

### Redirection as `dup2` in disguise

```bash
# scenario: save stdout, redirect, restore
exec 4>&1                       # fd 4 ← duplicate of stdout
exec 1>/tmp/captured            # stdout ← /tmp/captured
echo 'goes to file'             # ⇒ written to /tmp/captured
exec 1>&4 4>&-                  # restore stdout, drop the saved copy
echo 'goes to terminal'
```

This pattern is the substrate for every `>(…)`/`<(…)` process substitution in Bash. Process substitutions appear as `/dev/fd/N` paths because the kernel exposes the open fd table as a virtual directory.

### Limits and `O_CLOEXEC`

`ulimit -n` (`RLIMIT_NOFILE`) caps how many fds a single Bash process may hold. Bash sets `O_CLOEXEC` on every fd it opens for its own use (including pipeline ends), so child commands do not see the shell's bookkeeping fds — but **explicit** `exec N>file` opens are inherited unless you close them.

### Anti-patterns

```bash
# wrong — leaks fd 3 across exec
exec 3>"/tmp/log"
some-long-running-program        # inherits fd 3 unintentionally

# right — close before handing control over
exec 3>"/tmp/log"
do_logging_with_fd3
exec 3>&-
some-long-running-program
```

**See also**: §1.4 (streams and the standard descriptors), §6 (redirection and pipelines, full Part), §13.6 (process substitution), §17 (coprocesses), BCS0905 (input redirection), BCS0903 (process substitution).

#fin
