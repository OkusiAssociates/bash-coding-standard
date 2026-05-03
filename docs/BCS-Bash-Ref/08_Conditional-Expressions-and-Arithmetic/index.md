<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part VIII — Conditional Expressions and Arithmetic

*Bash has two test contexts: `[[ ]]` for file/string/regex and `(( ))` for arithmetic. The legacy `[ ]` POSIX test exists but is not used in modern Bash. This Part documents both contexts, their operators, and their precedence rules.*

---

## Chapters

1. [8.1 `[[ ]]` overview](01_overview.md) — The modern conditional command.
2. [8.2 File test operators](02_File-test-operators.md) — Single-operand tests on files.
3. [8.3 File comparison operators](03_File-comparison-operators.md) — Two-operand file tests.
4. [8.4 String operators](04_String-operators.md) — String comparison and inspection.
5. [8.5 Pattern matching with `==`](05_Pattern-matching-with.md) — Right-hand side of `==` (or `=`) inside `[[ ]]` is a glob pattern unless quoted.
6. [8.6 Regex matching with `=~`](06_Regex-matching-with.md) — Right-hand side of `=~` is an ERE (extended regular expression).
7. [8.7 Logical operators and grouping](07_Logical-operators-and-grouping.md) — Inside `[[ ]]`, logical operators combine sub-expressions.
8. [8.8 Quoting rules inside `[[ ]]`](08_Quoting-rules-inside.md) — `[[ ]]` is a reserved word, parsed specially.
9. [8.9 Arithmetic context `(( ))`](09_Arithmetic-context.md) — `(( expression ))` evaluates expression as arithmetic, returns 0 if non-zero, 1 if zero.
10. [8.10 Arithmetic operators and precedence](10_Arithmetic-operators-and-precedence.md) — Bash arithmetic supports a rich operator set with C-like precedence.
11. [8.11 Integer types, overflow, base prefixes](11_Integer-types-overflow-base-prefixes.md) — Bash arithmetic uses signed C `intmax_t` — typically 64-bit on Linux.
12. [8.12 Floating-point — workarounds](12_Floating-point-workarounds.md) — Bash has no native floats.
13. [8.13 `let` builtin](13_let-builtin.md) — `let` evaluates its arguments as arithmetic expressions, returning failure if the last evaluates to zero.
14. [8.14 The deprecated `[ ]` and `test`](14_The-deprecated-and-test.md) — POSIX `test` builtin and its `[ ]` synonym.

---

← Previous: [Part VII — Control Flow and Compound Commands](../07_Control-Flow-and-Compound-Commands/index.md)

Next: [Part IX — Functions](../09_Functions/index.md) →

#fin
