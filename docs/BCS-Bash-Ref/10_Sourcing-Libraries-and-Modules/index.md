<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part X — Sourcing, Libraries, and Modules

*Bash's `source` (alias `.`) is the primary mechanism for code reuse across scripts. This Part documents sourcing semantics and the conventions that make Bash libraries composable, distributable, and safe.*

---

## Chapters

1. [10.1 `source` semantics](01_source-semantics.md) — `source file` executes `file` in the current shell's context.
2. [10.2 The `BASH_SOURCE` array](02_The-BASH_SOURCE-array.md) — Tracks the call chain of sourced files and function calls.
3. [10.3 Self-locating library pattern](03_Self-locating-library-pattern.md) — The canonical pattern by which a library determines its own installation directory at runtime.
4. [10.4 Idempotent sourcing guards](04_Idempotent-sourcing-guards.md) — Prevents double-loading when multiple files source the same library.
5. [10.5 Namespace prefixes](05_Namespace-prefixes.md) — Bash function names can include `::` and other characters, enabling namespacing.
6. [10.6 Public vs private conventions](06_Public-vs-private-conventions.md) — Distinguishing exported API from internal helpers.
7. [10.7 Version negotiation](07_Version-negotiation.md) — Libraries should declare a version; callers should check it.
8. [10.8 Lazy and conditional loading](08_Lazy-and-conditional-loading.md) — Loading libraries only when needed reduces startup cost.
9. [10.9 Cross-shell sourcing pitfalls](09_Cross-shell-sourcing-pitfalls.md) — When a library might be sourced by both bash and sh.
10. [10.10 API design](10_API-design.md) — Designing a library API that other people will use.
11. [10.11 Distribution and installation](11_Distribution-and-installation.md) — How Bash libraries are packaged and deployed.

---

← Previous: [Part IX — Functions](../09_Functions/index.md)

Next: [Part XI — Process Management](../11_Process-Management/index.md) →

#fin
