<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.9 Arithmetic context `(( ))`

`(( expression ))` evaluates *expression* as integer arithmetic and returns 0 (true) when the result is non-zero, 1 (false) when zero. It is a *compound command*, not a substitution: it produces no stdout. Use `$(( ))` (§5.5) when you want the *value* as a string.

### Properties

- Variables are referenced without `$` inside `(( ))` — `count`, not `$count`. The `$` is harmless but redundant; omitting it makes the arithmetic intent obvious.
- Integer-only; bash has no native floating-point. For decimals, shell out to `bc -l` or `awk` (see §8.12).
- Idiomatic truthiness: `((count))` reads as "count is non-zero" and is preferred over `((count > 0))` per BCS0501.
- Side-effecting form: `((count += 1))` updates the variable and returns the new value's truthiness.

### Idiomatic use

```bash
# scenario: arithmetic as a condition — clean and idiomatic.
declare -i n=3
if ((n)); then echo 'non-zero'; fi   # ⇒ non-zero
((n > 0)) && echo 'positive'         # ⇒ positive
((result = 7 * n))                   # update; no $ needed
echo "$result"                       # ⇒ 21
```

Note the deliberate absence of `$` on the left of `=`: inside `(( ))`, `result = 7 * n` is an assignment expression, semantically identical to `result=$((7 * n))` but without the substitution-and-quoting overhead.

### The errexit pitfall

The interaction between `(( ))` and `set -e` is the most-cited bash gotcha for a reason: it is silent. `((count++))` evaluates to the *pre-increment* value of `count`. When `count` starts at 0, the expression returns 0, `(( ))` exits non-zero, and `set -e` kills the script — but the variable still gets incremented before the exit, so a post-mortem inspection shows `count=1` and the bug looks like it can't have happened.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
declare -i count=0
((count++))                          # post-increment returns OLD value: 0 ⇒ false ⇒ exit
echo 'unreachable under set -e'      # ⇒ never prints; exit code 1
```

The same trap applies to `((--count))` whenever the result is zero, to `((flag = 0))` when used as a statement, and to any `(( ))` whose final value happens to be zero. The exemption matrix in §13.3 lists the (narrow) contexts where this exit doesn't fire — but relying on those exemptions is brittle.

The fix is unambiguous: use `+=`, which is a plain assignment with no return-value pitfall. BCS0505 makes this a hard rule.

```bash
# correct
declare -i count=0
count+=1                             # always safe; no truthiness games
count+=2                             # increments work the same way
((count))                            # use the value separately if you need it
```

For a counter you want to test *and* update in one step, write the test first: `((count > 0)) && count+=1` makes the intent explicit, and the `&&` short-circuit is unaffected by the value of `count` after the increment.

**See also**: §5.5 (`$(( ))` substitution), §13.3 (errexit exemption matrix), §8.13 (`let`), §8.10 (operators), BCS0501, BCS0505.

#fin
