<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.10 Quote removal

The implicit final phase of the expansion pipeline (§5.1). After
phases 1–8 have run, Bash strips the *user-supplied* quoting
characters — `\`, `'`, `"` — leaving only the bytes that should reach
`execve`. Quote characters introduced by an *expansion* (e.g. a
backslash that came from the value of a variable) are **not**
removed: they have already been "promoted" to data.

This rule is short by intent. The single most-asked question — "why
does my variable's backslash survive?" — is answered by one example.

### The user-versus-expansion rule

```bash
# scenario: backslash from user quoting versus from expansion
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# User-supplied backslash inside a double-quoted word — REMOVED at phase 9
echo "a\\b"                         # ⇒ a\b   (the literal '\\' is one '\')
echo "a\b"                          # ⇒ a\b   (\b is not a recognised escape)

# Backslash from a $'...' ANSI-C value — DATA, not user quoting
declare -- var=$'a\\b'              # value is exactly: a, \, b   (3 bytes)
echo "$var"                         # ⇒ a\b   (backslash survives)
printf '%d\n' "${#var}"             # ⇒ 3

# Backslash inside a plain assignment — not an escape, just a byte
declare -- raw='a\b'                # value is exactly: a, \, b
echo "$raw"                         # ⇒ a\b
echo "${raw//\\/-}"                 # ⇒ a-b   (replace literal \ with -)
```

The principle: phase 9 fires once, at the end, against the result of
the prior phases. By that point the expanded value is *bytes*. Bash
does not re-parse those bytes for quoting.

### What gets removed

- Unquoted backslashes preceding a metacharacter (used to escape).
- Pairs of single-quotes wrapping a literal segment.
- Pairs of double-quotes wrapping an interpolated segment.
- The leading `$` of `$'…'` ANSI-C strings (the `\…` sequences inside
  having already been resolved when the token was scanned).
- The leading `$` of `$"…"` locale-translatable strings (rare).

### What is left behind

Anything that came **out of** an expansion: variable contents,
command-substitution output, the textual result of arithmetic, the
result of brace expansion. None of these is re-quoted; none is
re-scanned.

### Practical consequence

```bash
# scenario: a value containing $(...) does NOT execute the substitution
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- payload='$(rm -rf $HOME)'
echo "$payload"
# ⇒ $(rm -rf $HOME)   — literal, never executed
# (phase 5 ran before $payload existed in this word; the bytes are inert)

# Beware `eval` — that *would* re-scan and execute (BCS1004):
# eval "$payload"     # ✗ DO NOT — full BCS1004 violation
```

This is why `eval` is a BCS0307/BCS1004 anti-pattern: it forces a
*second* parsing pass over already-expanded data, restoring every
phase from 1 to 9 against bytes that were meant to be inert.

### BCS posture

- Quote variable references in word context (BCS0301). Quote removal
  then leaves your value intact.
- Treat `eval` as a security-critical construct (BCS1004); never `eval`
  a value derived from user input or filesystem data (BCS1005).
- For substitution-like patterns over data, prefer `${var/pattern/repl}`
  (§5.4) — it never re-parses the value as code.

**See also**: §5.1 (expansion order), §3.5 (single-quotes — what
gets stripped), §3.6 (double-quotes), §3.7 (`$'…'` ANSI-C strings),
§5.4 (`${var/...}` rewrite).

#fin
