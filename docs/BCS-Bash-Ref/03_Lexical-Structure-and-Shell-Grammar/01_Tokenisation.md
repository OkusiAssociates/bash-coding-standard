<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.1 Tokenisation

Bash splits its input into **tokens** — *words* and *operators* — before
any expansion happens. The tokeniser is purely lexical: it knows about
characters, quoting, and longest-match operator recognition, but
nothing about variables, builtins, or aliases. Every later stage
(expansion, parsing, execution) is built on top of the token stream
this layer produces, so most "why doesn't this parse?" questions are
really tokenisation questions in disguise.

### The character classes

The tokeniser recognises four classes of unquoted character:

| Class | Members | Effect |
|-------|---------|--------|
| Blank | space, tab | Ends the current word; not part of any token. |
| Metacharacter | space, tab, newline, `\|`, `&`, `;`, `(`, `)`, `<`, `>` | Always ends a word; some begin operators. |
| Control operator | `\|\|`, `&&`, `&`, `;`, `;;`, `;&`, `;;&`, `\|`, `\|&`, `(`, `)`, newline | A token in its own right; controls list/pipeline structure. |
| Word constituent | everything else, plus *anything quoted* | Accumulated into the current word. |

A newline is both a blank and a metacharacter — outside an unfinished
construct it terminates the command list; inside (`if`, `{ … }`, an
open quote) it is just whitespace.

### Words versus operators

A **word** is a maximal run of word constituents, possibly including
quoted regions. An **operator** is a single token recognised from the
control-operator set above. The distinction matters because:

- Operators are recognised by **longest match**: `&&` is one token, not
  two `&` tokens, and `<<` is the here-doc operator, not "redirect
  followed by redirect".
- Word boundaries are decided *before* expansion. `$var` is one word
  during tokenisation regardless of what `$var` later expands to (this
  is why unquoted expansions split — splitting happens later, on the
  expanded result).
- Reserved words (§3.2) are words that the *parser* later promotes to
  syntactic keywords; the tokeniser itself emits them as plain words.

### Worked example: tokenising `[[ -f $f ]]`

```bash
# scenario: trace the token stream of a typical conditional.
# input:  [[ -f $f ]]
# tokens: WORD([[)  WORD(-f)  WORD($f)  WORD(]])
```

Four words, three blanks. The blanks are mandatory: `[[-f` would be a
single word (`[[-f`) which is *not* the reserved word `[[`, so the
parser would treat it as a command name and bash would try to execute
a program literally called `[[-f`. The same logic explains why `((`
is parsed as `( (` (two subshell-open tokens, not the arithmetic
opener) when written `( (expr))` with a space — longest-match runs
left-to-right at the *operator* level only, not across word/operator
boundaries.

### Worked example: quoting freezes word boundaries

```bash
# scenario: show that quoting overrides every blank inside it.
set -- a"b c"d "e f"
printf '[%s]\n' "$@"
# ⇒ [ab cd]
# ⇒ [e f]
```

The first argument is **one** word — `a`, the quoted run `b c`, then
`d` — concatenated by adjacency. Tokenisation respects the quotes;
the embedded space never reaches the word-boundary logic. This is the
mechanism that makes `"$var"` safe regardless of the variable's
contents.

### Operator-recognition corner cases

Three patterns trip up readers and linters alike:

- **`&&` versus `& &`**: written together, longest-match consumes both
  `&` characters as one logical-AND operator. Separated by a space,
  the tokeniser emits two `&` control operators, which the parser
  reads as "background the empty command, then background again" — a
  syntax error.
- **`<<` versus `< <`**: `<<` is the here-doc operator; `< <` is two
  redirections, valid only with process substitution between them
  (`cmd < <(producer)`).
- **`;;` inside `case`**: `;;`, `;&`, `;;&` are *only* recognised as
  control operators inside a `case` body. Elsewhere the parser
  rejects them, and a stray `;;` is a common cause of obscure error
  messages outside of `case`.

### Why `((` and `[[` need their spaces

The reserved words `[[`, `]]`, `((`, `))` are recognised by the
*parser* on a fully-formed word boundary. The tokeniser does not know
they are special — it just produces words. So:

- `[[ -f $f ]]` → four words `[[`, `-f`, `$f`, `]]`. The parser
  sees the first word and enters conditional-command mode.
- `[[-f $f]]` → two words `[[-f` and `$f]]`. The parser tries to run
  a command literally named `[[-f`. The error message ("command not
  found") arrives long after the real bug.

The pattern generalises: any "special" syntactic marker that is
written without a magic operator character must be space-separated
from its arguments. This is also why `function name(){}` works (the
`(` is itself a metacharacter that starts a new token) but
`if[[…]]then` does not.

### Strict-mode interaction

`set -e` and `set -u` operate on the parsed/executed command, not on
tokens, so token-level mistakes (a missing space around `[[`, a
forgotten `;` before `then`) surface as parse errors **before** strict
mode has a chance to act. They are caught by `bash -n script` (parse
only) and by `shellcheck`, both of which consume the token stream
directly. The remedy is mechanical: run `bash -n` in CI on every
script, or rely on `shellcheck` to flag the whole class.

**See also**: §3.2 (reserved words), §3.4 (quoting overview), §3.10
(grammar), BCS0301.

#fin
