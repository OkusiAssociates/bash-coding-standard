<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.1 `source` semantics

`source file` (POSIX alias `.`) executes `file` in the *current*
shell's environment. Every variable assignment, function definition,
trap installation, alias, and shell-option toggle made by the sourced
file persists in the caller after sourcing returns. This is the
mechanism that makes bash libraries possible: the library file is a
script that, when sourced, populates the caller's namespace.

This chapter is the **canonical owner** of the strict-mode
propagation, `return`-versus-`exit` asymmetry, and Greg-canonical
sourcing-idiom material. Other chapters (e.g. §10.4 on idempotent
guards, §10.3 on self-location) reference this chapter rather than
restating it.

### The basic mechanics

| Property | Behaviour |
|----------|-----------|
| Aliases | `.` (POSIX) and `source` (bash). Identical effect. |
| Path search | If the filename contains no `/`, bash searches `$PATH`. With a slash (relative or absolute), the path is used verbatim. |
| Executable bit | Not required. The file is read, not exec'd. |
| Persistence | All shell-state changes (variables, functions, traps, aliases, `shopt`) survive sourcing. |
| Arguments | `source file arg1 arg2` sets the file's positional parameters during sourcing; the caller's `$@` is restored on return. |

### Strict-mode propagation: the `set -e` trap

The single most under-documented fact about `source` is that the
sourced file inherits the caller's strict-mode flags. `set -e` is
*on* inside the sourced file if the caller has it on; a non-zero
status from any unchecked simple command in the sourced file will
exit the *caller's* shell.

```bash
# scenario: set -e in the caller propagates into the sourced file
# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail
echo 'before source'
source ./lib.sh
echo 'after source'                     # unreachable

# --- lib.sh ---
echo 'inside lib'
false                                   # ⇒ caller exits here, status 1
echo 'lib continued'                    # never executed
```

The mistake is to write a library assuming "errors will be silent
because I am only being sourced." Under strict mode they are
emphatically not silent. Library authors must therefore either
(a) audit every command for failure modes, or (b) wrap risky
sections with `|| true` / `|| return N` to inspect the status
explicitly.

### `return` versus `exit` inside a sourced file

The two commands mean different things and mixing them is a
landmine. `return` at the top level of a sourced file terminates
*sourcing* and hands control back to the caller — the caller's shell
keeps running. `exit` ends the *caller's* shell entirely, regardless
of how deeply nested the sourcing is.

```bash
# scenario: return vs exit asymmetry in a sourced file
# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail
source ./lib.sh                         # see two variants below
echo 'caller continues'                 # only printed for the return-form

# --- lib.sh — variant A: return ---
echo 'lib starting'
[[ -r /etc/myapp.conf ]] || return 0    # ⇒ caller prints "caller continues"
echo 'lib loaded conf'

# --- lib.sh — variant B: exit ---
echo 'lib starting'
[[ -r /etc/myapp.conf ]] || exit 0      # ⇒ caller's shell exits, "caller continues" never printed
echo 'lib loaded conf'
```

The rule of thumb: **`return` from a sourced file, never `exit`**,
unless the library has detected a state so corrupt that the caller
*must* be terminated. The 1-line guard `return 0` is harmless;
`exit 0` from a library kills any interactive shell that happened to
source it for autocompletion. Library authors who follow this
convention can safely be sourced from `~/.bashrc`.

### The Greg-canonical sourcing idiom

The pattern below is the bash community's accepted shape for a
library file. It combines an idempotent re-source guard, a strict-mode
propagation acknowledgement, the function-prefix namespace
convention (§10.5), and a `return`-not-`exit` discipline. Every BCS
library should match this skeleton.

```bash
# scenario: full library skeleton — idempotent, strict-mode-aware, return-discipline
# /usr/local/lib/myapp/strings.sh
#!/usr/bin/env bash
# strings.sh — string utilities for myapp.

# Reject direct execution: this file is meant to be sourced.
[[ ${BASH_SOURCE[0]} != "$0" ]] || {
  >&2 echo "Error: ${BASH_SOURCE[0]} must be sourced, not executed"
  exit 1                                # exit is correct here — we are NOT sourced
}

# Idempotent guard: re-sourcing is a no-op (§10.4).
[[ ${MYAPP_STRINGS_LOADED:-0} -eq 1 ]] && return 0
declare -gri MYAPP_STRINGS_LOADED=1     # -g because we may be inside a function (§10.8)

# Acknowledge that set -e from the caller is in force here.
# Library code must not assume the unchecked command "just continues".
# Use `|| return N` for any command whose failure should bail out of sourcing.

# --- public API (namespace-prefixed, §10.5) ---
myapp_strings_upper() {
  local -- s="${1:?usage: myapp_strings_upper STRING}"
  printf '%s' "${s^^}"
}

myapp_strings_lower() {
  local -- s="${1:?usage: myapp_strings_lower STRING}"
  printf '%s' "${s,,}"
}

# --- private helpers (single-underscore prefix, §10.6) ---
_myapp_strings_assert_nonempty() {
  [[ -n ${1:-} ]] || return 1
}

# Optional: export public functions if subshells must see them (§9.9).
# declare -fx myapp_strings_upper myapp_strings_lower

# Successful end-of-file: implicit `return 0`. Never `exit`.

#fin
```

Three notes on the skeleton. The `BASH_SOURCE[0] != "$0"` guard
correctly uses `exit` when triggered, because in that branch the
file *is* being executed directly and `return` would itself fail
("can only `return` from a function or sourced script"). The
idempotent guard uses `declare -gri` so the flag survives even when
the library is sourced for the first time *inside* a function
(§10.8). The end-of-file is bare — bash treats it as `return 0`,
which is what every successful library load should yield.

### File arguments to `source`

`source file arg1 arg2` makes `arg1`, `arg2` available as `$1`, `$2`
during the file's execution. The caller's positional parameters are
restored when sourcing returns. This mechanism is occasionally useful
for plugin-style libraries that want a configuration token without
introducing a global.

```bash
# scenario: positional parameters during sourcing
# --- plugin.sh ---
echo "plugin called with: $1"

# --- caller.bash ---
set -- one two three
source ./plugin.sh foo                  # plugin sees $1=foo
echo "caller still has: $1"             # ⇒ caller still has: one
```

The pattern is rare in BCS code; configuration is usually carried in
environment variables to avoid the implicit ordering contract.

**See also**: §10.2 (`BASH_SOURCE` array detail), §10.3
(self-locating library pattern), §10.4 (idempotent guards), §10.5
(namespace prefixes), §10.8 (lazy loading and `declare -g`), §9.9
(exporting functions), §13.2 (`set -e` semantics), BCS0101 (strict
mode), BCS0407 (library patterns), BCS-bash
`30_02_dot-source.md`.

#fin
