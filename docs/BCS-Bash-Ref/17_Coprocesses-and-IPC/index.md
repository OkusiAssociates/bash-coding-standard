<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVII — Coprocesses and IPC

*Inter-process communication primitives available to bash scripts: coprocesses, FIFOs, anonymous pipes, network sockets via `/dev/tcp`, and shared memory via `/dev/shm`.*

---

## Chapters

1. [17.1 The `coproc` builtin](01_The-coproc-builtin.md) — Starts a process with a bidirectional pipe to it.
2. [17.2 Bidirectional fd pairs](02_Bidirectional-fd-pairs.md) — The pattern of using a coproc as a persistent worker.
3. [17.3 Multiple coprocesses](03_Multiple-coprocesses.md) — Running several coprocs simultaneously.
4. [17.4 Named pipes (FIFOs)](04_Named-pipes-FIFOs.md) — `mkfifo` creates a named pipe — a persistent file-system entity that two processes use for one-way communication.
5. [17.5 Anonymous pipes](05_Anonymous-pipes.md) — `a | b` creates an anonymous pipe — kernel-allocated, no filesystem entity.
6. [17.6 `/dev/tcp` and `/dev/udp`](06_devtcp-and-devudp.md) — Bash-synthesised network endpoints.
7. [17.7 `/dev/shm` shared memory](07_devshm-shared-memory.md) — `tmpfs` mounted at `/dev/shm` — RAM-backed file system.
8. [17.8 External IPC tools](08_External-IPC-tools.md) — When bash's primitives aren't enough.
9. [17.9 Choosing the right primitive](09_Choosing-the-right-primitive.md) — Decision tree.

---

← Previous: [Part XVI — Concurrency and Parallelism](../16_Concurrency-and-Parallelism/index.md)

Next: [Part XVIII — Readline, History, and Completion](../18_Readline-History-and-Completion/index.md) →

#fin
