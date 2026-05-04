<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 13.7 `||:` and `|| true` idioms

Two equivalent idioms for "I expect this command may fail and I do
not want errexit to react":

| Form | Notes |
|------|-------|
| `cmd \|\| true` | explicit, readable; preferred in production scripts |
| `cmd \|\|:`     | compact (`:` is the null builtin, returning 0) |

Both produce a final exit status of 0 for the AND-OR list, satisfying
`set -e` (§13.2). Use after individual commands whose failure does
**not** indicate a script-level error — ad-hoc cleanup that may
discover an already-removed file, optional logging that may fail under
load, etc.

```bash
# scenario: tolerated failures
[[ -f $stale ]] && rm -- "$stale" || true   # OK if file is gone
notify_optional_endpoint || true            # OK if endpoint is down
```

The discrimination test: if the failure means the script should
*continue but log it*, write `if ! cmd; then warn '...'; fi`. If the
failure means the script should *fall back to a different action*,
write a proper `if`/`else`. If the failure means *do nothing different*
— no log, no fallback — then `|| true` is the right tool.

### AND-OR list precedence — the trap

This is the single biggest pitfall with `||:`. Bash's `&&` and `||`
have **equal precedence** and associate left-to-right. The idiom
`cmd_a && cmd_b || true` does **not** mean "`cmd_b` is protected by
`|| true`"; it means "(cmd_a && cmd_b) || true" — the `|| true`
protects the whole list, not the right-hand command alone.

```bash
# scenario: AND-OR precedence trap
set -euo pipefail

# What the author probably meant:
#   "always run cmd_a; if it succeeds, also run cmd_b; tolerate failure
#    of cmd_b but not cmd_a"
# What bash does:
#   "(cmd_a && cmd_b) || true" — failure of EITHER is suppressed.

cmd_a() { echo 'a ran'; return 1; }         # this should crash the script…
cmd_b() { echo 'b ran'; return 0; }
cmd_a && cmd_b || true                      # …but it doesn't!
echo 'we get here despite cmd_a failing'    # ⇒ we get here despite cmd_a failing
```

Two ways to disambiguate:

```bash
# scenario: explicit grouping — protect cmd_b only
cmd_a && { cmd_b || true; }                 # cmd_a still subject to set -e
# Or with an if:
if cmd_a; then
  cmd_b || true                             # cmd_b is the "tolerated" one
fi
```

Use the `{ … }` group when the whole expression must remain a single
list; use `if` when readability matters. The bare `cmd_a && cmd_b ||
true` form should be considered an anti-pattern in any script with
`set -e` active.

`:` is bash's null builtin (returns 0), `true` is also a builtin in
modern bash; they are functionally equivalent. Prefer `|| true` for
readability in code junior maintainers will read.

To proceed but keep the failure visible, capture and log instead of
swallowing: `cmd; rc=$?; (( rc )) && warn "cmd failed: rc=$rc"`. This
is more verbose but documents that the failure is known about, not
silently lost.

**See also**: §13.2 (`set -e` semantics), §13.3 (errexit exemption
matrix), §13.8 (ERR trap), §13.11 (propagating exit codes),
BCS-bash `30_43_set.md`, BCS0605 (error suppression), BCS0604
(checking return values).

#fin
