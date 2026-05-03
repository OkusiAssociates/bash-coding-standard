<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.4 Return value via `return N`

Bash functions return an 8-bit unsigned exit status. The full
mechanics:

- `return N` — `N` is taken modulo 256, then masked to 0–255.
- `return` with no argument — returns the status of the last
  command executed in the function body.
- Default return at function end — last command's status (the same
  rule as bare `return`).
- The caller sees the function's return in `$?` after the call.
- Distinct from `exit` — `return` leaves the calling shell running
  (§7.13).
- Convention: 0 success, non-zero failure, with consistent meaning
  across the codebase (BCS0602).

### Wrap-on-256

Status codes outside 0–255 silently wrap. This is *almost always* a
bug: a function that `return 300` will surface as status 44 to its
caller, looking like a different (and possibly meaningful) failure
mode. The fix is to constrain return values at the source.

```bash
# scenario: status wrap-around — a return value outside 0–255 silently truncates.
#!/usr/bin/env bash
set -euo pipefail

returns_300() { return 300; }
returns_300 || rc=$?
echo "rc=$rc"                                  # ⇒ rc=44   (300 mod 256)

returns_minus_1() { return -1; }               # bash refuses: "return: -1: invalid option"
                                               # use 1, 255, or a documented code (BCS0602)

#fin
```

### `return` versus `exit`

The distinction is critical when functions are used as guards or
predicates. `return` ends the function; `exit` ends the entire
shell (or, inside a subshell, that subshell — see §7.13).

```bash
# scenario: a predicate that signals failure with return, not exit.
#!/usr/bin/env bash
set -euo pipefail

# wrong: exit kills the shell, even when called from an interactive context
# or from a sourced setup script.
require_root_v1() {
  [[ $EUID -eq 0 ]] || exit 13                 # bad: caller has no chance to handle
}

# right: return; caller decides what to do.
require_root_v2() {
  [[ $EUID -eq 0 ]] || return 13               # good (BCS0602)
}

if ! require_root_v2; then
  >&2 echo 'this command needs root; re-run with sudo'
  exit 13
fi

# from a sourced library, return is the only safe choice (§10.1).

#fin
```

The discipline: **functions return; scripts exit.** `exit` from
inside a function should be reserved for unrecoverable corruption
detected at the function level — and even then is suspect, because
a future caller might want to recover.

**See also**: §7.12 `return`, §7.13 `exit`, §9.5 communicating
results, §13.10 exit code conventions, §10.1 `source` semantics
(why libraries must `return`, never `exit`), BCS0602 (exit codes),
BCS0407 (library patterns).

#fin
