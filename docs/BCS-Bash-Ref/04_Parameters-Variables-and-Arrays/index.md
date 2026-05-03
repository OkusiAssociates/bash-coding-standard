<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part IV — Parameters, Variables, and Arrays

*Bash variables are not all strings. They have types, scopes, attributes, and namespaces. This Part documents the data model: the parameter taxonomy, the `declare` system, scope rules, and the array machinery.*

---

## Chapters

1. [4.1 Parameter taxonomy](01_Parameter-taxonomy.md) — Bash distinguishes three kinds of parameters: positional (set by argument passing), special (single-character names with fixed semantics), and shell variables (named by the user or by bash itself).
2. [4.2 Positional parameters](02_Positional-parameters.md) — Set by script invocation, function call, and `set --`.
3. [4.3 Special parameters](03_Special-parameters.md) — Single-character parameters with fixed semantics, set by bash itself.
4. [4.4 Shell variables](04_Shell-variables.md) — Bash maintains a long list of reserved variable names with specific semantics.
5. [4.5 The `declare` builtin and attributes](05_The-declare-builtin-and-attributes.md) — Bash variables have *attributes* set via `declare` (alias `typeset`).
6. [4.6 `local` and dynamic scope](06_local-and-dynamic-scope.md) — Variables declared `local` inside a function are visible to that function and to functions it calls (dynamic scope), but invisible to its caller after return.
7. [4.7 `readonly` and immutability](07_readonly-and-immutability.md) — Variables marked readonly cannot be reassigned, unset, or have their attributes changed.
8. [4.8 `export` and the environment](08_export-and-the-environment.md) — `export` marks a shell variable for inheritance by child processes.
9. [4.9 Indexed arrays](09_Indexed-arrays.md) — Sparse, integer-indexed arrays.
10. [4.10 Associative arrays](10_Associative-arrays.md) — Hash maps from string keys to string values.
11. [4.11 Namerefs (`-n`)](11_Namerefs-n.md) — A nameref is a variable whose value is the *name* of another variable; reads and writes through the nameref are forwarded to the target.
12. [4.12 Integer arithmetic semantics](12_Integer-arithmetic-semantics.md) — Bash arithmetic is signed 64-bit on every modern Linux.
13. [4.13 Variable assignment semantics](13_Variable-assignment-semantics.md) — When and how bash evaluates assignments.
14. [4.14 Unsetting](14_Unsetting.md) — Removing variables and functions from the shell.

---

← Previous: [Part III — Lexical Structure and Shell Grammar](../03_Lexical-Structure-and-Shell-Grammar/index.md)

Next: [Part V — Expansions](../05_Expansions/index.md) →

#fin
