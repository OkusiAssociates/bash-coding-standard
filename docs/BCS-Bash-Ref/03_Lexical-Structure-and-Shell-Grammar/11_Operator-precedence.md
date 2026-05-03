<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.11 Operator precedence

Bash's *list* operators have a small, tight precedence hierarchy —
distinct from the **arithmetic** operator precedence inside `(( ))`
(§8.10). Misreading the list-level precedence is the root cause of
the most enduring antipattern in shell programming: the use of
`a && b || c` as if it were `if a; then b; else c; fi`. It is not.

### The precedence table (highest to lowest)

| Level | Operators | Associativity | Notes |
|-------|-----------|---------------|-------|
| 1 (tightest) | `\|`, `\|&` (pipeline) | left | Pipelines bind tighter than logical operators. |
| 2 | `time`, `!` | unary, prefix | Apply to the following pipeline only. |
| 3 | `&&`, `\|\|` | **left** | Equal precedence — this is the footgun. |
| 4 | `;`, `&`, newline | left | Sequencing/backgrounding; lowest. |

`( … )` (subshell) and `{ … ; }` (brace group) are not operators —
they are compound commands that re-establish a fresh precedence
context inside, and may be used to override the table above by
explicit grouping.

### Why `&&`/`||` are not if/then/else

```bash
# scenario: a "ternary" attempt that misfires when b returns non-zero.
a && b || c
```

Because `&&` and `||` are equal-precedence and left-associative, the
shell parses this as `(a && b) || c`. So:

- If `a` succeeds **and** `b` succeeds → only `a && b`; `c` skipped.
- If `a` succeeds **and** `b` *fails* → `c` runs (this is the bug).
- If `a` fails → `b` skipped; `c` runs.

The author probably meant "if `a` then `b` else `c`" — but that
contract collapses the moment `b` can fail. Real-world example:
`grep -q pat file && cp file backup || rm -f file`. If `cp` fails
(disk full, permission denied), the file is removed — the opposite
of what was intended.

### Worked example: the gotcha in action

```bash
#!/usr/bin/env bash
# scenario: prove that "$b" running and failing still triggers "$c".
set -uo pipefail   # NB: NOT -e here, so we can observe the path

a() { return 0; }
b() { echo 'b ran'; return 1; }
c() { echo 'c ran'; }

a && b || c
# ⇒ b ran
# ⇒ c ran
```

Both `b` and `c` execute. Under `set -e` the script would also exit
if `b`'s failure were not in a "tested" position — but `&&` *is* a
tested position, so the failure is silently swallowed and `c` fires
regardless. This combination — `set -e` plus `a && b || c` — is the
quietest way to ship a broken script.

### Worked example: explicit grouping fixes it

```bash
# right — actual if/then/else semantics, no ambiguity.
if a; then
  b
else
  c
fi

# right — guarded short-circuit, when c truly is a fallback for a:
a || c
b      # only runs after the guard, regardless of c

# right — when you really do want "try b only if a; never c on b's failure":
if a; then b; fi
```

Reach for `&&`/`||` only when the right-hand side is a *side-effect*
that cannot itself fail (`echo`, `: # noop`, an idempotent log call)
or when you have explicitly grouped: `a && { b; true; } || c`. The
trailing `true` neutralises `b`'s exit status so `||` no longer
fires on a `b` failure.

### `time` and `!` bind to the pipeline only

```bash
time grep pat file | wc -l   # times the WHOLE pipeline (special case)
! grep -q pat file           # inverts grep's exit; pipeline of one
! cmd1 | cmd2                # inverts cmd2's exit (or pipeline's under pipefail)
time cmd1 && cmd2            # times cmd1 only; && joins at lower precedence
```

To time an entire `&&`/`||` chain, group with a brace block:
`time { cmd1 && cmd2; }`.

### Strict-mode note

`set -e` skips failures in "tested" positions: the LHS of `&&`/`||`,
the head of `if`/`while`/`until`, and any pipeline negated with `!`.
This is why `a && b || c` undermines `set -e` — every command in
the chain is in a tested position. Use explicit `if` for control
flow under strict mode; use `&&`/`||` only for safe one-line guards.

**See also**: §3.10 (grammar), §7.1 (`if`), §8.10 (arithmetic
precedence), §13.2 (errexit semantics), BCS0501, BCS0601.

#fin
