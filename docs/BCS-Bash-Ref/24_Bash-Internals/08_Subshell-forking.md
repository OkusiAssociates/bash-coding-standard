<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.8 Subshell forking

When bash needs a subshell — an explicit `( … )` group, a command
substitution `$(…)`, the upstream stages of a pipeline (without
`shopt -s lastpipe`), or `&` for background execution — it calls
`fork(2)`. The child inherits a copy-on-write view of the parent's
address space, the parent's open file descriptors, and a near-complete
snapshot of shell state.

What the child gets:

- **Memory** (copy-on-write): all variables, functions, internal state.
- **Open file descriptors**: inherited as references to the same
  kernel-side `struct file` — writes to the same fd from parent and
  child interleave at the kernel.
- **Signal handlers**: inherited as set in the parent. Caught signals
  reset to default if the child later `exec`s a new program.
- **Process group**: depends on whether the subshell is part of a
  pipeline (each pipeline stage gets its own pgid by default in
  job-control mode) or a plain background job.
- **Environment**: the parent's environment becomes the child's
  environment.

The implication that traps users repeatedly: **subshell variable
changes are local to the subshell**. The parent never sees them. This
is why `$(…)` cannot return values via assignment; it can only return
them via stdout. Bash 5.3 introduces `${ cmd; }` no-fork command
substitution to break this rule on purpose (§25.1) — but for everything
through 5.2, the rule is absolute.

### A `BASHPID` / `BASH_SUBSHELL` demo

`$$` is the **parent shell's PID**. It does *not* update inside a
subshell. `BASHPID` (bash 4.0+) is the PID of the current shell —
parent or subshell — and it does. `BASH_SUBSHELL` is a counter that
increments each time a new subshell is entered, with 0 in the
top-level shell.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

printf 'top:        $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
  $$ "$BASHPID" "$BASH_SUBSHELL"

(
  printf 'subshell-1: $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
    $$ "$BASHPID" "$BASH_SUBSHELL"
  (
    printf 'subshell-2: $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
      $$ "$BASHPID" "$BASH_SUBSHELL"
  )
)

# Same effect inside a command substitution:
who=$(printf 'cmdsub:     $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
  $$ "$BASHPID" "$BASH_SUBSHELL")
printf '%s' "$who"
#fin
```

Typical output (PIDs differ each run):

```
top:        $$=12345  BASHPID=12345  BASH_SUBSHELL=0
subshell-1: $$=12345  BASHPID=12346  BASH_SUBSHELL=1
subshell-2: $$=12345  BASHPID=12347  BASH_SUBSHELL=2
cmdsub:     $$=12345  BASHPID=12348  BASH_SUBSHELL=1
```

`$$` is constant; `BASHPID` reflects the actual process; `BASH_SUBSHELL`
counts nesting depth. Use `BASHPID` for tempfile names that must be
unique per-subshell (otherwise concurrent subshells of the same parent
collide on `$$`). Use `BASH_SUBSHELL` to detect *that* you are in a
subshell — useful for traps that should run only at top level.

### Variable assignment scoping

The single most common subshell-forking surprise:

```bash
# wrong — pipe creates a subshell; count never updates in the parent
declare -i count=0
printf '%s\n' a b c | while read -r line; do
  count+=1
done
printf 'count=%d\n' "$count"
# ⇒ count=0 (the right-hand `while` ran in a subshell of the pipeline)

# right — process substitution keeps the loop in the parent shell
declare -i count=0
while read -r line; do
  count+=1
done < <(printf '%s\n' a b c)
printf 'count=%d\n' "$count"
# ⇒ count=3
```

Or, equivalently, `shopt -s lastpipe` makes the *last* pipeline stage
run in the parent shell (with the subtle caveat that it works only in
non-interactive bash). BCS prefers process substitution (§5.4) because
the scoping is unambiguous.

**See also**: §22.x (idioms cookbook) for the BASHPID-in-tempfile-name
pattern; §17.x (IPC) for shared-fd semantics across subshells; §6.16
(`shopt lastpipe`) for the partial workaround; §25.1 for the bash 5.3
no-fork escape hatch; BCS0202 (variable scoping) for the function-vs-
subshell distinction in BCS-aligned scripts.

#fin
