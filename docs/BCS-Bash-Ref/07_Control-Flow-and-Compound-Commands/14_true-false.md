<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.14 `:`, `true`, `false`

Three commands that exist primarily to satisfy syntax requirements
(a slot in the grammar that demands a *command*, where any non-zero
or zero status will do).

- `:` — null command, returns 0. A *special* builtin: faster than
  `true` because it does no argument processing and cannot be
  shadowed.
- `true` — returns 0. Regular builtin.
- `false` — returns 1. Regular builtin.
- Use cases: empty body of a control structure (`while :; do …;
  done`), forcing success in the `cmd ||:` idiom, infinite loops,
  *and* the side-effecting parameter-expansion idiom below.
- `: ${VAR:=default}` — evaluate parameter expansion for its
  side effect (assigning a default), discarding the value.

### The `: ${VAR:=default}` idiom

`${VAR:=default}` not only *expands to* `default` when `VAR` is
unset/empty but also *assigns* `default` to `VAR` as a side effect.
Pairing it with `:` discards the expansion result while keeping the
assignment — a one-line "set if not set" pattern.

```bash
# scenario: provide configurable defaults at the top of a script
# without overriding any value already set in the environment.
#!/usr/bin/env bash
set -euo pipefail

: "${LOG_LEVEL:=info}"                         # default 'info' if unset (BCS0204)
: "${CACHE_DIR:=$HOME/.cache/myapp}"
: "${TIMEOUT:=30}"

printf 'LOG_LEVEL=%s\nCACHE_DIR=%s\nTIMEOUT=%s\n' \
  "$LOG_LEVEL" "$CACHE_DIR" "$TIMEOUT"

#fin
```

Run it bare:

```
LOG_LEVEL=info
CACHE_DIR=/home/user/.cache/myapp
TIMEOUT=30
```

Run it with `LOG_LEVEL=debug TIMEOUT=60 ./script` and only those two
get overridden — the assignment happens *only* when the variable is
unset or empty.

The single colon is essential: `${VAR:=default}` on its own line
without a leading command is not valid syntax (bash sees the
expansion as a command and tries to execute the value). `:` provides
the command slot and ignores the expanded text. Quoting the whole
right-hand side (as above) is BCS practice (BCS0301) — it preserves
spaces in defaults like `${MSG:=hello world}`.

**See also**: §5.4 parameter expansion (the `${VAR:=word}` form),
§13.4 checking return values (the `cmd || :` suppression idiom),
BCS0204 (constants and environment variables), BCS0301 (quoting
fundamentals), BCS0605 (error suppression).

#fin
