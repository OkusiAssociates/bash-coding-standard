<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.7 ANSI-C quoting `$'...'`

A quoting form that interprets backslash escapes the way C does. Use it whenever a literal contains a control character (tab, newline, NUL), a non-ASCII byte, or a Unicode code point that is awkward to embed directly. BCS sanctions this form for escape-sequence emission (BCS0305).

The full escape table:

| Escape       | Result                                          |
|--------------|-------------------------------------------------|
| `\a`         | alert / bell (`0x07`)                           |
| `\b`         | backspace (`0x08`)                              |
| `\e`, `\E`   | ESC (`0x1B`)                                    |
| `\f`         | form feed (`0x0C`)                              |
| `\n`         | newline (`0x0A`)                                |
| `\r`         | carriage return (`0x0D`)                        |
| `\t`         | horizontal tab (`0x09`)                         |
| `\v`         | vertical tab (`0x0B`)                           |
| `\\`         | literal backslash                               |
| `\'`         | literal single quote                            |
| `\"`         | literal double quote                            |
| `\?`         | literal `?` (legacy C trigraph escape)          |
| `\nnn`       | byte with octal value `nnn` (1–3 digits)        |
| `\xHH`       | byte with hex value `HH` (1–2 digits)           |
| `\uHHHH`     | Unicode code point (4 hex digits) — UTF-8 encoded |
| `\UHHHHHHHH` | Unicode code point (8 hex digits) — UTF-8 encoded |
| `\cX`        | control-X (e.g. `\cA` is `0x01`)                |

```bash
# scenario: tab, byte, and Unicode in a single literal
printf '%s\n' $'tab\there\tend' $'byte=\xff' $'café'
# ⇒ tab
# ⇒ byte=
# (line 1 contains literal TABs between words; line 2 ends with a
#  raw 0xFF byte rendered per the terminal's locale)
# ⇒ cafe
# (the source uses `cafe` plus a combining-acute U+0301; the precomposed
#  é (U+00E9) is a different byte sequence)
```

The canonical script idiom — a strict-mode-safe `IFS` literal:

```bash
IFS=$' \t\n'                  # space, tab, newline (BCS1003 — IFS Safety)
```

The runtime alternative is `printf '%b\n'`, which interprets backslash escapes from a value already in a variable. Use ANSI-C quoting for compile-time literals (the parser does the work once) and `%b` for values that arrive from elsewhere.

```bash
# scenario: parse-time vs run-time escape interpretation
greeting=$'hello\tworld'      # interpreted at parse time
printf '%s\n' "$greeting"     # → "hello<TAB>world" (literal tab between words)
raw='hello\tworld'            # the four characters \, t plus rest
printf '%b\n' "$raw"          # → also "hello<TAB>world" (printf interprets \t)
printf '%s\n' "$raw"          # ⇒ hello\tworld
```

**See also**: §3.5 (single quotes — no escapes), §3.6 (double quotes — selective escapes), §3.9 (backslash-escape contexts), §14.5 (`printf` vs `echo` — why `printf '%b'` is the safe runtime form), BCS0305 (Printf Patterns), BCS1003 (IFS Safety).

#fin
