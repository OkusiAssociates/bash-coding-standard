<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.8 SUID restrictions

Linux silently ignores the SUID bit on interpreted scripts (BCS1001). The
kernel design reflects an unfixable race: between the kernel reading the
shebang and the interpreter `open(2)`-ing the script, an attacker on the
same filesystem can substitute a different file. macOS still honours SUID
on scripts; doing so on any platform is unsafe regardless of OS support.

Two supported alternatives exist for "shell needs to run as another user":
a sudoers entry, or a small C wrapper that exec's the script with a
sanitised environment.

### Alternative 1 — `sudoers` with `NOPASSWD` and a command alias

The `sudoers` route is correct when one or two specific commands need
elevated privileges and an interactive admin is not available. Pin the
exact command path and arguments using a `Cmnd_Alias`; never permit a
wildcarded command:

```sudoers
# /etc/sudoers.d/backup-runner — installed mode 0440, owned root:root
Cmnd_Alias BACKUP_CMDS = /usr/local/sbin/backup-now, \
                         /usr/local/sbin/backup-verify

backup ALL=(root) NOPASSWD: BACKUP_CMDS
Defaults!BACKUP_CMDS env_reset, secure_path="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin"
```

Three properties matter: the command paths are absolute (no `PATH`
search), arguments are not wildcarded (`*` in sudoers is regex-naive and
typically over-permissive), and `env_reset` plus `secure_path` strip the
caller's environment. The `backup-runner` script is owned root, mode 0755,
in a directory the `backup` user cannot write.

Verify the entry parses and that the matrix is what you expected:

```bash
visudo -cf /etc/sudoers.d/backup-runner   # ⇒ exits 0 if valid
sudo -lU backup                            # ⇒ shows allowed commands
```

### Alternative 2 — SUID C wrapper

When `sudo` is unavailable (containers, embedded targets), a small SUID C
binary is the textbook substitute. The wrapper's job is to clear the
environment, restore a known `PATH`, and `execv` the real script. It must
be tiny, audited, and never grow features.

```c
/* backup-wrapper.c — compile: gcc -O2 -Wall -Wextra -o backup-wrapper backup-wrapper.c
 * install:  install -m 4755 -o root -g root backup-wrapper /usr/local/sbin/
 */
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  (void)argc; (void)argv;
  if (clearenv() != 0) return 1;
  if (setenv("PATH", "/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin", 1) != 0)
    return 1;
  if (setenv("IFS", " \t\n", 1) != 0) return 1;
  /* drop saved-uid is automatic on execv since binary is SUID-root */
  char *const av[] = { "/usr/local/sbin/backup-now", NULL };
  execv(av[0], av);
  return 127;
}
```

The wrapper accepts no arguments — passing argv through is the most common
mistake, since shell metacharacters in argv become injection in the script
(§20.5). If arguments are required, validate them in C against an
allow-list before exec.

Never set the SUID bit on a bash script even on platforms that honour it,
and never rely on `sudo -E` (which preserves the environment) for trusted
scripts; preserve only what you whitelist.

**See also**: §20.5 command-injection vectors, §20.11 privilege drop,
BCS1001 SUID/SGID prohibition, BCS1007 environment scrubbing.

#fin
