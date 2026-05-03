<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.5 Anonymous pipes

`a | b` creates an anonymous pipe — kernel-allocated, no filesystem
entity, automatically cleaned up when both ends close. The classical
shell IPC primitive and the foundation of every shell pipeline.

### Properties

- Parent and child only; cannot be opened by unrelated processes.
- Auto-cleanup on close (no `rm` needed, unlike a FIFO).
- Half-closed: writer continues until close; reader sees EOF.
- `SIGPIPE` on write to a closed reader (default action: terminate).
- Each pipeline stage runs in its own subshell — variable
  assignments do not propagate to the parent (the canonical "while
  read" trap; see §6.13).

### `pipefail` interaction

Without `pipefail`, a pipeline's exit status is the status of its
*last* command — a failing producer is silently masked by a
successful consumer:

```bash
# without pipefail (or under set +o pipefail)
false | cat            # exit status: 0  ← cat's status
echo $?                # 0

# with pipefail (assumed under strict mode)
set -o pipefail
false | cat            # exit status: 1  ← false's status, propagated
echo $?                # 1
```

Strict mode (BCS0101) sets `pipefail` precisely because silent
failures in the middle of a pipeline are a major class of shell
bugs. Pipelines under strict mode return the rightmost non-zero exit
status, or 0 if every stage succeeded.

### `SIGPIPE` semantics

A producer that writes to a pipe whose reader has closed receives
`SIGPIPE`:

```bash
# scenario: head closes the pipe early; the producer sees SIGPIPE
yes | head -n 5
# yes is killed by SIGPIPE — exits with status 141 (128 + 13)
```

Under `pipefail`, the script sees a non-zero exit because `yes`'s
status (141) is non-zero. For `yes | head` this is harmless; for a
custom producer it may need defensive handling:

```bash
# scenario: producer that ignores SIGPIPE so a closing reader doesn't kill it
( trap '' PIPE; produce_lots ) | head -n 100
```

`trap '' PIPE` ignores `SIGPIPE` for the producer subshell; the
producer's `write(2)` returns `EPIPE` instead, the script can check
`$?` and exit cleanly.

### Subshell semantics

Every pipeline stage runs in its own subshell, with the well-known
consequence that variable assignments in the rightmost stage are
*not* visible to the parent:

```bash
count=0
seq 1 10 | while IFS= read -r line; do count=$((count + 1)); done
printf '%d\n' "$count"     # ⇒ 0  (the while ran in a subshell)

# fix: process substitution (BCS0903), no subshell for the consumer
count=0
while IFS= read -r line; do count=$((count + 1)); done < <(seq 1 10)
printf '%d\n' "$count"     # ⇒ 10
```

See §6.13 for the full pipeline-subshell discussion and the
`lastpipe` shopt that changes this behaviour for the rightmost stage.

### See also

- §6.13 — pipeline subshell semantics in detail
- §17.4 — named pipes (FIFOs) for unrelated processes
- §13 — exit status and `pipefail`
- BCS0101 (strict mode), BCS0903 (process substitution), BCS0905
  (input redirection)

#fin
