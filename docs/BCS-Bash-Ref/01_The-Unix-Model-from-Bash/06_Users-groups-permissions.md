<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.6 Users, groups, permissions

The discretionary access control (DAC) model that every Bash script must respect. Linux distinguishes three IDs per process — real, effective, and saved — and the `chmod`/`chown` machinery operates on inodes via mode bits. Scripts that touch privileges must understand the trio; those that don't may forge ahead with `id` and `umask` alone.

The three IDs (each in user and group flavour):

| ID         | Meaning                                  | Bash inspection                |
|------------|------------------------------------------|--------------------------------|
| Real (ruid)| Who started the process                  | `id -ru`                       |
| Effective (euid) | Used for permission checks         | `id -u`, `$EUID`               |
| Saved (suid)     | Stash for `seteuid` swap-back      | not exposed via Bash; needs C  |

A non-SUID program normally has all three equal. SUID binaries (such as `sudo`, `passwd`) start with `euid=0` and `ruid=$invoker`, then juggle them via `seteuid()`. Bash refuses SUID on scripts (BCS1001 — SUID/SGID Prohibition); use `sudo` invocation, not `chmod u+s`.

Mode bits and their octal values:

| Symbol | Octal | Effect                              |
|--------|-------|-------------------------------------|
| `r`    | 4     | read                                |
| `w`    | 2     | write                               |
| `x`    | 1     | execute / traverse (on directory)   |
| `s` on owner   | 4000 | SUID — run as file owner     |
| `s` on group   | 2000 | SGID — run as file group / inherit group on dir |
| `t`    | 1000  | sticky — only owner may unlink (e.g. `/tmp`) |

Plus the optional layers most scripts can ignore: ACLs (`getfacl`, `setfacl`) and capabilities (`getcap`, `setcap`).

```bash
# scenario: show effective vs real identity, then grant a binary CAP_NET_BIND_SERVICE
printf 'ruid=%s euid=%s\n' "$(id -ru)" "$EUID"
# ⇒ ruid=1000 euid=1000
sudo setcap 'cap_net_bind_service=+ep' ./mywebd
getcap ./mywebd
# ⇒ ./mywebd cap_net_bind_service=ep
chmod 0640 secret.conf       # owner rw, group r, other none
chmod g+s shared/            # SGID dir: new files inherit shared's group
```

`umask` masks the bits that `creat(2)` would otherwise grant. A `umask 022` strips group/other write; `umask 077` makes new files private. Set it explicitly at the head of any script that creates sensitive files (BCS1006).

**See also**: §1.1 (process IDs), §1.5 (environment carries identity hints like `$USER`), §6.6 (umask interaction with redirection-created files), §10 (security — SUID prohibition, PATH hardening), §20.8 (why SUID scripts are forbidden).

#fin
