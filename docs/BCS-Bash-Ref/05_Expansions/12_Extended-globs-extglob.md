<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.12 Extended globs (extglob)

With `shopt -s extglob` enabled, bash's pattern syntax gains five
operators that bring it close to the expressive power of regular
expressions, while remaining shell-style globs (matched literally,
not anchored as regexes are). The operators apply uniformly to
pathname expansion (§5.9), `[[ word == pattern ]]` matching (§8), and
`case` (§7.5). The BCS strict-mode preamble (BCS0101) enables
`extglob` unconditionally, so these operators are always available in
a compliant script.

### The five operators

| Operator | Semantics |
|----------|-----------|
| `?(pat)` | zero or one occurrence of `pat` |
| `*(pat)` | zero or more occurrences |
| `+(pat)` | one or more occurrences |
| `@(pat)` | exactly one occurrence (alternation grouping) |
| `!(pat)` | anything *except* `pat` |

The `pat` is a *pattern list* — one or more sub-patterns separated by
`|`. Sub-patterns are themselves globs, optionally containing further
extglob operators.

### Each operator demoed

```bash
# scenario: each extglob operator in pathname expansion
shopt -s extglob nullglob

# Suppose the working directory contains:
#   report.txt  report.md  report.html  notes.txt  archive.tar.gz

ls ?(report).txt        # ⇒ report.txt              — ?( ) zero-or-one
ls *.@(md|html)         # ⇒ report.html report.md   — @( ) one of alternates
ls +([a-z]).txt         # ⇒ notes.txt report.txt    — +( ) one or more lowercase
ls *(report).txt        # ⇒ report.txt              — *( ) zero or more
ls !(*.tar.gz)          # ⇒ everything except archive.tar.gz
```

Note the difference between `@(a|b)` and a plain `[ab]`: the `@()`
form alternates *strings*, while `[ab]` alternates *single
characters*. Use `@()` whenever the alternates are multi-character —
filenames, extensions, words.

### The `!()` negation idiom

`!(pat)` is the operator most often missing from scripts that fall
back to a `for` loop with a `case` filter. It matches "anything that
does not match `pat`" — including the empty string. Combined with `|`
inside, it becomes "anything not in this list":

```bash
# scenario: clean a directory of every file except a small allow-list
shopt -s extglob

# Remove everything except *.bak, *.tmp, and the "keep" subdirectory
rm -rf -- !(*.bak|*.tmp|keep)

# Iterate every non-hidden non-source file
for f in !(*.bash|*.sh|.*); do
  process "$f"
done
```

The `!(...)` form is particularly useful in destructive commands —
saying "everything *except* X" once is safer and clearer than building
an explicit allow-list.

### Composability

Extglob operators nest. The pattern-list separator `|` allows
arbitrary alternation, and each alternate may itself be an extglob:

```bash
# scenario: composed extglob — image files except thumbnails
shopt -s extglob nullglob
declare -a images=( *.@(png|jpg|jpeg|gif) )      # one of these extensions
declare -a not_thumbs=( !(thumb_*).@(png|jpg) )  # excluding thumb_-prefixed
```

This is where extglob clearly outperforms POSIX sh and where reaching
for `find … -name …` is unnecessary.

### Use in `[[` and `case`

The same operators work in pattern-matching contexts that do not
involve the filesystem:

```bash
# scenario: extglob in [[ and case for input validation
shopt -s extglob
declare -- input='42abc'

if [[ $input == +([0-9])*([a-z]) ]]; then
  info 'digits-then-letters form'
fi

case "$input" in
  +([0-9]))         info 'pure number' ;;
  +([0-9])*([a-z])) info 'mixed' ;;
  *)                info 'other' ;;
esac
```

Pattern-matching here is glob-style, so `+([0-9])` means "one or more
digits", *not* the regex equivalent — there is no anchoring or
backreference. For full regex, use `[[ word =~ regex ]]` (§8).

### Pitfalls

- **Parsing**: bash parses extglob patterns at the moment the shopt
  is *active*. A pattern read into a variable while `extglob` is off
  is then re-parsed when used? No — the pattern's behaviour is set at
  command-evaluation time, but unbalanced parentheses in the source
  *file* under `extglob`-off can be a syntax error. Set `extglob`
  early (the strict-mode preamble does so).
- **Quoting**: the parentheses are special only when `extglob` is on.
  Inside double quotes, the operators are *not* expanded — `"+(a)"` is
  the literal four characters. Strip the quotes, or use `[[ x ==
  +(a) ]]` where the right-hand side is treated as a pattern.
- **Empty match**: `*(pat)` and `?(pat)` both match the empty string.
  `[[ '' == *(x) ]]` is true. This is occasionally surprising in
  validators.

**See also**: §5.9 (basic glob metacharacters that extglob extends),
§5.11 (`extglob` toggle and other glob shopts), §7.5 (`case`
pattern matching), §8 (`[[ == ]]` pattern operands and `=~` for true
regex), §22 (idiom: `!()` allow-list deletion), BCS0101 (strict-mode
preamble enables `extglob`), BCS0501 (conditional and case patterns).

#fin
