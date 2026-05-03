<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.1 The Bash process tree at runtime

A Bash script is not a single process; it is a parent shell that spawns
children for some constructs and runs others in-process. Whether a given
construct forks decides which variable assignments survive, which traps
fire, and which signals reach which PID. Strict-mode discipline (BCS0101)
lives or dies by knowing which line forks and which does not.

### Construct-to-tree map

| Construct | Forks? | Notes |
|-----------|:------:|-------|
| Builtin (`echo`, `read`, `[[`) | no | runs in current shell |
| Function call | no | shares variables, traps |
| Brace group `{ …; }` | no | grouping only |
| `exec cmd` | no | replaces current shell, does not return |
| External command | yes | classic `fork(2)` + `execve(2)` |
| Command substitution `$(…)` | yes | child writes to a pipe |
| Process substitution `<(…)` `>(…)` | yes | child plus a `/dev/fd/N` pipe |
| Subshell `( … )` | yes | explicit fork, no exec |
| Background `cmd &` | yes | new pgid when job control on |
| Pipeline `a \| b` | yes | one fork per stage (see `lastpipe`) |

### Worked example: pstree of every construct

```bash
#!/usr/bin/env bash
# scenario: snapshot the process tree under five forking constructs.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SELF=$$
printf 'top-level pid=%d\n' "$SELF"

# Each line below forks at least once; pstree freezes the moment.
echo "subst=$(pstree -p "$SELF" | head -1)"          # $(...) child
( pstree -p "$SELF" | sed -n '1p' )                  # ( ... ) child
diff <(echo a) <(echo a) && echo 'procsub ok'        # >(... ) <(... )
sleep 0.1 | sleep 0.1                                # pipeline (two forks)
sleep 1 & wait "$!"                                  # background + wait
```

`pstree -p $$` printed inside `$(…)` shows the script PID with a child
shell hanging off it; the same printed inside `( … )` shows the same
parent but a different child PID — proof that each construct fakes a
fresh process. Builtins and functions never appear as new nodes.

### ASCII shape under each construct

```
script (pid=4711)
├── $(pstree -p 4711 ...)        ← bash subshell (pid=4712)
│       └── pstree (pid=4713)
├── ( pstree -p 4711 | sed ... ) ← bash subshell (pid=4714)
│       ├── pstree (pid=4715)
│       └── sed    (pid=4716)
├── <(echo a) >(echo a)          ← two procsub children (pid=4717,4718)
├── sleep 0.1 | sleep 0.1        ← pipeline (pid=4719,4720)
└── sleep 1 &                    ← backgrounded child (pid=4721)
```

A function call or `{ …; }` group would not add a node here; control
returns inside the same `script` row.

### lastpipe: the pipeline exception

`shopt -s lastpipe` runs the **rightmost** stage of a pipeline in the
current shell when the shell is non-interactive and job control is off.
The other stages still fork; only the last is in-process.

```bash
#!/usr/bin/env bash
# scenario: prove lastpipe lets the right-hand side mutate parent state.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob lastpipe
set +m                                                # disable job control

declare -i count=0
printf '%s\n' a b c | while read -r _; do count+=1; done
printf 'count=%d\n' "$count"
# ⇒ count=3   (without lastpipe: count=0, the loop ran in a subshell)
```

Without `lastpipe` the `while` reads in a forked child; assignments to
`count` evaporate when that child exits — a footgun that BCS0906 calls
out for `find … | while`.

### Strict-mode interaction

`set -e` and `inherit_errexit` (BCS0101) follow the fork. A `false` in a
brace group aborts the parent; the same `false` in `( false )` aborts
only the subshell, returns a non-zero status, and the parent then
honours `errexit` on the failing exit code. Knowing which body forks
tells you whether a failure is local or terminal.

### Inspection idioms

- `pstree -p "$$"` — full subtree from the script down.
- `ps -o pid,ppid,pgid,comm --forest` — flat ancestor view.
- `ps --ppid "$$" -o pid,comm` — direct children only.
- `BASHPID` (§11.2) is the only reliable handle on the *current* node.

### Common pitfalls

- Treating `cmd | tee` as in-process: `tee` always forks; the `tee`
  variant of `read … | while` still loses the `read`-side state unless
  `lastpipe` is on (BCS0906).
- Assuming `( cmd )` and `{ cmd; }` are interchangeable: only the
  brace group preserves variable mutations.
- Counting forks for `$( $( … ) )`: each `$()` fork is independent;
  the inner one runs *inside* the outer subshell.
- Forgetting that `exec >file` *redirects* without forking but
  rebinds the current shell's stdout for the rest of the script;
  `exec cmd` *replaces* the shell entirely.

### Quick reference: fork cost intuition

External commands and forking constructs cost a `fork(2)` (cheap on
Linux thanks to copy-on-write) plus, for external commands, an
`execve(2)`. Builtins, brace groups, and function calls are free —
they manipulate parser state only. Tight inner loops that invoke
`grep`, `sed`, or `awk` once per iteration pay this cost on every
trip; replace them with bash builtins (`[[ =~ ]]`, parameter
expansion, `printf -v`) when the loop body permits.

**See also**: §11.2 (PID variables), §11.3 (subshell origins),
§11.4 (`BASH_SUBSHELL`), §11.6 (process groups), §16 (concurrency),
BCS0101, BCS0411, BCS0504, BCS0906.

#fin
