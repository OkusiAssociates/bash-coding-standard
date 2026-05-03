<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.4 Default-value patterns

Defaulting a variable in bash is one of those tasks where four near-identical
forms exist and the differences only matter when you are debugging a script
in production at three in the morning. Pick the form that matches what you
actually want to happen to the variable; resist the urge to swap them
mechanically.

The four forms differ on two axes: do they trigger when the variable is
*unset* only, or *unset-or-empty*? And do they assign back into the variable,
or just substitute a value at the point of use? Pick by reading both columns:

| Form | Triggers on unset | Triggers on empty | Assigns to VAR |
|------|-------------------|-------------------|----------------|
| `${VAR-default}` | yes | no | no |
| `${VAR:-default}` | yes | yes | no |
| `${VAR=default}` | yes | no | yes |
| `${VAR:=default}` | yes | yes | yes |

The colon variants treat an empty string as "needs defaulting"; the colonless
variants accept the empty string as a deliberate choice and leave it alone.
The `=` variants mutate the variable in place; the `-` variants substitute
once and discard the default. None of the four export anything to the
environment — that still requires `export VAR` or `declare -x VAR`.

```bash
# scenario: defaulting a config value that may be unset OR deliberately empty
declare -- log_level=${LOG_LEVEL:-info}    # local copy, "info" if missing/empty

# scenario: assigning a default the rest of the function can rely on
: "${CACHE_DIR:=$HOME/.cache/myapp}"        # mutates CACHE_DIR; reuses everywhere

# scenario: distinguishing "user set FLAG=" from "user didn't set FLAG"
declare -- flag=${FLAG-unset}               # "unset" only when truly unset

# scenario: BCS-canonical declaration with default at top of script (BCS0105)
declare -i VERBOSE=${VERBOSE:-1}            # respects env override; falls back
declare -- CONFIG=${CONFIG:-/etc/myapp.conf}
```

The `:` form (`: "${VAR:=default}"`) deserves a closer look. The colon command
is a no-op that consumes its arguments without doing anything, so the only
purpose of the line is the side effect of the parameter expansion: assign the
default if needed, evaluate to the final value, then discard the value. This
is the idiom for "guarantee VAR has a value before I touch it." Without the
leading `:`, `"${VAR:=default}"` would be executed as a command and bash would
try to run a program named after the variable's value.

```bash
# wrong — runs $CACHE_DIR as if it were a command
"${CACHE_DIR:=$HOME/.cache/myapp}"
# ⇒ "myapp: command not found" (or worse, runs an attacker-chosen file)

# right — `:` swallows the value, side effect remains
: "${CACHE_DIR:=$HOME/.cache/myapp}"
```

A subtler trap: `${VAR:=default}` does not work on positional parameters or
read-only variables. `${1:=default}` is a syntax error; use `set -- "${1:-default}"`
instead. And `declare -r VAR=…` creates a read-only variable that subsequent
`:=` assignments will refuse with an error under `set -e`.

**See also**: §13.3 (parameter expansion) for the full grammar of `${…}` forms;
§22.5 (lazy initialisation) for the broader pattern when defaulting requires a
function call; BCS0105 (global variables) and BCS0204 (constants) for the
declare-with-default discipline at the top of a BCS-compliant script.

#fin
