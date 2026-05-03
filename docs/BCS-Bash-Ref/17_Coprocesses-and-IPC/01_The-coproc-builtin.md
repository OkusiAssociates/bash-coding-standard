<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.1 The `coproc` builtin

`coproc` starts a process with a bidirectional pipe pair connected to
the parent shell. Bash 4.0+; Bash 5.x lifted the "one coproc per shell"
restriction.

### Syntax

- `coproc NAME { commands; }` — named coproc, multi-command body.
- `coproc NAME command [args]` — named coproc, single-command body.
- `coproc { commands; }` — unnamed; default array name `COPROC`,
  default PID variable `COPROC_PID`.
- `coproc command` — the single-command, single-word case is special:
  the array is named after the command word *only* when the command
  word is a simple unquoted identifier; otherwise it is `COPROC`.

### What gets defined

For `coproc NAME ...`, bash creates:

| Name | Holds |
|------|-------|
| `${NAME[0]}` | the *read* fd — read from coproc's stdout |
| `${NAME[1]}` | the *write* fd — write to coproc's stdin |
| `${NAME_PID}` | the coproc's PID (note: literal `NAME_PID`, not `${NAME}_PID`) |

The PID variable is named by concatenating the chosen name with the
literal suffix `_PID`. For `coproc CALC ...` the variable is `CALC_PID`;
for the unnamed form the variable is `COPROC_PID`. The variable is
unset when the coproc terminates.

### Minimal invocation

```bash
# scenario: launch bc as a long-lived calculator
coproc CALC { bc -l; }

# write a query, read the answer
printf '3.14 * 2\n' >&"${CALC[1]}"
read -r answer <&"${CALC[0]}"
printf 'answer: %s\n' "$answer"
# ⇒ answer: 6.28

# clean shutdown
exec {CALC[1]}>&-          # close the write fd; bc sees EOF
wait "$CALC_PID"
```

The fd dereferences `>&"${CALC[1]}"` and `<&"${CALC[0]}"` are syntax-
heavy but mechanical: substitute the array element, prefix with `>&`
(write) or `<&` (read). Closing the write fd causes the child to see
EOF and exit; `wait` reaps it.

### Restrictions

- Bash 4.x: only one coproc may be live at a time. A second `coproc`
  call before the first exits is a fatal error.
- Bash 5.x: multiple coprocs allowed (§17.3).
- Coprocs cannot be nested inside `(...)` subshells; the fds would
  not propagate to the parent's environment.

### Why use `coproc` over `command | other`

A pipeline `producer | consumer` runs both halves in parallel but
neither can talk *back* to the other. `coproc` is the answer when the
parent script needs to drive a long-lived child interactively —
sending one query and reading one answer at a time, repeatedly,
without forking the child anew per query.

### See also

- §17.2 — bidirectional fd pairs (the canonical persistent-worker
  pattern)
- §17.3 — multiple coprocesses (Bash 5.x)
- BCS1101 (background job management)

#fin
