<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.10 Shell grammar

Bash's grammar — what the parser builds *after* the tokeniser of §3.1
has emitted its words and operators — is small, recursive, and
hierarchical. Five layers wrap each other from the smallest unit up
to the whole script. Every error message of the form "syntax error
near unexpected token …" is the parser failing to fit a token into
one of the productions below.

### The grammar in BNF form

```bnf
simple-command   ::= [assignment | redirection]* WORD [WORD | redirection]*
pipeline         ::= ['time'] ['!'] command ('|' | '|&') command)*
and-or-list      ::= pipeline (('&&' | '||') pipeline)*
list             ::= and-or-list ((';' | '&' | NEWLINE) and-or-list)* [';' | '&']
compound-command ::= brace-group | subshell | for | case | if | while | until
                   | select | arithmetic-cmd | conditional-cmd
command          ::= simple-command | compound-command | function-definition
function-definition ::= [ 'function' ] WORD [ '(' ')' ] compound-command [ redirection* ]
```

Read each production as "the left side **is** any of the right-side
forms". The recursion is genuine: a `pipeline` can be wrapped in a
`( … )` (subshell, a `compound-command`), which makes it a
`command`, which is the body of another `pipeline`, and so on
indefinitely.

### Layer-by-layer meaning

- **Simple command:** the leaf — a command name with arguments and
  redirections. Assignments may precede the command word (`PATH=/x cmd`).
- **Pipeline:** one or more commands joined by `|` or `|&`; the
  optional `time` reserved word measures wall/CPU time, and the
  optional `!` inverts the final exit status (relevant under `set -e`,
  see §13.2).
- **AND-OR list:** pipelines joined by short-circuit `&&`/`||`. These
  are equal-precedence and **left-associative** — the source of the
  classic `a && b || c` footgun (§3.11).
- **List:** the largest unit Bash treats as one logical command. `;`
  and newline sequence; `&` backgrounds. A trailing `;` is optional;
  a trailing `&` is the difference between sync and async.
- **Compound command:** bracketed structure (`if`, `while`, `for`,
  `case`, `(( ))`, `[[ ]]`, `{ … }`, `( … )`) that itself contains a
  list. Loops and conditionals are commands, not statements.

### Worked example: parse tree of a real pipeline

```bash
# scenario: parse `time ! grep -q ERROR log | wc -l && notify || true`
```

```text
list
└── and-or-list
    ├── pipeline                             ← time ! grep -q ERROR log | wc -l
    │   ├── time              (modifier)
    │   ├── !                 (negation)
    │   ├── simple-command    grep -q ERROR log
    │   └── simple-command    wc -l
    ├── &&  →  pipeline / simple-command     notify
    └── ||  →  pipeline / simple-command     true
```

`time` and `!` attach to the pipeline as a whole; `&&` and `||` join
pipelines into the and-or-list; the trailing newline (or `;`) would
end the list. Note that `time` cannot be applied to the
`and-or-list` as a unit — to time the whole expression you must wrap
it in a brace group: `time { grep … | wc -l && notify || true; }`.

### Worked example: function definition is a compound command

```bash
greet() {
  local -- name="${1:-world}"
  printf 'hello, %s\n' "$name"
}
```

The body `{ … }` is a brace group — itself a `compound-command` —
which under the function-definition production becomes the function's
body. This is why the `}` must be on its own line or preceded by
`;` (the brace group's `list` production requires a terminator before
the closing brace).

### Where redirections attach

A redirection (`>`, `<`, `2>&1`, etc.) is a child of the **simple
command** at lexical level — `cmd > out` redirects only `cmd`. To
redirect the output of a *compound* command, the redirection must
follow the closing keyword:

```bash
{ cmd1; cmd2; } > combined.log    # right — applies to both
( cmd1; cmd2 ) > sub.log          # right — subshell with redirected stdout
while read -r l; do echo "$l"; done < input.txt
```

Redirecting the head of a pipeline only affects that head:
`cmd1 > x | cmd2` discards `cmd1`'s stdout to `x`, leaving `cmd2`
to read whatever `cmd1` writes to `&3` or stderr.

### Why every layer matters in practice

Each layer above introduces a distinct error-handling rule:

- **Simple-command** failure under `set -e` exits the script — unless
  the command is in a tested position (see below).
- **Pipeline** exit status is the rightmost command (default) or the
  rightmost *non-zero* (under `pipefail`, BCS0101). Without
  `pipefail`, `cat missing.txt | head` returns success.
- **AND-OR list** short-circuits: `cmd1 && cmd2` skips `cmd2` if
  `cmd1` fails; `cmd1 || cmd2` skips `cmd2` if `cmd1` succeeds.
- **List**: `cmd1; cmd2` always runs both; `cmd1 & cmd2` backgrounds
  `cmd1` and continues without waiting.

The "tested position" rule for `set -e` (§13.2) is defined in terms
of the grammar layers: a simple command is tested if it is the LHS
of `&&` or `||`, the head of `if`/`while`/`until`, or negated by `!`.
Anything else is untested and a failure exits the script.

### Strict-mode note

`set -e`, `inherit_errexit`, and `pipefail` interact with these
layers at well-defined points: a pipeline's exit status is the **last**
command's by default, or — under `pipefail` — the rightmost non-zero;
`set -e` triggers on any failed simple command not in a tested
position (the LHS of `&&`/`||`, `if`/`while` head, `!`-negated). The
grammar is the substrate; error handling (§13) is the policy on top.

**See also**: §3.1 (tokenisation), §3.2 (reserved words), §3.11
(operator precedence), §7 (control flow), §13.2 (errexit semantics),
BCS0101, BCS0501, BCS0601.

#fin
