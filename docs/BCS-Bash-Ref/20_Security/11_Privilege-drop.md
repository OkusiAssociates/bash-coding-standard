<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.11 Privilege drop

A script that starts as root should retain root only for the operations
that demand it. Drop privileges as early as possible — ideally immediately
after the privileged setup phase — and re-acquire only via an audited
boundary (sudo callback or pre-arranged capability).

### Three tools, ranked

`sudo -u`, `runuser`, and `setpriv` cover the practical spectrum. Pick the
least-privileged tool that suffices.

| Tool      | Best for                          | Availability                    |
|-----------|-----------------------------------|---------------------------------|
| `sudo -u` | Simple "run as user X"            | Universal where sudo installed  |
| `runuser` | systemd hosts, no PAM noise       | systemd distros (most modern)   |
| `setpriv` | Capability/securebits/no-new-privs| util-linux 2.32+                |

### `setpriv` — capability-drop incantation

`setpriv` is the most precise. The canonical incantation for "run this
under user `nobody`, with no capabilities, with `no_new_privs` so even an
SUID binary inside cannot re-elevate" is three lines:

```bash
# scenario: drop to nobody for a network-facing subtask
declare -ri NOBODY_UID=$(id -u nobody)
declare -ri NOBODY_GID=$(id -g nobody)
setpriv \
  --reuid="$NOBODY_UID" --regid="$NOBODY_GID" \
  --clear-groups --no-new-privs \
  --inh-caps=-all --bounding-set=-all \
  -- /usr/local/libexec/fetch-feed --url "$URL"
```

Five things are happening: `--reuid`/`--regid` set both real and effective
ids (so the child cannot setuid back), `--clear-groups` removes
supplementary groups (a script's most-overlooked privilege carrier),
`--no-new-privs` makes future `execve` ignore SUID and file capabilities,
and `--inh-caps=-all --bounding-set=-all` empties both inheritable and
bounding capability sets. The `--` is critical: it terminates `setpriv`
options so the target command's argv is not reinterpreted.

### `sudo -u` — the simpler case

When the host has sudo and capabilities are not required, `sudo -u --`
suffices:

```bash
# scenario: subtask runs as build user, no env carry-over
sudo -u builduser -- /usr/local/bin/run-build "$JOB_ID"
```

The `--` after `-u <user>` separates sudo's options from the command's
argv. `sudo -E` (preserve environment) is almost always wrong in
privilege-drop contexts; let `env_reset` strip the parent's environment.

### Re-acquiring privilege

A long-running script that drops to `nobody` for fetch and elevates for
write must arrange the elevation path *before* the drop, since post-drop
no setuid path remains. Two patterns work:

```bash
# scenario: pre-arrange a sudo callback before dropping
sudo -n true || die 13 'cannot pre-authenticate sudo'
# … privileged setup …
do_unprivileged_work_and_emit_results
# back in privileged main:
sudo -n install -m 0644 -- "$results" /var/lib/myapp/state
```

The `sudo -n true` pre-authenticates without prompting, refreshing the
sudo timestamp. The post-work `sudo -n` succeeds without re-prompting if
the timestamp has not expired and the sudoers entry is `NOPASSWD`.

The alternative is a privileged supervisor that `fork+exec`s an
unprivileged child via `setpriv`/`sudo`, then receives results over a
pipe. The supervisor never drops; the child never elevates. This is the
shape of every well-designed network daemon.

### Auditing the boundary

Every privilege transition is a security event. Log the EUID before and
after:

```bash
# scenario: audit the transition
info "dropping to nobody (euid was $EUID)"
exec setpriv --reuid="$NOBODY_UID" --regid="$NOBODY_GID" \
             --clear-groups --no-new-privs -- "$0" --child "$@"
```

Using `exec` replaces the parent so there is no privileged process left
holding open file descriptors that a successful exploit on the child
could inherit.

**See also**: §20.8 SUID restrictions, §20.13 symlink races, BCS1001
SUID/SGID prohibition, BCS1007 environment scrubbing.

#fin
