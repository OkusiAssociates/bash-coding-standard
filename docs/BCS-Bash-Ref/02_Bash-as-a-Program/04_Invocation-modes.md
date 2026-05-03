<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.4 Invocation modes

Bash behaves differently depending on how it was invoked. Confusing the modes is the most common source of "works in my terminal, breaks in cron" bugs — the cron environment is non-interactive, non-login, with a stripped `PATH` and no aliases.

### The four-quadrant matrix

Two orthogonal axes — `interactive | non-interactive` × `login | non-login` — define which startup files are read (see §2.5) and which features (job control, prompt, history) are enabled.

| | **Login** | **Non-login** |
|---|---|---|
| **Interactive** | SSH login, console TTY login, `bash -l`. Reads `/etc/profile` then the first of `~/.bash_profile`, `~/.bash_login`, `~/.profile`. Job control on. | Terminal emulator window inside an existing session, `bash` with no flags from another shell. Reads `/etc/bash.bashrc`, `~/.bashrc`. Job control on. |
| **Non-interactive** | `bash -l script.sh`, `su - user -c …`. Reads login files. Rare — only for cron-like scenarios that explicitly want a login environment. | `bash script.sh`, `bash -c '…'`, `ssh host cmd`, **cron**. Reads `BASH_ENV` only. Job control off. **The cron quadrant.** |

The bottom-right cell is where most surprises happen: cron runs your script with no aliases, no `~/.bashrc`, and a minimal `PATH` (usually `/usr/bin:/bin`).

### Detecting the mode at runtime

```bash
# scenario: emit a one-line classification of the current shell
mode='non-interactive non-login'
[[ $- == *i* ]] && mode="interactive ${mode#non-interactive }"
shopt -q login_shell && mode="${mode/non-login/login}"
echo "$mode"
# bash      ⇒ interactive non-login
# bash -l   ⇒ interactive login
# bash -c   ⇒ non-interactive non-login
# ssh host bash -lc ''  ⇒ non-interactive login
```

`$-` contains the current short option flags: `i` for interactive, `m` for job control. `shopt -q login_shell` is the canonical login detection.

### The cron pitfall

```bash
# scenario: a script that "works in the terminal" but fails in cron
# crontab:  * * * * * /home/me/run.sh
# run.sh contains:  ll /var/log

# wrong — depends on alias from ~/.bashrc, which cron does not source
ll /var/log                # ⇒ /bin/sh: ll: command not found

# right — use the real command and pin PATH (BCS1002)
declare -rx PATH='/usr/local/bin:/usr/bin:/bin'
ls -l /var/log
```

### Single-command and stdin modes

`bash -c 'cmd args' name arg1 arg2` runs the string with `$0=name`, `$1=arg1`, `$2=arg2`. `bash -s` (or no script argument) reads commands from stdin — useful for piping a generated script:

```bash
# scenario: pipe a script body into bash with positional args
printf '%s\n' 'echo "$0 saw $#: $*"' | bash -s pipeline foo bar
# ⇒ pipeline saw 2: foo bar
```

### Selected flags

| Flag | Effect |
|------|--------|
| `-i` | Force interactive (rarely needed; the test on stdin handles it). |
| `-l`, `--login` | Force login behaviour. |
| `-r`, `--restricted` | Restricted shell — no `cd`, no `PATH`/`SHELL`/`ENV` mutation, no `exec` of programmes containing `/`. See §20.14 and §23. |
| `--posix` | POSIX conformance. Strict-mode scripts do not need it. |
| `--noprofile` | Skip login startup files. |
| `--norc` | Skip `~/.bashrc`. |
| `--rcfile FILE` | Read `FILE` instead of `~/.bashrc`. |

The `sh` symlink invocation (`#!/bin/sh` plus a `bash`-as-`sh` install) makes Bash mimic POSIX `sh` — relevant when shipping to systems where `/bin/sh` is dash or ash. BCS0102 mandates an explicit Bash shebang specifically to avoid this ambiguity.

**See also**: §2.5 (which startup files each mode reads), §2.7 (full bash CLI option matrix), §20.14 / §23 (restricted shell), BCS0102 (shebang), BCS1002 (PATH security).

#fin
