<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part III — Lexical Structure and Shell Grammar

*Before any expansion, before any execution, bash tokenises and parses input. This Part documents the language at the level of characters and grammar — the rules that determine what counts as a word, an operator, or a reserved word.*

---

## Chapters

1. [3.1 Tokenisation](01_Tokenisation.md) — Bash splits input into tokens — words and operators — using a specific algorithm that respects quoting.
2. [3.2 Reserved words](02_Reserved-words.md) — A small set of identifiers that bash recognises as syntax keywords when they appear in command position.
3. [3.3 Comments](03_Comments.md) — The `#` character introduces a comment to end-of-line, but only in specific contexts.
4. [3.4 Quoting overview](04_Quoting-overview.md) — Quoting is the mechanism by which the user defers or suppresses bash's expansion behaviour.
5. [3.5 Single quotes](05_Single-quotes.md) — Single quotes preserve the literal value of every character within them.
6. [3.6 Double quotes](06_Double-quotes.md) — Double quotes preserve most characters literally but allow parameter expansion, command substitution, arithmetic expansion, and backslash escaping for a small set.
7. [3.7 ANSI-C quoting `$'...'`](07_ANSI-C-quoting.md) — Quoting form that interprets backslash escapes the way C does.
8. [3.8 Locale-translation `$"..."`](08_Locale-translation.md) — Quoting form that triggers a gettext lookup against the program's message catalogue.
9. [3.9 Backslash escapes](09_Backslash-escapes.md) — Backslash outside quoting preserves the literal value of the next character.
10. [3.10 Shell grammar](10_Shell-grammar.md) — Bash's grammar at the structural level: simple commands, pipelines, lists, compound commands.
11. [3.11 Operator precedence](11_Operator-precedence.md) — The precedence and associativity of shell operators — distinct from arithmetic operator precedence (§8.10).

---

← Previous: [Part II — Bash as a Program](../02_Bash-as-a-Program/index.md)

Next: [Part IV — Parameters, Variables, and Arrays](../04_Parameters-Variables-and-Arrays/index.md) →

#fin
