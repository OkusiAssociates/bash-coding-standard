<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.12 Detaching from the terminal

Full daemonisation — what C programs achieve via the classic
double-fork dance — is genuinely hard in Bash and almost always the
wrong tool. This chapter shows the canonical recipe in case you must,
and the modern alternative you should use first.

### Why double-fork at all?

Calling `setsid(2)` only succeeds if the caller is not already a
process group leader, so the recipe is:

1. **fork** — first child is no longer the parent's process group
   leader.
2. First child calls `setsid()` — becomes session leader with no
   controlling terminal.
3. **fork again** — grandchild is no longer a session leader, so it
   can never re-acquire a controlling terminal even if it opens a tty.
4. Grandchild `chdir("/")` so it does not pin a removable filesystem.
5. Grandchild sets `umask(0)` so file modes are entirely under its
   control.
6. Grandchild closes fds 0/1/2 and reopens them on `/dev/null` (or log
   files).
7. First child exits; the original parent already exited; the
   grandchild is reparented to PID 1 (`init`/`systemd`).

### Bash skeleton: a hand-rolled daemon

```bash
#!/usr/bin/env bash
# scenario: hand-rolled detachment using setsid + redirections.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r LOGFILE=/var/log/myworker.log
declare -r PIDFILE=/run/myworker.pid

daemonise() {
  # setsid --fork covers steps 1-3 in one call; we then do 4-6 in-shell.
  setsid --fork bash -c '
    set -euo pipefail
    cd /
    umask 0
    exec </dev/null >>"$1" 2>&1
    echo "$BASHPID" > "$2"
    exec "${@:3}"
  ' _ "$LOGFILE" "$PIDFILE" /usr/local/bin/myworker --foreground
}

daemonise
printf 'started; pid in %s\n' "$PIDFILE"
```

`setsid --fork` collapses steps 1-3 into one call; the inner
`bash -c` body performs the cwd, umask, fd redirection, and pidfile
write, then `exec`s the real worker. The outer script returns
immediately and the worker is reparented to `init`/`systemd`.

### Side-by-side: bash vs systemd

```ini
# scenario: the same worker as a systemd unit — far less moving parts.
# /etc/systemd/system/myworker.service
[Unit]
Description=My worker
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myworker --foreground
Restart=on-failure
StandardOutput=append:/var/log/myworker.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
```

```bash
# scenario: install + start the unit.
sudo install -m 0644 myworker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now myworker.service
```

`systemctl` handles every step the bash skeleton enumerates: it forks,
calls `setsid(2)`, sets up cgroups, manages stdout/stderr capture,
restarts on failure, and tracks the pid for you. `Type=simple` works
because the daemonising responsibility moves out of your script —
write your worker as a normal foreground program and let systemd
detach it.

### Trade-off

| Concern | Hand-rolled bash | systemd unit |
|---------|------------------|--------------|
| Lines of "infrastructure" code | ~15 | 0 (worker stays foreground) |
| Restart on failure | hand-rolled loop | `Restart=on-failure` |
| Log rotation | hand-rolled or external | `journalctl` + `logrotate` |
| Resource limits | `ulimit` only | `LimitNOFILE`, cgroup controls |
| Boot-time start | rc-script, cron `@reboot` | `WantedBy=multi-user.target` |
| Status / health | pidfile inspection | `systemctl status` |
| Portability to non-systemd hosts | yes | no (use `init.d`/`launchd`) |

The bash recipe earns its keep on minimal containers, embedded
systems, and ad-hoc rescue work where you cannot install or rely on
systemd. Everywhere else, write the worker as a foreground program
and let the supervisor detach it.

### Strict-mode interaction

`set -euo pipefail` is preserved across `exec`; the `bash -c` body
inside `daemonise()` re-asserts strict mode because option state does
not survive across the inner `exec`. Always re-enable strict mode in
any shell body launched via `setsid --fork bash -c '…'`.

**See also**: §11.6 (process groups and sessions),
§11.11 (`nohup`/`setsid`/`disown`), §11.13 (environment inheritance),
BCS0101, BCS0603, BCS1006.

#fin
