<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.12 Queue patterns

Producer-consumer in shell. Three primitives are practical: an
append-only file with locking, a named pipe (FIFO), and a shell
process-substitution. Anything more sophisticated — persistent
queues, crash recovery, retries — belongs in a real broker (Redis,
RabbitMQ, NATS).

### File-as-queue with `flock`

The simplest persistent queue: producer appends, consumer locks-and-
reads-and-truncates atomically:

```bash
# scenario: producer appends a job; multiple producers safe via O_APPEND
queue_push() {
  local -- payload=$1
  printf '%s\n' "$payload" >> /var/spool/myapp/queue
}

# scenario: consumer drains one batch under exclusive lock
queue_drain() {
  local -- queue=/var/spool/myapp/queue
  local -- tmp
  tmp=$(mktemp)
  (
    flock -x 200
    [[ -s $queue ]] || return 1
    cp -- "$queue" "$tmp"
    : > "$queue"
  ) 200>"$queue.lock"
  while IFS= read -r job; do
    process_job "$job"
  done < "$tmp"
  rm -- "$tmp"
}
```

Producers rely on `O_APPEND` atomicity for short writes (§14.12) and
need no lock. Consumers must lock — between "read the file" and
"truncate the file" any other consumer would see duplicate work or a
producer would lose appends.

### FIFO producer-consumer

For in-process or sibling-process coordination, a named pipe streams
jobs without persistence:

```bash
# scenario: one producer, three consumers, no on-disk queue
declare -- fifo
fifo=$(mktemp -u)
mkfifo -- "$fifo"
trap 'rm -f -- "$fifo"' EXIT

# producer in the background
(
  for i in {1..100}; do
    printf 'task-%03d\n' "$i"
  done
) > "$fifo" &
prod_pid=$!

# three consumers, each reading the same FIFO
for c in 1 2 3; do
  (
    while IFS= read -r task; do
      printf 'consumer %d processing %s\n' "$c" "$task" >&2
    done < "$fifo"
  ) &
done

wait "$prod_pid"
# producer closed FIFO; consumers see EOF and exit
wait
```

- Multiple consumers from one FIFO is supported but ordering is
  non-deterministic — exactly one consumer receives each line, but
  which one depends on scheduling.
- Producer EOF (closing the writing fd) propagates to all consumers
  as `read` returning non-zero — the loop ends naturally.
- The trap ensures the FIFO is removed even on early exit (§17.4).

### Process-substitution queue

For one-shot fan-in (consumer reads once, producer streams once),
process substitution avoids the FIFO file entirely:

```bash
# scenario: consume the lines of one producer with no on-disk artefact
while IFS= read -r line; do
  process "$line"
done < <(producer_command)
```

The `< <(...)` form sets up an anonymous pipe; the producer runs in
parallel, the consumer reads at its own pace. No queue length, no
persistence — but no FIFO management either.

### When bash is the wrong answer

- Persistent queue with crash recovery — bash has no transaction
  primitive.
- Multi-host distribution — use a real broker.
- Fairness/priority scheduling — bash's "whoever reads first wins" is
  fine for small N; degrades under contention.
- Replay or dead-letter queues — outside bash's scope.

### See also

- §14.12 — `PIPE_BUF` and atomic-append details
- §16.10 — locking primitives
- §17.4 — named pipes (FIFOs) reference
- BCS1006 (temporary file handling), BCS1101 (background job management)

#fin
