<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.1 `[[ ]]` overview

The modern conditional command. `[[` is a *reserved word*, not a builtin: bash recognises it during grammar parsing, before any expansion runs over its operands. That single fact explains every quoting peculiarity in this section, and is the load-bearing distinction between `[[ ]]` and the legacy `[ ]` test command (§8.14).

Because parsing happens first, the shell knows the *structure* of the expression — left operand, operator, right operand — before it knows any of the *values*. That structural knowledge lets `[[ ]]` suspend two normally-mandatory expansion phases (word splitting and pathname expansion) on its operand text, and lets it apply operator-specific quoting rules to the right-hand side of `==`, `!=`, and `=~`. None of this is possible inside a command whose arguments are parsed only after expansion.

### Properties

- Syntax: `[[ expression ]]`. Returns 0 (true), 1 (false), or 2 on a syntax error.
- Operands undergo parameter, command, arithmetic, and process substitution; word splitting and pathname expansion are *suppressed* — variables are safe unquoted in any operand position (BCS0303).
- Logical operators inside the brackets: `&&`, `||`, `!`, parentheses for grouping. Unlike `[ ]`, these are *part of the conditional grammar*, not separate shell tokens — they need no escaping.
- Variable expansions on the *left* of an operator never need quoting. On the *right* of `==`, `!=`, or `=~`, quoting changes meaning.
- Right-hand side of `==`/`!=` is a glob pattern unless quoted (see §8.5).
- Right-hand side of `=~` is an ERE; quoting demotes the pattern to a literal string (see §8.6).

### The reserved-word consequence

```bash
# scenario: parse-time recognition lets bash treat [[ specially.
declare -- file='report file.txt'   # space in name would break [ -f $file ]
[[ -f $file ]] && echo 'exists'     # ⇒ exists (no quoting required)
[[ -f $UNSET ]] || echo 'absent'    # ⇒ absent (unset operand is empty string)
```

Inside `[[ ]]`, the unquoted `$file` cannot word-split into two arguments, because no word splitting is performed; and `$UNSET` does not need a default substitution, because `[[ -f '' ]]` is a well-defined false. The same operands inside `[ ]` would require defensive quoting and `${UNSET:-}` guards.

### The quoting-on-RHS rule

```bash
# scenario: same RHS, two meanings, controlled only by quoting.
declare -- f='report.txt'
[[ $f == *.txt ]]   && echo 'glob match'        # ⇒ glob match
[[ $f == "*.txt" ]] || echo 'literal differs'   # ⇒ literal differs
[[ $f == '*.txt' ]] || echo 'single-quoted too' # ⇒ single-quoted too
```

The asymmetry — left positions take values, right positions take *patterns* — is intentional: the right-hand side of a comparison is the only place where bash needs a glob/regex grammar at all, so that is the only place where quoting changes semantics.

**See also**: §8.5 (glob RHS), §8.6 (regex RHS), §8.8 (quoting rules), §8.14 (deprecated `[`/`test`), BCS0303, BCS0501.

#fin
