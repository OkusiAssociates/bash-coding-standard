<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.4 Quoting overview

Quoting is the mechanism by which the script author **defers or
suppresses** Bash's expansion behaviour. There are five concrete
forms, each with different rules about what is preserved literally
and what is allowed to expand. Choosing the right one — almost always
double quotes around a variable — is the single most consequential
hygiene decision in shell programming, and the root cause of the vast
majority of "it worked until the filename had a space" bugs.

### The expansion-suppression hierarchy

Read this table top-to-bottom as "quietest first". Each row lists what
the form *allows* through; everything not listed is preserved
literally.

| Form | Suppresses | Allows | Notes |
|------|------------|--------|-------|
| `'…'` (single) | everything | nothing | Cannot contain a literal `'`. |
| `$'…'` (ANSI-C) | most expansion | backslash escape sequences only | Useful for `\t`, `\n`, `\xNN`, `\uNNNN`. |
| `"…"` (double) | word splitting, pathname expansion | `$var`, `${…}`, `$(…)`, `$(( ))`, `` ` `` (history `!` only when interactive) | The default for parameter use. |
| `\c` (backslash) | meaning of one character | n/a | Inside `"…"` only escapes a small set (§3.9). |
| `$"…"` (locale) | as `"…"` | as `"…"` | After expansion, the result is passed to `gettext`. Rare. |
| (unquoted) | nothing | everything | Word splitting and pathname expansion *will* occur. |

### Why `"$var"` is the always-correct default

```bash
# scenario: the same variable expanded with and without quotes.
declare -- file='my report.txt'

ls $file        # wrong — expands to two words: ls "my" "report.txt"
ls "$file"      # right — one argument, exactly as stored
```

Without quotes, the shell first expands `$file` to `my report.txt`
and **then** word-splits the result on `IFS`, producing two arguments.
With quotes, splitting is suppressed. This is not a stylistic
preference; it is a correctness requirement under `set -u` and
`inherit_errexit` (BCS0101). The only legitimate reason to omit the
quotes is when you *want* word splitting — and in that case write
`read -ra` or an explicit `IFS=` redefinition, not bare `$var`, so
the intent is visible.

### Composability

Quoting forms compose by **lexical adjacency**, not nesting. There is
no such thing as a single quote inside a single-quoted string —
adjacent runs are concatenated:

```bash
# scenario: the close-escape-reopen idiom for embedding a literal '.
echo 'it'\''s'      # ⇒ it's
echo "it's"         # ⇒ it's   (cleaner)
echo $'it\'s'       # ⇒ it's   (ANSI-C alternative)
```

Inside `$(…)` or `` `…` ``, quoting is **independent** of the outer
context — the inner shell parses its body afresh. This is why
`"$(grep 'pattern' "$file")"` works: the outer double quotes do not
reach into the substitution.

### When other forms beat double quotes

- Single quotes when the value is a literal that should never be
  re-interpreted: regular expressions, AWK programs, JSON fragments.
- ANSI-C quoting (`$'…'`) when you need control characters by name
  (`$'\t'`, `$'\n'`, `$'\x1b'`) — see §3.7.
- Backslash escape (`\c`) for one or two metacharacters in an
  otherwise-unquoted command (`echo a\ b` is ugly; prefer `echo "a b"`).

### Common mis-quoting patterns

```bash
# wrong — variable will word-split if it contains whitespace.
cp $src $dst

# right — each side is one argument no matter what.
cp -- "$src" "$dst"

# wrong — single-quoted, so $HOME is literal "$HOME".
echo 'home is $HOME'

# right — double-quoted preserves the literal "is" while expanding $HOME.
echo "home is $HOME"
```

The most frequent bug is the first form: a script that worked in
testing because no path had a space, then failed in production
because someone created `My Documents/`. Quote first, optimise later.

### Quoting inside command substitution is independent

`$(…)` and `` `…` `` start a fresh parsing context. The outer quotes
do not reach inside; the inner shell tokenises and parses the body
on its own terms:

```bash
# scenario: outer double quotes; inner single quotes are literal-mode again.
declare -- name='world'
declare -- greeting="$(printf 'hello, %s\n' "$name")"
printf '%s' "$greeting"
# ⇒ hello, world
```

The inner `'%s\n'` is single-quoted *inside* `$(…)` — it does not
need to be escaped from the outer `"…"`. The same is true of
`$(grep "pattern" "$file")` — the inner `"…"` is not a re-escape of
the outer pair, it is a fresh quoting context. This is one of the
practical advantages of `$(…)` over the legacy backtick form, which
required cumbersome backslash-escaping for nested quotes.

### Strict-mode note

Under `set -u`, an unquoted expansion of an unset variable still
errors, but the diagnostic is far worse: word splitting may produce
zero arguments, silently changing the command's shape before the
unset detection fires. Quoting brings the failure forward to its
true cause.

**See also**: §3.5 (single quotes), §3.6 (double quotes), §3.7 (ANSI-C
quoting), §3.9 (backslash escapes), BCS0301, BCS0303, BCS0307.

#fin
