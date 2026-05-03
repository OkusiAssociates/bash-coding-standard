<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXIV — Bash Internals

*How bash actually works. This Part is for advanced readers who want to understand semantics by understanding the implementation.*

---

## Chapters

1. [24.1 The execution pipeline](01_The-execution-pipeline.md) — The high-level path from input string to syscalls.
2. [24.2 The bison grammar](02_The-bison-grammar.md) — Bash 5.2 rewrote the command-substitution parser using a recursive bison grammar.
3. [24.3 Variable storage](03_Variable-storage.md) — Bash maintains variables in a hash table, scoped by call stack.
4. [24.4 Function storage](04_Function-storage.md) — Functions are stored similarly to variables, in their own table.
5. [24.5 The job table](05_The-job-table.md) — Per-shell table of jobs.
6. [24.6 The trap table](06_The-trap-table.md) — Per-shell table mapping signals to handler strings.
7. [24.7 The execution environment](07_The-execution-environment.md) — The bundle of state that defines a command's runtime context.
8. [24.8 Subshell forking](08_Subshell-forking.md) — What `fork()` copies, what it doesn't.
9. [24.9 Builtin loadables](09_Builtin-loadables.md) — Bash supports loading additional builtins from shared objects at runtime.
10. [24.10 Reading the bash source](10_Reading-the-bash-source.md) — For deep understanding, the canonical resource is the bash source itself.

---

← Previous: [Part XXIII — POSIX Conformance and Portability](../23_POSIX-Conformance-and-Portability/index.md)

Next: [Part XXV — Bash 5.3 and the Future](../25_Bash-5.3-and-the-Future/index.md) →

#fin
