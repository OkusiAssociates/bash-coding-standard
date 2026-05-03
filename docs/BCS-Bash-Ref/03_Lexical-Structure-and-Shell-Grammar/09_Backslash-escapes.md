<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.9 Backslash escapes

Backslash is the lexical "escape next character" operator, but its meaning depends on the surrounding quoting context. The four contexts each have a different rule, and confusing them is the second-most-common quoting bug after forgetting to quote at all.

The four contexts in one table:

| Context        | Rule                                                                             |
|----------------|----------------------------------------------------------------------------------|
| Unquoted       | `\X` is literal `X`; loses any special meaning. `\<newline>` is line continuation. |
| Inside `"..."` | Escapes only `\$`, `` \` ``, `\"`, `\\`, `\<newline>`. Any other `\X` stays as two characters: `\` and `X`. |
| Inside `'...'` | No interpretation. Backslash is always literal. There is no escape for `'`.       |
| Inside `$'...'`| Full C-style escape table (§3.7).                                                |

One demo per context:

```bash
# scenario: unquoted — backslash demotes a metacharacter
echo a\ b                     # ⇒ a b               (the space is literal)
echo \$HOME                   # ⇒ $HOME             (no expansion)
echo line1\
line2                         # ⇒ line1line2        (line continuation, newline removed)

# scenario: inside double quotes — only the five magic escapes work
echo "price=\$5"              # ⇒ price=$5
echo "path=C:\Users\name"     # ⇒ path=C:\Users\name (the \U and \n are literal pairs)
echo "$(printf 'a\\b')"       # ⇒ a\b               (two-step: printf, then literal)

# scenario: inside single quotes — backslash is just a character
echo '\n is literal'          # ⇒ \n is literal
echo 'C:\Users\name'          # ⇒ C:\Users\name     (no Windows-path agony)

# scenario: inside ANSI-C quoting — full escape table (§3.7)
echo $'tab\there\nend'        # ⇒ tab     here
                              # ⇒ end
```

The double-quote rule is the subtle one: only five escape sequences are recognised inside `"..."` (`\$`, `` \` ``, `\"`, `\\`, `\<newline>`); any other `\X` stays as **two characters**. This means `"\n"` inside double quotes is literally backslash-n, not a newline. Reach for `$'...'` (§3.7) when newlines are needed.

Line continuation (`\<newline>`) works inside double quotes too — both the backslash and the newline disappear:

```bash
# scenario: long string built across lines
msg="hello \
world"                        # ⇒ "hello world"     (the \-newline is removed)
```

BCS strongly prefers single quotes for static strings (BCS0301, BCS0307), which sidesteps this maze entirely. Reach for double quotes only when expansion is wanted; reach for `$'…'` only when control characters are needed.

**See also**: §3.4 (quoting overview), §3.5 (single quotes), §3.6 (double quotes), §3.7 (ANSI-C quoting full escape table), BCS0301 (Quoting Fundamentals), BCS0307 (Anti-Patterns).

#fin
