<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.5 The shell environment

Every process carries an **environment** — an array of `KEY=VALUE` strings inherited at `fork(2)` and replaced wholesale at `execve(2)`. The shell distinguishes plain shell variables (visible only inside the current shell) from environment variables (copied into every child's environ block).

### `export` versus a bare shell variable

A bare assignment populates the shell's symbol table but is **not** copied into the environment of forked children. `export` (or `declare -x`) flips the export bit so the variable is included in `environ(7)` at the next `execve`.

```bash
# scenario: prove the difference
SHELL_ONLY='only here'
export ENV_VAR='everywhere'

bash -c 'echo "SHELL_ONLY=${SHELL_ONLY:-unset}; ENV_VAR=${ENV_VAR:-unset}"'
# ⇒ SHELL_ONLY=unset; ENV_VAR=everywhere
```

A child process can never see a non-exported variable. There is no syscall to "read the parent's bare variables" — the membrane is one-way and only at `exec` boundaries.

### Inheritance and propagation

```
  parent shell                        child process
  ┌──────────────┐    fork(2)         ┌──────────────┐
  │ env: A,B,C   │ ─────────────────▶ │ env: A,B,C   │   (copy)
  │ shell: X,Y   │                    │ (no shell vs)│
  └──────────────┘                    └──────────────┘
                                              │ execve("prog", argv, environ)
                                              ▼
                                       ┌──────────────┐
                                       │ prog runs    │
                                       │ env: A,B,C   │   (preserved)
                                       └──────────────┘
```

After the child exits, the parent's environment is untouched: there is no back-channel for a child to mutate parent state. To pick up changes you must re-source (`source ~/.bashrc`) or re-exec the parent.

### Demonstrating environment propagation

```bash
# scenario: per-command override without polluting the shell
PATH="/usr/local/bin:$PATH" git status         # PATH set only for git
echo "${PATH@Q}"                               # parent PATH unchanged

# scenario: env var visible to a Python child
export PYTHONDONTWRITEBYTECODE=1
python3 -c 'import os; print(os.environ["PYTHONDONTWRITEBYTECODE"])'   # ⇒ 1
```

### Inherited process attributes

Beyond `environ`, `fork(2)` also copies:

- **Working directory** (`$PWD`, `$OLDPWD`).
- **`umask`** — affects `open()` mode bits (BCS1006).
- **Resource limits** (`ulimit`, see `getrlimit(2)`).
- **Locale**: `LANG`, `LC_*`, `LANGUAGE` (see §5.13).
- **Time zone** via `$TZ`.
- **`PATH`** — search semantics with security implications (BCS1002, §20.2).

`PATH` deserves special caution: a child that inherits a writable directory in `$PATH` can be hijacked. BCS1002 mandates an explicit, hard-coded `PATH` at script start.

### Anti-pattern

```bash
# wrong — assignment without export, expecting children to see it
DEBUG=1
./run-tests.sh        # DEBUG is unset inside run-tests.sh

# right — either export, or one-shot prefix
DEBUG=1 ./run-tests.sh
```

**See also**: §1.1 (fork/exec lifecycle), §1.3 (files), §2.5 (startup files), §5.13 (locale), §20.2 (PATH security), BCS1002 (PATH), BCS1003 (IFS), BCS1007 (environment scrubbing before exec).

#fin
