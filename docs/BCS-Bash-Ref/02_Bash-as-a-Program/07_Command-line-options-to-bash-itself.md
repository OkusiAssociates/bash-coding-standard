<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.7 Command-line options to bash itself

The bash binary accepts both single-character and `--`-prefixed long options. This is the cheatsheet — what each does, when you would reach for it. The options interact with `set` (most of these are equivalent to a `set` call inside the script) and with the invocation modes documented in §2.4.

| Option         | Equivalent to        | Effect                                                       |
|----------------|----------------------|--------------------------------------------------------------|
| `-c STRING`    | —                    | Execute STRING as a one-shot script; remaining args become `$0 $1 …` |
| `-i`           | —                    | Force interactive even without a tty                         |
| `-l`, `--login`| `bash --login`       | Behave as a login shell (sources `~/.profile` chain, §2.5)   |
| `-r`, `--restricted` | —              | Restricted shell (§20.14)                                    |
| `-s`           | —                    | Read commands from stdin even when arguments are present     |
| `-x`           | `set -x`             | Trace every command before execution                         |
| `-v`           | `set -v`             | Echo input lines as read                                     |
| `-e`           | `set -e`             | Exit on error (BCS0101)                                      |
| `-u`           | `set -u`             | Treat unset variables as errors (BCS0101)                    |
| `-o NAME`      | `set -o NAME`        | Set a long option (`pipefail`, `errtrace`, …)                |
| `-O NAME`      | `shopt -s NAME`      | Set a `shopt` option                                         |
| `+O NAME`      | `shopt -u NAME`      | Unset a `shopt` option                                       |
| `--norc`       | —                    | Skip `~/.bashrc` (interactive only)                          |
| `--noprofile`  | —                    | Skip the login-mode profile chain                            |
| `--rcfile FILE`| —                    | Use FILE instead of `~/.bashrc`                              |
| `--posix`      | `set -o posix`       | POSIX-conformance mode                                       |
| `--noediting`  | —                    | Disable readline in interactive mode                         |
| `--debugger`   | —                    | Enable debugger hooks (used by `bashdb`)                     |
| `--version`    | —                    | Print version and exit                                       |
| `--help`       | —                    | Brief help and exit                                          |

```bash
# scenario: launch a child Bash with extglob and globstar already active
bash -O extglob -O globstar -c 'shopt extglob globstar'
# ⇒ extglob        on
# ⇒ globstar       on
# scenario: one-shot script with positional args
bash -c 'printf "%s\n" "$@"' _ apple banana cherry
# ⇒ apple
# ⇒ banana
# ⇒ cherry            ($0 is set to "_" and discarded)
```

```bash
# scenario: trace a buggy startup quickly
bash -x -c 'for i in 1 2 3; do echo "$i"; done'
# ⇒ + for i in 1 2 3
# ⇒ + echo 1
# ⇒ 1
# ...
```

**See also**: §2.4 (which combination of `-i`/`-l`/`-c` makes a shell interactive vs login), §2.5 (`--rcfile`, `--noprofile` interaction with the startup chain), `set` and `shopt` builtins (§30.43, §30.45), §20.14 (`--restricted`).

#fin
