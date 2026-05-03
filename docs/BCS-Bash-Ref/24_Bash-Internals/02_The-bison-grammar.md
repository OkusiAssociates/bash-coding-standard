<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.2 The bison grammar

Bash 5.2 rewrote the command-substitution parser using a recursive bison grammar.

- Pre-5.2: ad-hoc parsing in C; subtle bugs around nesting and quoting.
- Bash 5.2: full bison grammar; cleaner, more correct.
- Files in source tree: `parse.y`, `subst.c`.
- Reading the grammar: bison `parse.y` is the canonical reference.
- Implications: bash 5.2 accepts some constructs that older bash rejected, and vice versa.

#fin
