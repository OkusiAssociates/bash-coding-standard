<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.13 `let` builtin

`let` evaluates each of its arguments as an arithmetic expression
and returns failure (status 1) if the value of the **last**
expression is zero. Older idiom; modern code uses `(( ))` (§8.9)
for the same semantics with cleaner quoting.

- `let x=5 y=10 z=x+y` — multiple assignments in one call.
- `let "x = 5"` — quoting required when the expression contains spaces.
- Returns 1 if the last expression evaluates to zero, even when
  every assignment succeeded — same way `(( x=0 ))` returns 1.
- Use `(( ))` instead in modern code; `let` is older and fiddlier.

### The last-expression-zero exit-status trap

The trap that bites every script under `set -e` is that a *successful*
arithmetic operation whose final result is zero is *itself* a failure
return — and errexit then trips. This is identical to the `((var++))`
trap (§8.9) but is even more surprising in `let` form because the
syntax is "command-like" rather than expression-like.

```bash
# scenario: a perfectly valid let assignment kills the script under set -e.
#!/usr/bin/env bash
set -euo pipefail

# wrong: let returns 1 because the LAST expression evaluates to 0,
# even though the assignments all succeeded. set -e fires.
process_record() {
  local -i count=0
  let count=count+0                            # count is 0; let returns 1; script exits (BCS0601)
  echo "count is $count"                       # never reached
}

# right: use (( )) and add `|| :` if zero is a normal result.
process_record_safe() {
  local -i count=0
  (( count = count + 0 )) || :                 # explicit suppression (BCS0605)
  echo "count is $count"                       # ⇒ count is 0
}

process_record_safe

#fin
```

The rule: any arithmetic *expression* whose value can become zero
must be paired with an explicit success guard under errexit, or
re-cast as a plain assignment. The simplest guard is `|| :`. This is
a high-frequency strict-mode landmine alongside `((count++))` and
`read` at end-of-file.

**See also**: §8.9 arithmetic context, §8.10 arithmetic operators
and precedence, §13.3 errexit exemption matrix, §5.5 arithmetic
expansion, BCS0505 (arithmetic operations), BCS0601 (exit on error),
BCS0605 (error suppression).

#fin
