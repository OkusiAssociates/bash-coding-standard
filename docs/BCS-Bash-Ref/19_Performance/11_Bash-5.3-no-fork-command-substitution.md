<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.11 Bash 5.3 no-fork command substitution

`${ command; }` runs command in the current shell, no fork.

- Bash 5.3+ only.
- Same syntax as parameter expansion but with `cmd; }`.
- Captures stdout into the substitution result without spawning a subshell.
- Saves the ~1 ms subshell cost per call.
- Caveat: command runs in current shell, so variable changes persist (a feature for some uses, a bug for others).
- Not yet portable; use only if you can require Bash 5.3+.

```bash
# scenario: contrast variable-leak side-effect
counter=0

# classic — subshell isolates side-effects
result=$(counter=99; printf '%s\n' "hit")
printf 'classic: result=%s counter=%s\n' "$result" "$counter"
# ⇒ classic: result=hit counter=0

# bash 5.3+ — no fork, side-effects leak into caller
# (the snippet below is only legal under bash 5.3+; under 5.2 it is a
#  syntax error, so it is illustrated as a comment rather than executed.)
#   result=${ counter=99; printf '%s\n' "hit"; }
#   printf 'no-fork: result=%s counter=%s\n' "$result" "$counter"
#   → "no-fork: result=hit counter=99"
```

The performance win is real (~1 ms per call), but the variable-leak
behaviour means you cannot use `${ … }` as a drop-in replacement for
`$( … )`. Reserve it for hot loops where you control all assignments
inside the block, and document the choice next to the call site.

**See also**: §19.1 (cost model), §13.04 (command substitution), §25 (Bash 5.3 future).

#fin
