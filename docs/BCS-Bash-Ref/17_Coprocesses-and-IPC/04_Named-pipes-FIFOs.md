<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.4 Named pipes (FIFOs)

`mkfifo` creates a persistent file-system entity that two unrelated
processes use for one-way communication. Unlike anonymous pipes
(§17.5), a FIFO outlives any individual process and can be opened by
any process with filesystem permission.

### Form register

- `mkfifo PATH` — create the FIFO file with default mode (umask
  applies).
- `mkfifo -m 0600 PATH` — create with explicit mode.
- `cmd1 > FIFO &` — writer; *blocks* until a reader opens the FIFO.
- `cmd2 < FIFO` — reader; blocks until a writer opens the FIFO.
- Bidirectional comms: open two FIFOs, one per direction.
- Cleanup: `rm FIFO` after use — the file persists otherwise.

### `mktemp -p` idiom with trap cleanup

A FIFO created without a cleanup trap leaks across script crashes.
The canonical safe pattern:

```bash
# scenario: ephemeral FIFO with guaranteed cleanup
declare -- fifo
fifo=$(mktemp -u --tmpdir=/tmp "${SCRIPT_NAME}.fifo.XXXXXX")
mkfifo -m 0600 -- "$fifo"
trap 'rm -f -- "$fifo"' EXIT

# producer in the background
(
  for i in {1..5}; do
    printf 'item-%d\n' "$i"
  done
) > "$fifo" &
producer_pid=$!

# consumer in the foreground
while IFS= read -r line; do
  printf 'received: %s\n' "$line"
done < "$fifo"

wait "$producer_pid"
```

- `mktemp -u` *generates* a unique path without creating the file —
  `mkfifo` then creates it as a FIFO. (`-p` and `--tmpdir` are
  synonyms; `--tmpdir=/tmp` is the more explicit form.)
- `-m 0600` restricts the FIFO to the owner; without this the umask
  may grant group/world access (BCS1006).
- The trap fires on any exit (clean, error, signal trapped), removing
  the file even if the script aborts mid-write.

### Round-trip cross-script comms

Two FIFOs let unrelated processes hold a request/reply conversation:

```bash
# scenario: server side
mkfifo /tmp/req /tmp/rep
trap 'rm -f /tmp/req /tmp/rep' EXIT
while IFS= read -r request < /tmp/req; do
  printf 'echo: %s\n' "$request" > /tmp/rep
done

# scenario: client side (separate shell, same host)
printf 'hello\n' > /tmp/req
read -r reply < /tmp/rep
printf '%s\n' "$reply"     # ⇒ echo: hello
```

Each open/close cycle is a synchronisation point — the server's
`read` does not return until the client `printf` opens the FIFO for
writing, and vice versa.

### Pitfalls

- A FIFO with no reader blocks the writer forever (or until the
  reader appears). Use `O_NONBLOCK` from a real program if non-block
  semantics matter; bash has no portable equivalent.
- Multiple readers on one FIFO: each line is delivered to *exactly
  one* reader; ordering across readers is undefined (§16.12).
- Filesystem-bound: a FIFO on `/tmp` is host-local. For cross-host
  IPC, use sockets (§17.6) or a real broker.

### See also

- §17.5 — anonymous pipes (no filesystem entity)
- §17.6 — `/dev/tcp` for cross-host streams
- §16.12 — FIFO-as-queue producer/consumer pattern
- BCS1006 (temporary file handling)

#fin
