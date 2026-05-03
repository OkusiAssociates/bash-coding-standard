<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.5 Reading and writing (`<>`)

The `<>` operator opens a file for both reading and writing on a single
fd, with `O_RDWR | O_CREAT` semantics — the file is created if absent,
not truncated if present, and a single shared offset advances on both
reads and writes. It is the rarest of bash's redirection operators and
the only one that admits read-modify-write patterns on regular files
without an intermediary process.

### Forms

- `<> file` — open *file* on fd 0 (stdin) for read+write.
- `n<> file` — open on fd *n* (the form normally used).
- `{var}<> file` — Bash 5.0+ allocates a free fd into *var*.
- File created if missing; existing content preserved (no truncation).
- Single offset, shared between read and write — `read` advances it,
  `printf` advances it.

### Comparison with separate-fd alternatives

The temptation is to use `<file` and `>file` separately and trust the
filesystem to keep them coherent. It does not: opening the same path
twice produces two open file descriptions, each with its own offset,
and writes through one are not visible through the other until the
file is closed and re-opened. `<>` is the only operator that gives a
single offset shared between read and write.

### Read-modify-write demonstration

The use case is a long-lived fd that supports both `read` and `printf`
without re-opening. A typical pattern is incremental log scanning or
fixed-record state files:

```bash
# scenario: open state file once, read counter, write incremented value
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- statefile='counter.dat'
[[ -f $statefile ]] || printf '0\n' >"$statefile"   # seed if absent

exec 7<>"$statefile"            # fd 7 open for read+write
read -r -u 7 current            # read current value (offset advances)
declare -i n=$((current + 1))
exec 7>&-                       # close to release lock semantics

# Re-open with truncation to write the new value
printf '%d\n' "$n" >"$statefile"
echo "incremented to $n"        # ⇒ incremented to 1 (then 2, then 3 …)
```

Note: `<>` does *not* truncate, so naively writing a shorter value back
into the same offset leaves stale bytes after the new content. For
scalar state, re-open with `>` for the write phase, as above. For
fixed-width record updates (e.g. binary tables), `<>` plus precise
seek-via-`read -N` is the right tool.

### Caveats

- No `lseek` builtin — bash cannot rewind an `<>`-opened fd. To re-read
  from the start, close and re-open.
- Pipes and FIFOs accept `<>` but the semantics are different: opening
  a FIFO with `<>` succeeds without blocking on either end, useful as a
  producer + consumer self-test pattern (the `<>` open does not require
  a counterparty to already be present).
- Bash 5.0+ accepts `{var}<>file` to allocate a fresh fd into the
  variable rather than naming one explicitly; combine with
  `shopt -s varredir_close` (§6.12) for automatic cleanup at variable
  scope exit.
- Most bash scripts have no need for `<>`; use `<` for input and `>`
  for output unless you need a single fd to do both. Reach for it when
  the alternative would be re-opening the same path many times in a
  loop.

For scalar incremental updates, the standard pattern remains
"open `<>`, read, close, re-open `>`, write" — `<>` provides
read-side persistence without committing to the awkward in-place
overwrite semantics the operator strictly offers.

**See also**: §6.2 (input redirection), §6.3 (output redirection), §6.6
(dup), §6.12 (`exec` for persistent fds), §17.x (FIFOs as IPC).

#fin
