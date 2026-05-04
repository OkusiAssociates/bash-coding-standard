<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.4 Shell variables

Bash maintains a long list of reserved variable names with specific
semantics. This chapter is the canonical taxonomy; the full alphabetical
list with type and lifecycle is in Appendix C. The grouping below is
the conceptual map a script author needs in order to know **which**
variable to reach for and **why** it exists — even if the exact value
must be looked up elsewhere.

### Identity and version

- `BASH` — absolute path to the running `bash` binary.
- `BASH_VERSION` — full version string, e.g. `5.2.21(1)-release`.
- `BASH_VERSINFO[]` — six-element array: major, minor, patch, build,
  release, machine. Use this for programmatic version checks; never
  parse `BASH_VERSION` with regex.
- `BASHPID` — the running process's PID. Distinct from `$$`, which
  *never* changes within a script even inside subshells. Use `BASHPID`
  whenever you need the actual current PID.
- `UID`, `EUID`, `GROUPS[]` — real user id, effective user id (after
  `setuid`), supplementary groups.

### Call-stack introspection

These three arrays are parallel: index *i* of one corresponds to index
*i* of the others.

- `BASH_SOURCE[]` — the file each frame was sourced from.
  `${BASH_SOURCE[0]}` is the current file; `${BASH_SOURCE[-1]}` the
  outermost script.
- `FUNCNAME[]` — the function-name stack. `${FUNCNAME[0]}` is the
  current function; outside a function the array is empty.
- `BASH_LINENO[]` — line number at which each frame **called** the
  next. `${BASH_LINENO[0]}` is the line that called the current
  function.
- `BASH_ARGV[]`, `BASH_ARGC[]` — the argument history of every function
  call, populated only when `shopt -s extdebug` is active.

```bash
# scenario: a stack-trace helper for use inside an ERR or EXIT trap
trace() {
  local -i i frames=${#FUNCNAME[@]}
  for ((i=1; i<frames; i++)); do
    printf '  at %s (%s:%d)\n' \
      "${FUNCNAME[i]}" \
      "${BASH_SOURCE[i]}" \
      "${BASH_LINENO[i-1]}"
  done
} >&2

inner() { trace; }
outer() { inner; }
outer 2>&1   # merge stderr into stdout so the trace lines are captured
# ⇒ at inner
# ⇒ at outer
# (line numbers vary; the trace lists each calling frame in order)
```

### Pipeline and regex state

- `PIPESTATUS[]` — exit codes of every stage of the last pipeline.
  Indispensable when `set -o pipefail` is on but you still need to know
  *which* stage failed. The array is overwritten by the next pipeline,
  so capture it immediately.
- `BASH_REMATCH[]` — submatches from the most recent `=~` match.
  Element 0 is the whole match; elements 1+ are the parenthesised
  groups.

```bash
# scenario: capture pipeline failure point and regex submatches
grep -E '^v[0-9]' tags.txt | sort -V | tail -1
declare -ra status=("${PIPESTATUS[@]}")
((status[0] == 0)) || printf 'grep failed (rc=%d)\n' "${status[0]}" >&2

if [[ "v1.2.3-rc4" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-z0-9]+))?$ ]]; then
  printf 'major=%s minor=%s patch=%s pre=%s\n' \
    "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
    "${BASH_REMATCH[3]}" "${BASH_REMATCH[5]:-}"
fi
# ⇒ major=1 minor=2 patch=3 pre=rc4
```

### Runtime values

- `LINENO` — line number of the next command to be executed.
- `SECONDS` — integer seconds since shell start; assignable to reset.
- `EPOCHSECONDS` — current Unix time in seconds (Bash 5.0+).
- `EPOCHREALTIME` — Unix time with microsecond precision (Bash 5.0+).
- `RANDOM` — pseudo-random 0–32767 each access; not cryptographic.
- `SRANDOM` — uniformly distributed 32-bit value (Bash 5.1+); use this
  for any randomness that matters.
- `BASH_SUBSHELL` — depth of the current subshell nesting; `0` at the
  top level.

### Shell-state introspection

