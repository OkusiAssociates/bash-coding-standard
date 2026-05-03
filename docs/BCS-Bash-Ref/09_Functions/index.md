<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part IX — Functions

*Functions are bash's primary unit of code organisation. This Part documents definition syntax, argument passing, scope, return semantics, output discipline, and the inspection mechanisms.*

---

## Chapters

1. [9.1 Definition syntax](01_Definition-syntax.md) — Two equivalent forms, with subtle differences.
2. [9.2 Argument passing](02_Argument-passing.md) — Arguments arrive as positional parameters local to the function.
3. [9.3 `local` and scope](03_local-and-scope.md) — Variables declared `local` inside a function are dynamically scoped — visible to that function and its callees, invisible to its caller after return.
4. [9.4 Return value via `return N`](04_Return-value-via-return-N.md) — Functions return an 8-bit exit status.
5. [9.5 Communicating results](05_Communicating-results.md) — A function communicates results via four mechanisms; the choice has style and correctness implications.
6. [9.6 Recursion and `FUNCNEST`](06_Recursion-and-FUNCNEST.md) — Functions may call themselves, but bash's stack is limited.
7. [9.7 Function tracing](07_Function-tracing.md) — Hooks for observing function entry, exit, and DEBUG events.
8. [9.8 Listing and inspecting functions](08_Listing-and-inspecting-functions.md) — Bash provides multiple builtins for function introspection.
9. [9.9 Exporting functions](09_Exporting-functions.md) — Functions can be exported into the environment of child bash processes.
10. [9.10 Naming conventions](10_Naming-conventions.md) — Convention shapes maintainability.
11. [9.11 Self-locating with `BASH_SOURCE`](11_Self-locating-with-BASH_SOURCE.md) — A function can determine the file it was defined in via the `BASH_SOURCE` array.
12. [9.12 Calling-convention discipline](12_Calling-convention-discipline.md) — Stylistic and architectural rules for clean function design.

---

← Previous: [Part VIII — Conditional Expressions and Arithmetic](../08_Conditional-Expressions-and-Arithmetic/index.md)

Next: [Part X — Sourcing, Libraries, and Modules](../10_Sourcing-Libraries-and-Modules/index.md) →

#fin
