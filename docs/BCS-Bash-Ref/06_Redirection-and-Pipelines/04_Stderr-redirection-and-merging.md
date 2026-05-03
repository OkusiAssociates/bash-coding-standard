<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.4 Stderr redirection and merging

Bash provides explicit forms for redirecting stderr (`2>`, `2>>`, `2>&1`,
`1>&2`) plus two combined shorthands (`&>`, `&>>`). All resolve, after
parsing, to the same `dup2()` / `open()` syscall sequence the kernel
sees. The trap is that the order of operators is significant — `>file
2>&1` and `2>&1 >file` differ in result, not just style. This chapter
documents each form and traces the order-of-evaluation gotcha that bites
new authors.

### The operator inventory

- `2> file` — redirect stderr to *file* (truncate or create, fd 2).
- `2>> file` — append stderr to *file* on fd 2.
- `2>&1` — make fd 2 a duplicate of fd 1's *current* target.
- `1>&2` — make fd 1 a duplicate of fd 2's *current* target.
- `>file 2>&1` — both stdout and stderr to *file*. Idiomatic order.
- `2>&1 >file` — stderr to whatever fd 1 *was* (terminal), stdout to
  *file*. A common mistake.
- `&> file` — combined shorthand; equivalent to `>file 2>&1`.
- `&>> file` — combined-append shorthand.
- `2> >(cmd)` — pipe stderr through a process substitution (§6.10).

### Order-of-evaluation gotcha

Redirections are applied left-to-right against the current fd table
(§6.11). `2>&1` does not "merge" — it copies whatever fd 1 *currently*
points at into fd 2. Trace each form one operator at a time:

```bash
# scenario: contrast `>file 2>&1` (correct) with `2>&1 >file` (wrong)
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Correct order — file gets both streams
{ echo to-stdout; echo to-stderr >&2; } >out.log 2>&1
#   ^^^^^^^^^^^   step 1: open out.log on fd 1
#                  step 2: dup fd 1 (now out.log) onto fd 2
#                  ⇒ both streams land in out.log

# Wrong order — same operators, different sequence, terminal sees stderr
{ echo to-stdout; echo to-stderr >&2; } 2>&1 >out2.log
#   ^^^^^^^^^^^   step 1: dup fd 1 (still terminal) onto fd 2
#                  step 2: open out2.log on fd 1
#                  ⇒ stdout to file, stderr stays on terminal
```

The mnemonic: *first say where stdout goes, then say "stderr follows
stdout"*. Reverse it and the duplication has captured stale state.

### `&>` and `&>>` — atomic combined forms

Bash provides `&>file` and `&>>file` as parser-level shorthands that
*compile* to the correct ordering — there is no left-to-right pitfall
because the operator names a single combined operation:

```bash
# scenario: the three equivalent forms for "send everything to log"
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

cmd >log 2>&1                     # explicit, ordered
cmd &> log                        # bash-only shorthand (recommended)
cmd 1>log 2>log                   # WRONG — two separate opens, two offsets,
                                  # output may interleave or one stream
                                  # may overwrite the other's bytes
# ⇒ first two equivalent; third races on shared file
```

The third form (`1>log 2>log`) is a common over-clever attempt: each
operator opens the file independently, so each fd has its own write
offset and the streams race. Use `&>` or `>file 2>&1`.

`&>>` likewise appends both streams atomically — the file is opened
once with `O_APPEND`, and both fds share that one open file
description, so writes from either fd advance the kernel-side offset
correctly (BCS0711).

### Common idioms

- Discard both streams: `cmd &>/dev/null`.
- Capture both into a variable: `output=$(cmd 2>&1)`.
- Capture stdout into a variable, leave stderr on terminal:
  `output=$(cmd)` — the default; stderr is *not* captured by `$()`.
- Send stderr only to a file, leave stdout on terminal:
  `cmd 2>err.log` — stderr alone has its own operator.
- Swap streams (pipe stderr but not stdout): `cmd 3>&1 1>&2 2>&3 3>&-`
  — the classic stream-swap dance, see §6.6.
- Pipe stderr into a downstream filter while keeping stdout on
  terminal: see the swap dance above; alternatively
  `cmd 2> >(filter >&2)` if a process-substitution sink suffices
  (§6.10).

### Why `&>` is preferred for "everything to one place"

`>file 2>&1` is portable, explicit, and correct, but its three-token
shape invites the reversed-order error. `&>file` is a single bash
parser-recognised operator: there is no left-to-right reordering
hazard, no chance of accidentally inserting another redirection
between the two pieces, and the reader's eye sees one operation.
Likewise `&>>file` for the append case. BCS0711 codifies this
preference for combined redirection.

**See also**: §6.3 (output redirection), §6.6 (duplicating fds), §6.11
(order of evaluation), §6.14 (`|&` pipeline form), §7.2 (BCS0702 stdout
vs stderr separation), BCS0601, BCS0703, BCS0711.

#fin
