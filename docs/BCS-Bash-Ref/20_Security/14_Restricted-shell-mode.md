<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.14 Restricted shell mode

`bash -r` or `bash --restricted` runs in restricted mode.

- Cannot `cd`.
- Cannot set or unset `SHELL`, `PATH`, `ENV`, `BASH_ENV`.
- Cannot specify command names containing `/`.
- Cannot redirect output to files.
- Cannot use `exec` to replace shell with another program.
- Use case: chrooted environment for limited users; not a security boundary on its own.
- Easy to escape if the user can run any unrestricted shell from inside.

```text
# scenario: worked rbash escape — anything that re-execs bash unrestrictedly wins
$ rbash
rbash$ cd /tmp                      # ⇒ rbash: cd: restricted
rbash$ ls /etc                      # ⇒ ok — read-only ops are unrestricted
rbash$ vi notes.txt                 # editor opens
:!bash                              # vi shell-out ⇒ unrestricted /bin/bash
$ id                                # ⇒ same uid; rbash bypassed
```

Any binary whitelisted on PATH that exposes a shell-out (vi, less, awk
`system()`, find `-exec`, perl, python, ssh `~C`, even `man` with
`MANPAGER`) is an escape. Likewise, any file that bash will source —
because `BASH_ENV` is locked, but if a startup file like `~/.bashrc` is
writable, the user edits it before invoking rbash.

**Treat rbash as a UI hint, not a security boundary.** Real confinement
needs `chroot`, `setuid` capability dropping (§20.11), namespaces, or
proper sandboxing (`bwrap`, `firejail`). Pair rbash with: a curated
read-only `$HOME`, a tightly-scoped PATH whose binaries cannot shell out,
and a non-interactive login shell.

**See also**: §20.8 (SUID restrictions), §20.11 (privilege drop), §20.01 (threat model).

#fin
