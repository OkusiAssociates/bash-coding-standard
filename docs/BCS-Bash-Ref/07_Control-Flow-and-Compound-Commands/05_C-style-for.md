<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.5 C-style `for ((;;))`

A numeric loop with arithmetic context, modelled on C's `for`
statement. Use it when the loop variable is a counter — index into an
array, repeat-N-times, walk a half-open range — rather than a
membership iteration over a list (use `for x in …` for the latter,
§7.4).

### Syntax

```
for (( init; cond; update )); do list; done
```

All three expressions are *arithmetic* — the same context used by
`(( … ))` and `$(( … ))`. Variables are referenced bare, without `$`;
unset variables expand to `0` rather than the empty string. Empty
expressions are legal: `for ((;;))` is the canonical infinite loop.

### Indexed array iteration

```bash
# scenario: index walk over an array (when the index itself matters)
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -ar items=(alpha beta gamma delta)
declare -i i

for ((i=0; i<${#items[@]}; i++)); do
  printf '%d: %s\n' "$i" "${items[i]}"
done
# ⇒ 0: alpha
# ⇒ 1: beta
# ⇒ 2: gamma
# ⇒ 3: delta
```

Note the bare `i` inside `${items[i]}`: array subscripts are an
arithmetic context, so `${items[$i]}` is a redundant `$`-expansion
that costs a parse round and gains nothing (BCS0207, BCS0505). For
membership iteration without the index, the `for x in "${items[@]}"`
form is shorter and clearer; pick the C-style form only when the index
is actually used.

For *sparse* arrays (after `unset 'arr[3]'`), the range `0..${#arr[@]}-1`
is wrong: `${#arr[@]}` counts elements, not the maximum index. Iterate
`"${!arr[@]}"` instead (§7.4).

### Infinite loop with break

The empty-condition form is the standard event loop:

```bash
# scenario: wait for a condition, polling once per second
declare -i tries=0

for ((;;)); do
  if check_ready; then
    info 'ready'
    break
  fi
  tries+=1
  ((tries >= 30)) && die 24 'timed out after 30s'
  sleep 1
done
```

`for ((;;))` is identical in effect to `while :;` and `while true;`;
all three are idiomatic. Pick the one that reads best in context — the
arithmetic-loop form is conventional when an explicit counter
participates in the termination condition, the `while true` form when
the body is the focus.

### Strict-mode and errexit interaction

`(( … ))` returns `0` if the expression evaluates non-zero, and `1` if
it evaluates to zero. Under `set -e` this means a *standalone*
arithmetic statement that evaluates to zero terminates the script:

```bash
# wrong — errexit fires when count reaches zero
declare -i count=3
((count--))                          # 3→2 fine, 2→1 fine
((count--))                          # 1→0: status is 1, errexit aborts
```

Inside the C-style `for`'s `update` slot the issue does not arise —
the update expression's status is not propagated as the construct's
status — but watch for it in regular code. The standard mitigations
are `count+=-1` (assignment statement, always returns `0`) or
`((count--)) || true` (BCS0505, BCS0601).

**See also**: §7.4 (`for x in list` for membership iteration), §7.6
(`while`/`until` for condition-driven loops), §8.4 (arithmetic
evaluation), BCS0207, BCS0505, BCS0601.

#fin
