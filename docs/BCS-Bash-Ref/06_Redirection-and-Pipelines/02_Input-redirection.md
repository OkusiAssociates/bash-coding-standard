<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.2 Input redirection

Operators that connect an fd to an input source. Default fd is 0
(stdin). All forms are evaluated in the order they appear (§6.11)
and apply for the duration of the command, compound block, or
function call to which they are attached.

### Operator cheatsheet

| Operator | Meaning |
|----------|---------|
| `< file` | open *file* read-only on fd 0 |
| `n< file` | open *file* read-only on fd *n* |
| `<&n` | duplicate fd *n* onto fd 0 |
| `n<&m` | duplicate fd *m* onto fd *n* |
| `<&-` | close fd 0 |
| `n<&-` | close fd *n* |
| `<<` | here-document (§6.8) |
| `<<<` | here-string (§6.9) |
| `<>` | open file for **read + write** on fd 0 (or `n<>file` on fd *n*; §6.5) |

The `n` immediately precedes the operator with no space (`3<file`,
not `3 <file`). Default `n` is 0 for `<` operators, 1 for `>`
operators.

### Composite example — read from fd 3

```bash
# scenario: read from a side-channel fd 3 while keeping stdin (fd 0) free
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Open /etc/hostname on fd 3 for reading; leave stdin attached to terminal
exec 3</etc/hostname

# Read one line from fd 3 specifically, not from default fd 0
read -r -u 3 hostline
printf 'hostname=%s\n' "$hostline"

# Re-read by duplicating fd 3 onto fd 0 for a single command
read -r line2 <&3
printf 'next=%s\n' "${line2:-<eof>}"

# Close fd 3 explicitly (or rely on EXIT trap — BCS0110)
exec 3<&-
```

`exec 3<file` is the canonical "open this side input once" idiom; the
BCS rule is to pair every `exec n<…` with an explicit close, ideally
via an `EXIT` trap (BCS0110).

### `read -u` versus `<` and `<&`

- `read -u 3 var` — read from fd 3 (does not touch fd 0).
- `read var <&3` — duplicate fd 3 onto fd 0 *for this `read`*, then
  read from fd 0. Functionally equivalent for a single read, but
  `-u` is clearer and avoids the temporary dup.
- `read var < file` — fresh open of *file* for this `read` only;
  always starts from byte 0. Not useful for multi-line iteration.

### Loop pattern — `while … do … done < file`

The standard "read every line of a file" loop attaches the redirection
to the `done` keyword, not to `read`:

```bash
# scenario: line-by-line file reading without subshell loss (§6.16, BCS0905)
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0
while IFS= read -r line; do
  count+=1
  printf '%4d: %s\n' "$count" "$line"
done < /etc/hostname
printf 'lines read: %d\n' "$count"
```

Quoting `IFS=` and using `-r` are the two BCS-mandated parts of the
idiom (BCS1003, BCS0905). Attaching redirection to `done` keeps the
loop body in the *current shell*, so `count` survives the loop —
contrast with `cat file | while read …`, which puts the loop in a
pipeline subshell where any modification is lost.

### BCS posture

- Use `read -u N` rather than `read … <&N` for clarity.
- Pair every `exec n<file` with `trap 'exec n<&-' EXIT` (BCS0110).
- Quote filenames in redirections: `< "$file"` (BCS0301).
- For looped line reading, prefer `while … done < file` over piping
  through `cat` (BCS0905, §6.16).

**See also**: §6.3 (output redirection), §6.5 (read+write `<>`),
§6.6 (duplicating fds), §6.7 (moving and closing), §6.8
(here-documents), §6.9 (here-strings).

#fin
