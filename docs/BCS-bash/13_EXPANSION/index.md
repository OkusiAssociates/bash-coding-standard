<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## EXPANSION

Expansion is performed on the command line after it has been split into words.  There are seven kinds of
expansion performed: brace expansion, tilde expansion, parameter and variable expansion, command substitution,
arithmetic expansion, word splitting, and pathname expansion.

The order of expansions is: brace expansion; tilde expansion, parameter and variable expansion, arithmetic
expansion, and command substitution (done in a left-to-right fashion); word splitting; and pathname expansion.

On systems that can support it, there is an additional expansion available: process substitution.  This is
performed at the same time as tilde, parameter, variable, and arithmetic expansion and command substitution.

After these expansions are performed, quote characters present in the original word are removed unless they
have been quoted themselves (quote removal).

Only brace expansion, word splitting, and pathname expansion can increase the number of words of the
expansion; other expansions expand a single word to a single word.  The only exceptions to this are the
expansions of "$@" and "${name[@]}", and, in most cases, $* and ${name[*]} as explained above (see
PARAMETERS).

---
- [Brace Expansion](01_Brace-Expansion.md)
- [Tilde Expansion](02_Tilde-Expansion.md)
- [Parameter Expansion](03_Parameter-Expansion.md)
- [Command Substitution](04_Command-Substitution.md)
- [Arithmetic Expansion](05_Arithmetic-Expansion.md)
- [Process Substitution](06_Process-Substitution.md)
- [Word Splitting](07_Word-Splitting.md)
- [Pathname Expansion](08_Pathname-Expansion.md)
- [Quote Removal](09_Quote-Removal.md)
