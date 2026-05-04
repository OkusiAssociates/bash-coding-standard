<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.3 Multiple coprocesses

Bash 4.0 supported only one anonymous `coproc` at a time. Bash 4.4+ allows multiple **named** coprocesses to run concurrently — each must be given a name so its array variables and PID do not collide.

### Naming and fd dereference

Each named coproc creates a two-element array `NAME` whose elements `${NAME[0]}` and `${NAME[1]}` are the read- and write-end file descriptors, plus a scalar `NAME_PID` carrying the child's PID. To `read` from coproc `A` you must dereference its specific array — there is no implicit "current" coproc.

```bash
# scenario: route a query through one of two coprocs based on input
coproc A { while read -r n; do printf '%s\n' "$((n*2))"; done; }
coproc B { while read -r n; do printf '%s\n' "$((n*n))"; done; }

double() { printf '%s\n' "$1" >&"${A[1]}"; read -r ans -u "${A[0]}"; echo "$ans"; }
square() { printf '%s\n' "$1" >&"${B[1]}"; read -r ans -u "${B[0]}"; echo "$ans"; }

double 7        # ⇒ 14
square 7        # ⇒ 49

# tear down — close write ends so child loops exit, then wait
exec {A[1]}>&- {B[1]}>&-
wait "$A_PID" "$B_PID"
```

The non-obvious bits are the syntax `>&"${A[1]}"` (write to coproc A's stdin) and `read -u "${A[0]}"` (read from its stdout). Forgetting the array index and writing `>&"$A"` silently fails: `$A` expands to the array's first element by default but the redirection parses ambiguously.

### fd close discipline

Coprocs do not exit until their write end (from the parent's perspective) is closed and their input loop hits EOF. Leaving fds open across an `exec` is a classic leak: a long-running child started later in the script will inherit the coproc fds and prevent the producer from ever seeing EOF.

```bash
# scenario: explicit close before launching unrelated children
coproc WORKER { while read -r line; do process "$line"; done; }

printf '%s\n' job1 job2 job3 >&"${WORKER[1]}"
exec {WORKER[1]}>&-              # close write end → worker sees EOF
wait "$WORKER_PID"               # reap

# now safe to spawn other long-lived processes — no leaked fds
exec /usr/bin/some-daemon
```

The `{NAME[1]}>&-` form is required: a literal numeric `exec 12>&-` would close the wrong fd if Bash assigned a different number. Always close by name.

### Pre-4.4 caveat

On Bash 4.0-4.3, attempting a second `coproc` while the first is alive prints `bash: only one coprocess at a time`. Detect with `((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4)))` (BCS0409) before relying on the multi-coproc pattern.

### Anti-pattern

```bash
# wrong — same name reused; second coproc clobbers the first's array
coproc CHILD { read -r line; printf '%s\n' "$line"; }
coproc CHILD { read -r line; printf '%s\n' "$line"; }   # second launch
                                                        # silently replaces $CHILD
                                                        # — first child unreachable

# right — distinct names per coproc instance
coproc PARSER  { while read -r line; do printf 'parsed:%s\n' "$line"; done; }
coproc EMITTER { while read -r line; do printf 'emitted:%s\n' "$line"; done; }
```

**See also**: §17.1 (the `coproc` builtin), §17.2 (bidirectional fd pairs and stdbuf), §1.2 (file descriptor model), §11.3 (`wait`), BCS0409 (Bash version detection), BCS1101 (background job management).

#fin
