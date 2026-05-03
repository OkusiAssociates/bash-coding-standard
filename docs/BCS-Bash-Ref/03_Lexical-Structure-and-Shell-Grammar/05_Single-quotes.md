<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.5 Single quotes

Single quotes preserve the literal value of every character within them. **No** expansion of any kind, **no** escape sequences, **no** exception. The only character that cannot appear inside single quotes is a single quote itself; there is no escape for `'` between `'…'` — you must close, escape, and reopen.

The full rules:

- No parameter expansion: `'$var'` is the four characters `$`, `v`, `a`, `r`.
- No command substitution: `'$(cmd)'` is the literal string.
- No arithmetic expansion: `'$((1+1))'` is literal.
- No backslash escaping: `'\n'` is two characters, `\` and `n`.
- Newlines are literal — single quotes span lines without continuation.
- Single quotes do **not** nest inside single quotes; the close-escape-reopen idiom is mandatory.
- Inside double quotes, `'` is itself literal (so a sentence with an apostrophe written inside `"..."` needs no further work).

The close-escape-reopen idiom in code (this is the canonical pattern):

```bash
# scenario: embed a literal single quote inside a single-quoted string
echo 'it'\''s'                # ⇒ it's
# decomposition:
#   'it'   close after "it"
#   \'     escaped single quote (a literal apostrophe in the unquoted gap)
#   's'    reopen, append "s"
# the shell concatenates adjacent quoted/unquoted runs into one word

# scenario: alternative — switch to double quotes (or ANSI-C)
echo "it's"                   # ⇒ it's
echo $'it\'s'                 # ⇒ it's            (ANSI-C, see §3.7)
```

BCS prefers single quotes for **static strings** (BCS0301, BCS0307) — promote single quotes to double quotes only when expansion is actually needed. The rule is positive ("use single quotes for static") rather than negative; the result is a script in which the presence of double quotes signals expansion intent at every site.

```bash
# wrong — double quotes around a static string (BCS0307 anti-pattern)
info "Starting backup..."
# right — single quotes; nothing expands
info 'Starting backup...'
# right — double quotes only because $target is expanded
info "Starting backup of $target..."
```

**See also**: §3.4 (quoting overview — when to reach for which form), §3.6 (double quotes), §3.7 (ANSI-C `$'...'` for control characters and Unicode), BCS0301 (Quoting Fundamentals), BCS0307 (Anti-Patterns).

#fin
