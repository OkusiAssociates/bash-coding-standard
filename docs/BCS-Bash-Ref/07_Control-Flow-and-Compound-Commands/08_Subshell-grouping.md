<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.8 Subshell grouping `( … )`

Run a list in a *subshell* — a forked child of the current shell that
inherits the parent's state but mutates only its own copy. The
subshell is the unit of isolation in bash; `( )` is the explicit way
to invoke it (command substitution, pipelines, and background `&` all
fork subshells implicitly).

### Syntax

```
( list )
```

Spaces inside the parentheses are conventional but not required by
the parser; `(cd /tmp; ls)` is legal. The construct exits with the
status of the last command in the list, just like brace grouping. The
form has no trailing semicolon requirement (unlike `{ … }`, §7.9) —
bash recognises `(` and `)` as words in their own right.

### What is and is not inherited

A subshell inherits, by copy:

- All variables (including arrays and associative arrays).
- All function definitions.
- All open file descriptors (the kernel `dup2`s them).
- `set -euo pipefail` and shopts (`inherit_errexit` is the load-bearing
  shopt that makes the inheritance propagate, BCS0101).
- The working directory.

A subshell *resets*:

- All non-EXIT traps to default (BCS0603, §12.4). Set EXIT traps
  inside the subshell if you need cleanup there.
- `BASH_SUBSHELL` increments by one — the canonical way to detect
  "are we in a subshell?".

A subshell *does not* propagate to the parent:

- Variable assignments, `unset` calls, `cd` calls, `umask` changes,
  `set` / `shopt` toggles, function definitions or redefinitions.

This last list is the entire point of the construct: a subshell is a
*write-isolation barrier*. Whatever you do inside `( )` is invisible
to the parent.

### `cd` in a subshell — the canonical scoped-mutation idiom

```bash
# scenario: cd into a directory, do work, return — without saving and restoring PWD
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# wrong — leaks the cd into the rest of the script
cd "$build_dir"
make
# … parent shell is now in $build_dir

# right — subshell scopes the cd
( cd "$build_dir" && make )
# parent's PWD is unchanged
```

The subshell pattern replaces the older `pushd`/`popd` dance with no
state to leak on a mid-function `die`. It is the standard scoping
mechanism for any operation that requires temporary mutation: a
working-directory change, an `IFS` override, an `umask` shift, a
trap installation that should not outlast the operation. The price is
one fork.

### `BASH_SUBSHELL` and detecting depth

```bash
# scenario: log shell depth for debugging
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trace() { printf '[depth=%d pid=%d] %s\n' "$BASH_SUBSHELL" "$BASHPID" "$*" >&2; }

trace 'top of script'                   # ⇒ depth=0
( trace 'first subshell'                # ⇒ depth=1
  ( trace 'nested subshell' )           # ⇒ depth=2
)
trace 'after subshells'                 # ⇒ depth=0 (back in parent)
```

`BASH_SUBSHELL` counts only explicit and command-substitution
subshells; pipelines also fork but the parser-level depth-tracking is
not always intuitive (the *last* stage of a pipeline runs in a
subshell-or-not depending on `lastpipe`, §7.6). For "what is my real
PID?" use `$BASHPID` — `$$` is the *parent* shell's PID and does
not change in a subshell, while `$BASHPID` is always the current
process's PID.

### Distinguished from `( ))` in arithmetic and conditional contexts

The parser disambiguates `( … )` from `(( … ))` (arithmetic) and
`[[ … ]]` (conditional) by lookahead: a single `(` followed by a
command-list opens a subshell; a doubled `((` opens an arithmetic
context. The two are completely separate constructs with separate
syntax and exit-status conventions; do not confuse one for the other.

**See also**: §7.9 (brace grouping `{ }` — the same idea without
forking), §7.10 (AND-OR short-circuits), §11.3 (subshell origins),
§13.3 (errexit and `inherit_errexit`), BCS0101, BCS0603.

#fin
