<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.6 Recursion and `FUNCNEST`

Bash functions may call themselves, but the call stack is bounded
and there is no tail-call optimisation. Bash provides one explicit
hook — the `FUNCNEST` variable — for capping recursion before the
process runs out of memory.

- Default `FUNCNEST` is 0 (no limit) — but the practical limit is
  in the 5000–10000 frames range, dependent on per-frame size and
  available memory.
- `FUNCNEST=N` sets a hard cap; exceeding it returns 1 from the
  recursive call **and** prints
  `bash: <fn>: maximum function nesting level exceeded (N)`.
- Common use cases for recursion: directory tree walking,
  depth-first search, parser-style descent over nested data.
- Tail-call optimisation: not performed; deeply recursive code will
  hit memory limits long before reaching `FUNCNEST` if uncapped.
- Pitfalls: recursion under `set -e` plus a failed base case can
  produce confusing exit chains where the wrong frame appears to
  fail.
- The call stack is visible at any frame via `FUNCNAME[]` and
  `BASH_LINENO[]` (§9.11).

### Recursive tree-walk with `FUNCNEST` cap

A capped recursive walker is the canonical demonstration. The cap
turns a runaway recursion (broken base case, symlink loop) into a
diagnosable error rather than a silent OOM kill.

```bash
# scenario: depth-first directory walk with FUNCNEST safety cap.
#!/usr/bin/env bash
set -euo pipefail

declare -i FUNCNEST=128                        # cap depth: refuse to recurse > 128 (BCS0410)

walk_tree() {
  local -- dir="$1"
  local -- entry
  for entry in "$dir"/*; do
    [[ -e $entry ]] || continue                # nullglob would also work
    if [[ -d $entry && ! -L $entry ]]; then    # avoid symlink loops
      printf 'DIR  %s\n' "$entry"
      walk_tree "$entry"                       # recurse
    else
      printf 'FILE %s\n' "$entry"
    fi
  done
}

walk_tree "${1:-.}"                             # demo: walk argument or cwd

#fin
```

If the tree happens to contain a symlink loop and the `! -L` guard
is removed, the recursion will eventually hit `FUNCNEST=128` and
bash will print the clear `maximum function nesting level exceeded`
error rather than swap-thrashing the host. The cap is therefore both
a correctness check (catches missing base-case) and an operational
safeguard.

For non-trivial recursion in production scripts, BCS0410 recommends
explicitly setting `FUNCNEST` even when no obvious loop is possible
— the cost is one variable assignment, the benefit is bounded
worst-case behaviour.

**See also**: §9.3 `local` and scope, §9.11 self-locating with
`BASH_SOURCE`, §9.12 calling-convention discipline, §13.x errexit
interaction (recursion plus `set -e` corner cases), BCS0410
(recursive function state discipline), BCS0411 (subshell return-value
patterns).

#fin