- `SHELLOPTS` — colon-joined list of `set -o` options currently on.
- `BASHOPTS` — colon-joined list of `shopt -s` options currently on.
- `BASH_EXECUTION_STRING` — string passed via `bash -c "…"`, empty
  otherwise.

### Locale and I/O

- `LANG`, `LC_ALL`, `LC_CTYPE`, `LC_COLLATE`, `LC_MESSAGES`,
  `LC_NUMERIC`, `LANGUAGE` — locale settings. Set `LC_ALL=C` for
  deterministic byte-level sorting and pattern matching.
- `IFS` — internal field separator. Default is space-tab-newline; many
  bugs come from accidental modification.
- `PWD`, `OLDPWD` — current directory and the previous one (for `cd
  -`).

### Prompts and interactive context

- `PS0` — printed after a command is read but before it executes.
- `PS1` — primary prompt.
- `PS2` — secondary prompt (continuation lines).
- `PS3` — `select` prompt.
- `PS4` — prefix for `set -x` trace lines (default `+ `).
  See §18.13 for prompt-expansion sequences.

### Completion and readline

- `COMP_WORDS[]`, `COMP_CWORD`, `COMP_LINE`, `COMP_POINT`, `COMPREPLY[]`
  — programmable-completion context (set only inside `complete -F`
  callbacks).
- `READLINE_LINE`, `READLINE_POINT` — content and cursor position
  available inside `bind -x`.
- `MAPFILE` — the default array name used by `mapfile`/`readarray` when
  no array is named (§14.3).

### History

- `HISTFILE`, `HISTSIZE`, `HISTFILESIZE`, `HISTCONTROL`, `HISTIGNORE`,
  `HISTTIMEFORMAT` — history configuration; relevant in interactive
  shells, ignored in non-interactive script mode.

### Process and job context

- `$$` — the **shell's** PID at startup. Constant for the lifetime of
  the script and **identical** in every subshell — this is the
  property that distinguishes it from `BASHPID`.
- `$!` — PID of the most recently backgrounded asynchronous command.
- `$?` — exit status of the most recent foreground pipeline.
- `$_` — last argument of the previous simple command.
- `PPID` — parent process's PID; constant for the script's lifetime.

### Useful at debugging time

- `LINENO` is most useful inside `PS4` for `set -x` traces:
  `PS4='+ ${BASH_SOURCE}:${LINENO}: '` produces a trace that names the
  file and line at every step.
- `FUNCNEST` — maximum function-call recursion depth before bash
  aborts; `0` (default) means no limit.
- `SHLVL` — incremented by 1 in each child shell; useful for spotting
  unexpectedly nested `bash -c` invocations.

```bash
# scenario: a debug-friendly PS4 for set -x
PS4='+ ${BASH_SOURCE##*/}:${LINENO} ${FUNCNAME[0]:-MAIN}() '
set -x
greet() { printf 'hi\n'; }
greet
# trace shows: + script.bash:42 greet() printf 'hi\n'
```

### Conventions

Bash's reserved names are upper-case; user globals should also be
upper-case but **never collide with these reserved names**. A common
defensive practice is to prefix project globals (`MYAPP_PATH` rather
than `PATH`) — see BCS0203 for naming conventions and BCS0204 for
the constants/environment split.

### Read-only and system-imposed names

A handful of reserved names are **read-only** and cannot be assigned:
`UID`, `EUID`, `PPID`, `BASHPID`, `BASH_VERSINFO[]`, `EPOCHSECONDS`,
`EPOCHREALTIME`, `LINENO`, `RANDOM` (each access reseeds), `SECONDS`
(assigning resets the counter, not changes its rules), `SHELLOPTS`,
`BASHOPTS`. Attempting to assign produces an error under `set -e` /
strict mode.

### See also

- Appendix C — full alphabetical reserved-variable index with types
- §4.5 — `declare` and how attributes interact with reserved names
- §14.3 — `mapfile` / `readarray` and `MAPFILE`
- §18.13 — prompt-string expansion
- BCS0203 (naming conventions), BCS0204 (constants/environment)

#fin
