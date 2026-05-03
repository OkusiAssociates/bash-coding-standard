<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.5 Startup file chains

Each invocation mode reads a different chain of startup files. This chapter is the canonical map of which files are sourced when, in what order, and why the `.bashrc`-from-`.bash_profile` idiom exists.

### Files-by-mode flowchart

```
                ┌──────────────────────────────────┐
                │ How was bash invoked?            │
                └──────────────┬───────────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
   LOGIN shell          INTERACTIVE non-login    NON-INTERACTIVE
   (-l, --login,        (terminal emulator,      (bash script,
    SSH login,           subshell of login)       bash -c, cron)
    console login)
        │                      │                      │
        ▼                      ▼                      ▼
   /etc/profile         /etc/bash.bashrc        ${BASH_ENV}
        │              (Debian/Ubuntu;           if set and
        ▼               RHEL uses /etc/          file exists;
   first existing of:   bashrc; macOS none)      no system file
   ~/.bash_profile             │
   ~/.bash_login               ▼                       │
   ~/.profile           ~/.bashrc                      ▼
        │                      │              (no profile, no rc)
        ▼                      ▼
   (interactive prompt)    (interactive prompt)

  On EXIT of a login shell:  ~/.bash_logout, then /etc/bash.bash_logout
```

The login chain runs **once per login session**; the interactive non-login chain runs **once per terminal window** that is not itself a login shell. `BASH_ENV` is the only file Bash reads for non-interactive invocations; in POSIX mode the equivalent is `ENV`.

The system-wide interactive non-login file path varies by distribution: Debian and Ubuntu use `/etc/bash.bashrc` (Bash is built with `-DSYS_BASHRC`); RHEL/Fedora wire `/etc/bashrc` from `~/.bashrc`; macOS ships nothing system-wide. Test with `bash -ic 'echo $-'` and inspect what was sourced.

### The `.bashrc`-from-`.bash_profile` idiom

A login shell does **not** read `~/.bashrc`. A subshell of that login does. Result: alias and function definitions in `~/.bashrc` are invisible at the login prompt itself. The standard fix is to source `~/.bashrc` from `~/.bash_profile`:

```bash
# ~/.bash_profile
# scenario: ensure interactive aliases/functions are available at login
[[ -f ~/.bashrc ]] && source ~/.bashrc

# put login-only setup (PATH augmentation, ssh-agent launch) AFTER this line
export PATH="$HOME/.local/bin:$PATH"
```

Without this, you log in via SSH, type `ll`, and get "command not found" — but the same alias works in a `tmux` pane started from the login shell. Sourcing `~/.bashrc` first lets login add to the same configuration; doing it last would mean `~/.bashrc` clobbers login-only `PATH` entries.

### `BASH_ENV` for non-interactive scripts

Cron-launched scripts and `ssh host bash script.sh` are non-interactive. The shell skips every `*rc` and `*profile` file. The single hook is `BASH_ENV`:

```bash
# scenario: give cron jobs access to a shared init file
# In crontab:
#   BASH_ENV=/etc/cron-env.bash
#   * * * * * bash /usr/local/bin/job.sh

# /etc/cron-env.bash
export PATH='/usr/local/bin:/usr/bin:/bin'
export TZ='Asia/Jakarta'
```

`BASH_ENV` is not searched on `$PATH` — it must be an absolute path — and it is **not** read for `bash --posix` (use `ENV` instead).

### Common pitfalls

```bash
# wrong — interactive-only code in ~/.bash_profile
PS1='\u@\h:\w\$ '            # has no effect under bash -c

# right — interactive cosmetics belong in ~/.bashrc
# (and ~/.bash_profile sources ~/.bashrc, see idiom above)

# wrong — environment variables only in ~/.bashrc
export EDITOR=vim            # missing under  ssh host 'echo $EDITOR'

# right — exported env in profile chain (or both, with .bashrc sourced)
```

The asymmetric rule of thumb: **prompt, aliases, completion in `~/.bashrc`; `PATH`, `EDITOR`, `LANG` in `~/.bash_profile`** — and chain them with the idiom above so both are available everywhere.

**See also**: §2.4 (which mode triggers which chain), §2.6 (`BASH_ENV` and `ENV` semantics), §2.8 (exit lifecycle and `~/.bash_logout`), §1.5 (environment propagation), BCS0111 (configuration file loading).

#fin
