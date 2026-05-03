<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.7 Logical operators and grouping

Inside `[[ ]]`, logical operators combine sub-expressions to form
compound conditions.

- `! expr` — negation.
- `expr1 && expr2` — short-circuit AND (skip `expr2` if `expr1`
  is false).
- `expr1 || expr2` — short-circuit OR (skip `expr2` if `expr1`
  is true).
- `( expr )` — grouping (parentheses must be inside `[[ ]]` to
  serve as grouping rather than as subshell delimiters).
- Precedence: `!` binds tightest, then `&&`, then `||`. Use
  parentheses when in any doubt.

These are *internal* operators of `[[ ]]`. Outside `[[ ]]`, the
same `&&`/`||` symbols sequence whole commands (§7.10) and have
*lower* precedence than most readers expect. The two contexts must
not be conflated.

### Combined-test example

Most BCS guard expressions need two or three checks chained with
short-circuit logic. The canonical case is "file exists, is
readable, and is non-empty before parsing":

```bash
# scenario: validate a config file in one expression.
#!/usr/bin/env bash
set -euo pipefail

config="$1"

if [[ -f $config && -r $config && -s $config ]]; then
  source "$config"                             # safe: exists, readable, non-empty (BCS0501)
else
  >&2 echo "config $config is missing, unreadable, or empty"
  exit 3
fi

# precedence demonstration: !, && and || combined.
# wrong: ambiguous to a human reader, even though bash parses it correctly.
if [[ ! -d $dir && -w $dir || $force == 1 ]]; then :; fi

# right: parenthesise so intent is unambiguous (BCS0303).
if [[ ( ! -d $dir && -w $dir ) || $force == 1 ]]; then :; fi

#fin
```

The parenthesised form survives later edits — adding a third clause
will not silently re-associate the existing two.

**See also**: §7.10 `&&` and `||` short-circuits (the *outside* of
`[[ ]]` form), §8.1 `[[ ]]` overview, §8.8 quoting rules inside
`[[ ]]`, BCS0303 (quoting in conditionals), BCS0501 (conditionals).

#fin
