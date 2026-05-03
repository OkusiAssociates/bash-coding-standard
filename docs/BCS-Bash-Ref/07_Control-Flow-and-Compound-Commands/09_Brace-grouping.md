<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.9 Brace grouping `{ … ; }`

Run a list in the *current* shell — same process, same scope.
Equivalent to a subshell `( … )` (§7.8) in its grouping role, but
without the fork: variable assignments, `cd` calls, and other
mutations all persist after the group exits. Reach for `{ … ; }` when
you need the grouping but not the isolation.

### Syntax — the landmines

```
{ list ; }
{ list
}
```

The parser treats `{` and `}` as *reserved words*, not punctuation.
Two consequences trap newcomers:

1. **The opening `{` must be followed by whitespace.** `{cmd}` is one
   word — bash tries to run a program literally called `{cmd}` and
   fails. Write `{ cmd; }`.
2. **The closing `}` must be preceded by a list terminator.** Either
   a semicolon or a newline. `{ cmd }` is a syntax error; `{ cmd; }`
   and `{ cmd<newline>}` are correct.

```bash
# wrong — both rules violated
{cmd1; cmd2}                         # ⇒ command not found: {cmd1
{ cmd1; cmd2 }                       # ⇒ syntax error near unexpected token `}'

# right — single-line form with semicolons
{ cmd1; cmd2; }

# right — multi-line form (newline serves as terminator before })
{
  cmd1
  cmd2
}
```

The single-line form is the more common source of typos; if a
hand-typed brace group misbehaves, audit the trailing `; }` first.

### Group redirection — the everyday use

The most common reason to reach for `{ … ; }` is to apply a redirection
to several commands at once:

```bash
# scenario: log a multi-step build atomically to one file
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r logfile='/var/log/build.log'

{
  date '+%F %T build start'
  ./configure
  make -j"$(nproc)"
  make test
  date '+%F %T build end'
} >> "$logfile" 2>&1
```

The `>> "$logfile" 2>&1` after the closing brace applies to every
command inside the group. The same pattern with `( … )` would also
work, but it would fork — pointless overhead when no isolation is
needed. Group redirection is the canonical case for `{ }` over `( )`.

### `{ }` vs `( )` — the decision

Identical externally (both are compound commands; both have an exit
status equal to the last contained command's); different internally:

| Property | `{ list ; }` | `( list )` |
|----------|--------------|------------|
| Forks | No | Yes |
| Variable mutations persist | Yes | No |
| `cd` persists | Yes | No |
| Trap inheritance | Yes (no reset) | Yes (resets non-EXIT) |
| `BASH_SUBSHELL` increments | No | Yes |
| Parser tokens | Reserved words (need spaces + terminator) | Operators (no spacing rules) |

Pick `{ }` when you want the grouping for redirection or sequence
control without paying for a fork. Pick `( )` when isolation is the
*point* — when the work inside the group must not leak.

### Distinguished from brace expansion

`{ }` is brace grouping. `{a,b,c}` and `{1..5}` (§5.2) are *brace
expansion* — a separate, expansion-phase mechanism that produces word
lists. The two never collide because the parser distinguishes by
context: a `{` at the start of a command position with surrounding
whitespace opens a group; a `{` mid-word with comma-or-range contents
triggers expansion. The visual similarity is unfortunate but
unambiguous in practice.

**See also**: §7.8 (subshell grouping `( )` — the same idea with
forking), §5.2 (brace expansion — different mechanism), §6 (redirection
mechanics), BCS0503, BCS0903.

#fin
