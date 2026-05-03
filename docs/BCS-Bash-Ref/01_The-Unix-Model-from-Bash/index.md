<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part I — The Unix Model from Bash

*Bash is a thin shell over Unix. Most "advanced Bash" mysteries dissolve once the underlying Unix model is clear. This Part documents the Unix abstractions Bash exposes, framed as Bash sees them. It is not a general Unix textbook — it is the minimum mental model required for the rest of this reference to make sense.*

---

## Chapters

1. [1.1 Processes — fork, exec, wait](01_Processes-fork-exec-wait.md) — The kernel-level process model on which every Bash construct ultimately rests.
2. [1.2 The file descriptor model](02_The-file-descriptor-model.md) — A file descriptor is a small non-negative integer that indexes the kernel's per-process open-file table.
3. [1.3 Files, directories, and special files](03_Files-directories-and-special-files.md) — The Linux VFS exposes seven file types through one uniform API.
4. [1.4 Streams and the standard descriptors](04_Streams-and-the-standard-descriptors.md) — The C runtime convention that every program inherits stdin (fd 0), stdout (fd 1), and stderr (fd 2).
5. [1.5 The shell environment](05_The-shell-environment.md) — Every process carries an environment — an array of `KEY=VALUE` strings inherited at fork and replaced at exec.
6. [1.6 Users, groups, permissions](06_Users-groups-permissions.md) — The discretionary access control model that Bash scripts must respect.
7. [1.7 Exit status and process termination](07_Exit-status-and-process-termination.md) — Every process exits with an 8-bit status code.
8. [1.8 Signals — overview](08_Signals-overview.md) — Signals are asynchronous notifications delivered to a process.
9. [1.9 The controlling terminal and TTY layer](09_The-controlling-terminal-and-TTY-layer.md) — Interactive Bash is intimately bound up with the controlling terminal.

---

Next: [Part II — Bash as a Program](../02_Bash-as-a-Program/index.md) →

#fin
