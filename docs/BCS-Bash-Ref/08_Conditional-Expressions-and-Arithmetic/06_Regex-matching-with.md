<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.6 Regex matching with `=~`

The right-hand side of `=~` is an ERE (POSIX extended regular expression). The cardinal rule: **quoting the RHS changes semantics**. A quoted RHS matches its *literal* characters; regex metacharacters lose their meaning. This is the single most surprising behaviour of `[[ ]]` — and the one most likely to produce a test that *appears* to pass while validating nothing.

### Captures and `BASH_REMATCH`

Successful matches populate the indexed array `BASH_REMATCH`:

- `BASH_REMATCH[0]` — the entire match.
- `BASH_REMATCH[1]…[N]` — text captured by parenthesised groups, in order.

`BASH_REMATCH` is *volatile*: the next `=~` evaluation overwrites it, even an unrelated one in some other function. Copy the values you care about into named variables immediately, before any further conditional logic.

POSIX character classes (`[[:alpha:]]`, `[[:digit:]]`, `[[:space:]]`, `[[:xdigit:]]`, etc.) are supported and respect the current locale. For ASCII-only validation in scripts that may run under a UTF-8 locale, prefer explicit ranges (`[A-Za-z0-9]`) over `[[:alnum:]]`.

### The quoting trap

For a regex containing whitespace, alternation, or shell-special characters, store it in a variable and reference it unquoted. This is the only sane way to keep the pattern readable, and — more importantly — the only way to compose patterns from constants without falling into the quoting trap.

### Examples

```bash
# scenario: capturing version components from a tag.
declare -- tag='v2.17.4-rc1'
if [[ $tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  declare -i major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}
  printf 'major=%d minor=%d patch=%d\n' "$major" "$minor" "$patch"
fi
# ⇒ major=2 minor=17 patch=4
```

The `[0-9]+` quantifier is a regex feature; if the RHS were quoted, it would mean "the four-character string `[0-9]+`" and the match would fail.

```bash
# scenario: quoting the RHS breaks the regex — a common silent failure.
declare -- s='abc123'
[[ $s =~ ^[a-z]+[0-9]+$ ]]   && echo 'unquoted: matches'    # ⇒ unquoted: matches
[[ $s =~ "^[a-z]+[0-9]+$" ]] || echo 'quoted: literal only' # ⇒ quoted: literal only
```

The second test asks whether `abc123` contains the literal text `^[a-z]+[0-9]+$` as a substring. It does not. The bug here is that the test reads as a successful regex check to anyone skimming the code; only a failing edge-case input reveals it. Worse, the validation is *consistently negative* — it rejects every input — which often gets papered over with "well, the validation is strict".

```bash
# scenario: variable-stored pattern — the recommended idiom.
declare -- pat='^(error|warn|info):[[:space:]]*(.*)$'
declare -- line='warn: low disk'
if [[ $line =~ $pat ]]; then
  printf 'level=%s message=%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
fi
# ⇒ level=warn message=low disk
```

The variable form has three virtues beyond readability: it sidesteps the quoting trap (the variable expansion is *not* quoted, so its content is treated as regex); it lets you keep complex patterns in named, testable constants; and it lets you build a regex by composition without the escaping hell that arises when the pattern itself contains quotes or whitespace.

A practical rule: if a regex contains anything beyond simple character classes and quantifiers, lift it into a `declare -r pat=…` constant near the top of the function. This gives reviewers one place to audit, and keeps the conditional itself readable.

**See also**: §8.5 (glob alternative), §22.x (input validation), BCS0303, BCS0501.

#fin
