<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.12 `exec` for fd manipulation

`exec` has two distinct modes that share a name only by accident of
history. With a command argument, it *replaces the shell process* with
that command — the calling shell ceases to exist. Without a command,
it *applies its redirections to the current shell* and continues
executing the script. The latter is the only way to make redirections
persist beyond a single command, and the only way to manage long-lived
fds from inside a script.

### The two modes

- `exec cmd …` — `execve()`-replace this shell with *cmd*. The script
  ends here; whatever was after this line is dead code.
- `exec REDIR…` — apply *REDIR…* to the calling shell's fd table.
  Script continues; subsequent commands inherit the new fd state.

These two modes share the *redirection grammar*: `exec cmd >log` execs
*cmd* with stdout pointed at *log*, while `exec >log` redirects the
*current shell*'s stdout to *log* and returns. The presence or absence
of a command argument is the deciding factor.

### Persistent script-wide redirection

The most common script-wide use of `exec` is to redirect everything to
a log:

```bash
# scenario: redirect all subsequent output of this script to a logfile
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- LOGFILE='/var/log/myscript.log'

# Save originals on fd 3 (stdout) and fd 4 (stderr) for later restore
exec 3>&1 4>&2

# Redirect script-wide
exec >>"$LOGFILE" 2>&1

echo "this line is logged"
date
echo "diagnostic" >&2

# Restore (move-form clears the saved fds atomically)
exec 1>&3- 2>&4-
echo "this line is back on terminal stdout"
echo "this too on terminal stderr" >&2
```

The save-redirect-restore pattern is the standard technique; using the
move-form (`1>&3-`, `2>&4-`) for the restore atomically closes the
saved fds, preventing leaks into any later children (§6.7).

### Custom fd for read+write — fd 7 idiom

`exec` is also how scripts open custom fds for repeated `read`/`printf`
without re-opening the file each time. Convention puts user fds in the
3–9 range; bash itself may use fds beyond that internally:

```bash
# scenario: open a config file once, read multiple lines, write a marker, close
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- conf='session.dat'
[[ -f $conf ]] || : >"$conf"     # ensure exists

exec 7<>"$conf"                  # fd 7 open for read+write (§6.5)

# Read existing lines (offset advances as we read)
declare -a lines=()
while read -r -u 7 line; do
  lines+=("$line")
done

# Append a new marker (offset is at EOF after the reads)
printf 'session-end %(%FT%T%z)T\n' -1 >&7

exec 7>&-                        # close fd 7
echo "read ${#lines[@]} prior lines"
```

`read -u 7` reads from fd 7; `printf … >&7` writes to it; `exec 7>&-`
closes it. The fd persists across all three commands — replacing it
with a series of `<file` / `>file` operators on each command would
force re-opens and lose the offset.

### `exec`-replace mode (the other meaning)

When `exec` carries a command, the shell calls `execve()` and the
script's process *becomes* that command. The script ends; nothing after
the `exec` line runs:

```bash
# scenario: tail-call into a longer-running program
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Set up environment, then hand off to the real binary
declare -x PATH='/usr/local/bin:/usr/bin:/bin'
exec /usr/sbin/myservice "$@"

# DEAD CODE — never reached unless `exec` itself fails (e.g. missing binary)
echo "this line will never print"
```

The replace-mode is useful for wrapper scripts (set environment, then
become the wrapped program) and for trampolines that should not leave a
parent shell hanging around. Note the scripted error: `exec /missing`
*does* fail and continue executing the script if the binary is missing
— protect with `||` or rely on `set -e` to catch the failure.

### `varredir_close` — Bash 5.2 fd lifetime tied to variable scope

Bash 5.2 introduced `shopt -s varredir_close` to address a long-standing
fd-leak hazard: when an fd is opened by a `{var}> file` redirection
(the variable-fd form), the fd outlives the command unless explicitly
closed. With `varredir_close` enabled, bash automatically closes such
fds when the variable goes out of scope:

```bash
# Without varredir_close: fd assigned to $log_fd leaks if not closed
exec {log_fd}>log
# … fd remains open until script exit or explicit `exec {log_fd}>&-`

# With varredir_close: fd closes when log_fd is unset or function returns
shopt -s varredir_close
log_step() {
  local -i log_fd
  exec {log_fd}>log         # log_fd is local; fd closes on function return
  printf 'step done\n' >&"$log_fd"
}
log_step                    # fd auto-closed here, no leak
```

This is BCS-recommended for new code; combine with `local -i` for any
function that opens a fd via the `{var}>` form.

**See also**: §6.6 (duplicating fds), §6.7 (move and close), §11.x
(`exec`-replace and process replacement), §13.x (errexit interaction
with exec), BCS0101 (strict mode), BCS0107 (function organisation),
BCS0703 (messaging).

#fin
