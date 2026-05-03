<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.3 Subshell origins

A subshell is a forked copy of the shell that inherits state at the
fork point and discards its own state on exit. Knowing every construct
that triggers one is a precondition for reasoning about variable
mutation, trap firing, and exit-status propagation under
`inherit_errexit` (BCS0101).

### The complete catalogue of forking constructs

| Construct | Reason it forks |
|-----------|-----------------|
| `( cmd )` | explicit subshell — grouping + isolation |
| `$( cmd )` | command substitution — child writes to a pipe |
| `<( cmd )`, `>( cmd )` | process substitution — child plus a `/dev/fd/N` pipe |
| `cmd &` | background — child runs asynchronously |
| `cmd1 \| cmd2` | pipeline — one fork per stage (with `lastpipe` exception) |
| `coproc cmd` | coprocess — async child with bidirectional pipes |

The constructs that look similar but **do not** fork:

| Construct | Why it stays in-process |
|-----------|-------------------------|
| `{ cmd; }` | brace group is a parser feature, not a fork |
| `func args` | function call shares the calling shell |
| `source file` / `. file` | inlines the file |
| `exec cmd` | replaces the shell, no return |

### What the child inherits

A forked subshell inherits, by value at fork time:

- Variables (including arrays) and exported environment.
- Open file descriptors (with `O_CLOEXEC` honoured for execs only).
- Working directory and umask.
- Trap dispositions for **EXIT** (preserved) and other signals
  (reset to default — see §12.x for trap-in-subshell rules).
- Shell options (`set`, `shopt`).
- Functions and aliases.

Mutations made in the child do not propagate to the parent — the lesson
behind BCS0906's `find … | while read` warning.

### Worked example: variable scoping at the fork boundary

```bash
#!/usr/bin/env bash
# scenario: show that a subshell mutation does not leak to the parent.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0

( count=99; printf 'inside subshell: count=%d\n' "$count" )
printf 'outside subshell: count=%d\n' "$count"
# ⇒ inside subshell: count=99
# ⇒ outside subshell: count=0
```

The same trap holds for `$(…)`, `<(…)`, `>(…)`, `&`, and every stage of
a pipeline that runs in a forked child.

### The pipeline exception: `lastpipe`

`shopt -s lastpipe` causes the **last** pipeline stage to run in the
current shell when the shell is non-interactive **and** job control is
disabled (`set +m`, the default for scripts). The stages to its left
still fork.

```bash
#!/usr/bin/env bash
# scenario: lastpipe collapses one fork — variable assignments now persist.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob lastpipe
set +m   # mandatory: lastpipe is silently ignored when job control is on

declare -a names=()
printf '%s\n' alice bob carol | readarray -t names
printf 'collected %d names: %s\n' "${#names[@]}" "${names[*]}"
# ⇒ collected 3 names: alice bob carol
```

Without `lastpipe` the `readarray` runs in a subshell whose `names=`
assignment vanishes the moment the pipeline exits. This is why §11.1's
"pipeline forks at least one subshell" rule needs the qualifier
*"unless `lastpipe` is in effect on the rightmost stage"*.

### Strict-mode trap

`set -e` follows the fork: a `false` inside `( … )` aborts the
subshell, which then exits non-zero and *re-triggers* `errexit` in the
parent. A `false` inside `$(…)` triggers `inherit_errexit` so the
substitution itself fails — without that shopt, the parent silently
sees the empty result of a failed substitution.

### Trap behaviour at the fork boundary

A subshell inherits the EXIT trap, but **all other** trap dispositions
reset to default. This is bash's deliberate concession to POSIX: a
forked child should not be obliged to honour every signal handler the
parent installed for itself. If a subshell needs the same SIGTERM
handler as the parent, re-install it inside the subshell body. The
EXIT trap inheritance is the reason a function whose cleanup relies on
EXIT will fire twice when called from a subshell — once when the
subshell exits, again when the parent does. Use `BASH_SUBSHELL`
(§11.4) to gate cleanup on depth when needed.

### Common subshell footguns

- `var=$(cmd1 | cmd2)` — both pipeline stages are forked children of
  the `$(…)` subshell; mutations vanish three levels deep.
- `cd dir; ( do-work )` — the `cd` persists; the do-work runs in a
  child but shares cwd at fork time, then any further `cd` inside is
  local to the child only.
- `( set -e; foo; bar )` — `errexit` rules apply only inside the
  subshell; a parent `set +e` does not suppress a child failure unless
  you check the subshell's own exit status.
- Functions defined inside `$(…)` are not visible to the parent;
  define them at the top level or `source` them.

**See also**: §11.1 (process tree), §11.2 (PID variables),
§11.4 (`BASH_SUBSHELL`), §11.5 (foreground vs background),
BCS0101, BCS0411, BCS0504, BCS0906.

#fin
