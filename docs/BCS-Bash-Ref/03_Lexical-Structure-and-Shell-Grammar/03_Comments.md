<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.3 Comments

The `#` character introduces a comment to end-of-line, but only in specific contexts. The exact rule the parser applies: `#` begins a comment when it is the first character of a token. Mid-token, it is a literal `#`. This trips beginners constantly and footguns experienced scripters in `printf` format strings.

Where `#` is a comment:

- At the start of a line (the prototypical case).
- After whitespace, where a fresh token would begin.
- After most metacharacters and operators (`;`, `&`, `|`, `(`, `)`, newline).

Where `#` is **not** a comment:

- Mid-word: `foo#bar` is a single literal token.
- Inside double quotes: `"hello # world"` — literal hash.
- Inside single quotes: `'#'` — literal hash.
- Inside ANSI-C quoting: `$'#'` — literal hash.
- After `${` — `${var#prefix}` is the prefix-strip operator, not a comment.
- Inside `[[ … ]]`: `#` is treated as a word character (no comment recognition).
- In the digit-position of `${10}` etc. — irrelevant, but worth noting `#` has another role as `${#var}` (length).

```bash
# scenario: contrast leading vs mid-word
echo foo#bar                  # ⇒ foo#bar
echo foo #bar                 # ⇒ foo
echo "foo # bar"              # ⇒ foo # bar
url=https://x#frag            # → assigns the full URL with fragment
echo "$url"                   # ⇒ https://x#frag
result=${url#https://}        # → parameter expansion, # is the strip-prefix op
echo "$result"                # ⇒ x#frag
```

Interactive shells with `interactive_comments` shopt **off** treat `#` as literal even at line start; the default is on, and BCS scripts run with no expectation of disabling it.

BCS comment style (BCS1202): leading `#`-comments only — a comment occupies its own line. End-of-line comments after code are forbidden by the standard. The parser permits them; the standard does not.

```bash
# wrong — end-of-line comment (BCS1202 violation)
declare -i count=0   # how many widgets we have
# right — comment on its own line
# how many widgets we have
declare -i count=0
```

The `#!` "shebang" on line 1 is a comment to Bash but a magic number to the kernel — that line is what selects the interpreter (BCS0102). Anything after the shebang line is parsed normally.

**See also**: §3.1 (tokenisation rules that decide "is this `#` first-of-token?"), §3.5 / §3.6 (quoting that suppresses comment recognition), §5.4 (`${var#prefix}` parameter expansion), BCS1202 (comment style mandate).

#fin
