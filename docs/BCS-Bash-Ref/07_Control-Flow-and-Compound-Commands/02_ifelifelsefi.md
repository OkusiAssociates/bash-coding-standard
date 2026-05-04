<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.2 `if`/`elif`/`else`/`fi`

The conditional. The bash `if` is not a boolean test — it is a dispatcher
on *exit status*. Any command can serve as the condition; the branch
runs when that command's status is `0`. This is the single most
important fact about bash conditionals and the source of the
`if [[ … ]]` idiom: `[[ ]]` is just a builtin that exits `0` or `1`.

### Syntax

```
if list; then list; [elif list; then list;] … [else list;] fi
```

The condition is the exit status of the *last command* in the `if`
list, not the conjoined status of the whole list. This matters when the
`if`-list is itself an AND-OR chain (§7.10).

- `if [[ … ]]; then …; fi` — conditional-expression idiom.
- `if cmd; then …; fi` — exit-status idiom; equally valid.
- `if ! cmd; then …; fi` — negate the test.
- `if cond; then act; fi` — one-line form.
- An empty branch body must contain at least `:` (the null command);
  bash parses `if cond; then; fi` as a syntax error.

### Canonical forms

```bash
# scenario: dispatch on conditional expression
if [[ -f $config ]]; then
  source -- "$config"                # ⇒ runs when file exists
elif [[ -f $fallback ]]; then
  source -- "$fallback"
else
  warn 'no config found'
fi
```

```bash
# scenario: dispatch on command exit status (no [[ ]] needed)
if grep -q 'pattern' "$file"; then
  info 'matched'                     # ⇒ runs when grep exits 0
else
  info 'no match'                    # ⇒ runs when grep exits 1
fi
```

The second form is preferred whenever the condition *is* a command;
wrapping a command in `[[ -n $(cmd) ]]` is a code smell (BCS0303,
BCS0501). The exit-status form is faster (no command substitution),
clearer, and supports `! cmd` for negation.

### Errexit interaction (the exemption)

A command in an `if` condition is exempt from `set -e`. This is the
most-asked question about errexit: "why doesn't my script die when the
condition fails?" — because if it did, `if grep -q …; then` would
abort the script every time the pattern was absent. The exemption
applies to the *whole condition list*, including pipelines and AND-OR
chains:

```bash
# scenario: errexit exempts the if-condition
set -euo pipefail
cmd_that_exits_1() { return 1; }     # placeholder for some predicate

if cmd_that_exits_1; then            # → rc=1 from the test is exempt from set -e
  echo 'success'
else
  echo 'failure'                     # ⇒ failure
fi
```

The exemption is positional, not lexical. Calling a function from an
`if` condition makes the *whole function* exempt from errexit for the
duration of the call — including its inner commands. This is the
mechanism behind the most subtle errexit footgun in bash: a helper
function that "works" until you call it standalone (§13.3, BCS0601).

### One-line forms

```bash
# scenario: short conditional on a single line
[[ $# -gt 0 ]] || die 22 'argument required'
[[ -d $dir ]] || mkdir -p -- "$dir"
```

`[[ … ]] || cmd` is an AND-OR list (§7.10), not an `if`, but it serves
the same purpose for single-action conditionals and reads more
fluently in line-noise contexts. Reach for `if`/`fi` once two or more
actions are needed in the branch — chaining with `&&` / `||` past
two clauses invites the famous misconception trap (§7.10).

**See also**: §7.3 (`case` for multi-branch dispatch), §7.10 (AND-OR
short-circuits), §8 (conditional expressions and arithmetic), §13.3
(errexit and the condition exemption), BCS0303, BCS0501.

#fin
