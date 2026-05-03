<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 17.9 Choosing the right primitive

Decision tree.

- **One-off pipe between two commands you control:** `|` (anonymous pipe).
- **Bidirectional with a persistent helper:** `coproc`.
- **Cross-script communication:** FIFO.
- **Network:** `/dev/tcp` for trivial cases; `socat` or `curl` otherwise.
- **Shared memory between unrelated processes:** `/dev/shm` with file-based protocol.
- **Robust message passing:** external broker (Redis, Kafka, RabbitMQ).
- Match primitive to durability, throughput, and concurrency needs.

#fin
