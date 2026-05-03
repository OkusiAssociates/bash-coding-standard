<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.8 Quoting rules inside `[[ ]]`

`[[ ]]` is a reserved-word construct, parsed by bash *before*
ordinary word-splitting. Quoting rules are therefore relaxed
compared to ordinary commands — but they are not absent, and the
places where quoting *changes meaning* trip up even experienced
authors.

- Variable expansions: quoting is optional but harmless on the LHS
  of every operator. Inside `[[ ]]`, `[[ $f == foo ]]` is safe even
  if `$f` contains spaces, because no word-splitting occurs.
- Right of `==` / `!=`: **quoting matters** — unquoted RHS is a
  shell glob; quoted RHS is a literal string.
- Right of `=~`: **quoting matters** — unquoted RHS is an extended
  regular expression; quoted RHS is a literal string match (§8.6).
- Word splitting and pathname expansion do **not** occur inside
  `[[ ]]`.
- Operators must not be quoted: `[[ $a "<" $b ]]` compares against
  the *literal character* `<`, not lexicographically.

### Paired quoting matrix

The same value with three different quoting decisions illustrates
all three categories — harmless, required, and wrong:

```bash
# scenario: paired matrix — when quoting helps, when it must, when it breaks.
#!/usr/bin/env bash
set -euo pipefail

# CASE 1 — LHS quoting is harmless either way.
file='my report.txt'
[[ $file  == 'my report.txt' ]] && echo 'unquoted LHS: ok'   # ⇒ unquoted LHS: ok
[[ "$file" == 'my report.txt' ]] && echo 'quoted LHS: ok'    # ⇒ quoted LHS: ok (BCS0301)

# CASE 2 — RHS of ==: quoting is *required* to compare literally.
name='*.bash'
[[ install.bash == $name   ]] && echo 'unquoted RHS: glob match'    # ⇒ glob match (treats *.bash as glob)
[[ install.bash == "$name" ]] && echo 'quoted RHS: literal match'  || \
  echo 'quoted RHS: no literal match'                              # ⇒ no literal match (BCS0303)

# CASE 3 — operators must NOT be quoted.
a='abc' b='abd'
[[ $a < $b   ]] && echo 'unquoted <: lex less'        # ⇒ lex less
[[ $a "<" $b ]] && echo 'quoted "<": lex less'        # NOT printed: "<" is now a literal,
                                                       # there is no operator, syntax error suppressed

# CASE 4 — RHS of =~: same rule as ==. Quoting forces literal matching.
re='^[0-9]+$'
[[ 12345 =~ $re   ]] && echo 'unquoted =~: regex match'      # ⇒ regex match
[[ 12345 =~ "$re" ]] && echo 'quoted =~: literal match'  || \
  echo 'quoted =~: no literal match'                          # ⇒ no literal match

#fin
```

The rule of thumb: **quote the LHS for hygiene; decide RHS quoting
by the semantics you want.** If you want a literal compare, quote
the RHS; if you want a glob/regex match, leave it unquoted (and
store the pattern in a variable so the *pattern itself* is the
quoted string).

**See also**: §8.5 pattern matching with `==`/`!=`, §8.6 regex
matching with `=~`, §3.2 single quotes, §3.3 double quotes,
BCS0301 (quoting fundamentals), BCS0303 (quoting in conditionals),
BCS0307 (anti-patterns).

#fin
