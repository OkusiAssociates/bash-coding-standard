<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.11 `break` and `continue`

Loop-control builtins. Both accept an optional integer `N` selecting
which enclosing loop to act on, counting outward from the innermost.

- `break [N]` — exit `N` enclosing loops (default 1).
- `continue [N]` — restart the test/header of the `N`-th enclosing
  loop (default 1).
- `N` out of range: `break: N: loop count out of range` (status 1
  under errexit will exit the shell).
- `case` is *not* a loop — `break` inside a `case` body refers to
  the nearest *enclosing* loop, not the `case` itself.
- `select` *is* a loop; `break` exits it (this is the only way to
  leave a `select` other than EOF).

### Nested-loop `break N`

The `N` argument is the only mechanism for exiting two or more loop
levels in one statement. Without it the inner loop must signal the
outer loop indirectly (a flag variable, or worse, a goto-style
re-test of the condition).

```bash
# scenario: search a 2D table; on first match, exit both loops.
declare -ra rows=('alpha beta' 'gamma delta' 'epsilon zeta')
declare -- needle='delta' found=''
for row in "${rows[@]}"; do
  for cell in $row; do
    if [[ $cell == "$needle" ]]; then
      found=$cell
      break 2                                  # ⇒ exits cell-loop AND row-loop
    fi
  done
done
printf 'found: %s\n' "${found:-none}"          # ⇒ found: delta (BCS0503)
```

Without `break 2` the inner `break` would only end the cell-loop and
the outer would continue scanning rows — usually a bug.

### `continue N`

Symmetrical: `continue 2` from within an inner loop restarts the
*outer* loop's next iteration, skipping the rest of both bodies.

```bash
# scenario: skip an entire outer iteration when an inner condition fires.
for dir in src tests docs; do
  [[ -d $dir ]] || continue                    # bare continue: next dir
  for f in "$dir"/*.bash; do
    [[ -r $f ]] || continue 2                  # ⇒ unreadable file: abandon this whole dir
    process "$f"
  done
done
```

**See also**: §7.4 `for`, §7.6 `while`/`until`, §7.7 `select`, §7.3
`case` (note: not a loop; `break` skips past it to the enclosing
loop), BCS0503 (loops), BCS0601 (errexit interaction with loop
control).

#fin
