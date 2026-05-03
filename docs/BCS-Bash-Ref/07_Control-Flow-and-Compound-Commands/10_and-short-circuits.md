<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.10 `&&` and `||` short-circuits

AND-OR lists chain commands with conditional execution. They are the
in-line alternative to `if/fi`: `cmd1 && cmd2` runs `cmd2` only if
`cmd1` succeeded; `cmd1 || cmd2` runs `cmd2` only if `cmd1` failed.
The two operators have *equal precedence* and are *left-associative*.
This last fact is the source of the most famous trap in bash and of
the canonical interview question on this topic.

### Mechanics

- `cmd1 && cmd2` — exit status of `cmd1` decides; `cmd2` runs iff
  `cmd1` exited `0`.
- `cmd1 || cmd2` — exit status of `cmd1` decides; `cmd2` runs iff
  `cmd1` exited non-zero.
- The whole list's exit status is the status of the *last command
  actually executed*.
- The `&&`/`||` test inspects the *immediate left command's* status —
  not the cumulative status of the whole left chain.
- Errexit exemption: every left-hand position in an AND-OR list is
  exempt from `set -e` (§13.3); only the *final* command's status is
  observed by errexit.

### Common one-liners

```bash
# scenario: conditional action without an if-block
[[ -d $dir ]] || mkdir -p -- "$dir"          # create only if missing
cmd && success 'done' || warn 'failed'       # WRONG — see misconception below
cd "$dir" && rm -- *.tmp                     # cd or skip the rm
```

The first idiom is universally safe — `[[ -d … ]] || mkdir` reads as
"ensure the directory exists." The second is the misconception, dealt
with next.

### The famous misconception: `&& … ||` is not `if-then-else`

`cmd1 && cmd2 || cmd3` *looks* like `if cmd1 then cmd2 else cmd3`. It
is not. It runs `cmd3` whenever the immediate left command of `||`
fails — and the immediate left command of `||` is `cmd2` whenever
`cmd1` succeeded. So `cmd3` runs not just when `cmd1` fails, but also
when `cmd1` succeeds *and* `cmd2` then fails:

```bash
# wrong — looks like if/then/else; isn't.
[[ -f $file ]] && rm -- "$file" || warn "could not check"
# trace:
#   $file present, rm succeeds (status 0)        → no warn (correct branch)
#   $file present, rm fails    (status 1)        → warn fires (silently wrong)
#   $file absent,  warn fires                    → warn fires (intended)
```

Two of the three execution paths print `could not check` even when the
problem was a failed `rm`, not a failed test. The standard misdiagnosis
is "filesystem is glitching"; the reality is that `&&`/`||` chains do
not implement conditional dispatch.

The right tool is an `if/fi`:

```bash
# right — explicit dispatch
if [[ -f $file ]]; then
  rm -- "$file" || warn "could not remove $file"
else
  warn "no such file: $file"
fi
```

…or grouping to disambiguate the intent:

```bash
# right — group the success branch so its failure cannot trigger the failure branch
[[ -f $file ]] && { rm -- "$file"; success "removed"; } || warn "no such file"
```

The braces force `{ rm …; success …; }` to be evaluated as a single
unit; their combined status is what `||` tests. The pattern is still
fragile (`success` failing would trigger the warn), but it eliminates
the more common version of the bug. For anything more than a binary
guard, prefer `if/fi` and stop.

### Errexit and AND-OR lists

`set -e` does not abort on a failure in any non-final position of an
AND-OR list. This is by design — `cmd || handler` would be useless if
the failing `cmd` aborted the script before `handler` ran. But it
also means a long AND-OR chain hides errors:

```bash
# wrong — only failure of cmd5 is observed by errexit
cmd1 && cmd2 && cmd3 && cmd4 && cmd5
```

Failures in `cmd1`–`cmd4` short-circuit the chain (the rest do not
run), but the *script* continues — because the chain's overall status
is whatever the last *executed* command returned, and that could be a
mid-chain success that simply stopped further work. For multi-step
sequences where every step must succeed, use a `for` loop, an
explicit if-cascade, or the BCS-standard `cmd || die …` pattern at
each step (BCS0601, BCS0604).

### Idiomatic uses that *are* safe

For all the misconceptions, three AND-OR idioms remain canonical and
unproblematic:

- **Guard-and-act**: `[[ test ]] && cmd` — single action conditional
  on a test. No third branch; cannot misfire.
- **Default-on-failure**: `cmd || default` — fall back when `cmd`
  fails. Common with `||` `:` `||` `true` to suppress non-fatal
  errors (BCS0605).
- **Die-on-failure**: `cmd || die N "message"` — the BCS-standard
  error-handling pattern (BCS0601, BCS0604). The terminating `die`
  guarantees the right-hand side is the only post-failure path.

Reach for these freely. Reach for `cmd1 && cmd2 || cmd3` and similar
three-clause forms not at all.

**See also**: §7.2 (`if/elif/else/fi` — the explicit conditional),
§7.8 (`( )` for grouping with isolation), §7.9 (`{ }` for grouping
without forking), §13.3 (errexit and the AND-OR exemption), BCS0601,
BCS0604, BCS0605.

#fin
