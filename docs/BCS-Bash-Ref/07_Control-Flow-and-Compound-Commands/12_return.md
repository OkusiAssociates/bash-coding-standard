<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.12 `return`

`return` exits the current function or sourced file with a status
code; control passes back to the caller as if the function or
`source` had completed normally.

- `return [N]` — `N` defaults to the status of the last command.
- `N` is taken modulo 256, then masked to 0–255; values outside that
  range wrap (e.g. `return 300` yields status 44).
- `return` outside a function: in a sourced script it terminates
  *sourcing*; outside both, bash prints `return: can only `return'
  from a function or sourced script` and yields status 1.
- Distinct from `exit`: `return` leaves the calling shell running.

### Strict-mode framing

Under `set -euo pipefail`, every function that fails to set an
explicit return path will inherit the status of its last command.
For most BCS functions this is the correct behaviour; for predicate
functions (those whose role is to answer yes/no), the explicit form
is clearer and survives later edits.

```bash
# scenario: explicit return paths in a strict-mode predicate.
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

is_lower_case() {
  local -- s="${1:?usage: is_lower_case STRING}"
  [[ $s =~ ^[[:lower:]]+$ ]] || return 1       # explicit failure code
  return 0                                     # explicit success code (BCS0501)
}

if is_lower_case 'hello'; then
  echo 'lower'                                 # ⇒ lower
fi

#fin
```

### `return` from a sourced file

This is the **only** safe way for a library to abort loading. `exit`
inside a sourced file kills the caller's shell, which, if the caller
is an interactive bash, is rude in the extreme.

```bash
# scenario: a sourced library aborts cleanly when a prerequisite is missing.
# --- /usr/local/lib/myapp/db.sh (the library) ---
[[ -n ${MYSQL_PWD:-} ]] || {
  >&2 echo 'db.sh: MYSQL_PWD not set; library not loaded'
  return 1                                     # ⇒ caller sees source failure, shell stays alive
}

# --- caller ---
if ! source /usr/local/lib/myapp/db.sh; then
  echo 'continuing without db support'         # caller decides what to do (BCS0407)
fi
```

The reverse — using `return` outside a function and outside a
sourced file — is a hard error: bash refuses and the shell continues
with status 1. Always make sure you know which scope you are in.

**See also**: §7.13 `exit`, §10.1 `source` semantics, §13.x
`errexit` exemption matrix, §9.4 return value via `return N`,
BCS0407 (library patterns), BCS0602 (exit codes).

#fin
