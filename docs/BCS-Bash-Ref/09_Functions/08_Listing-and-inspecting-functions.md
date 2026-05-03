<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.8 Listing and inspecting functions

Bash provides several builtins for function introspection — useful
for debugging, completion, and meta-programming.

- `declare -F` — list all defined function names.
- `declare -F funcname` — show the name (and source line if
  `extdebug` is on).
- `declare -f` — show all function definitions with bodies.
- `declare -f funcname` — show one function's body.
- `type -t funcname` — returns `function` for a function;
  empty/non-zero otherwise.
- `compgen -A function` — list function names as completion
  candidates.
- `compgen -A function -X '!my*'` — filter by prefix glob (the
  `!` inverts the match).

### `extdebug` for source-line attribution

`shopt -s extdebug` upgrades `declare -F funcname` from "just the
name" to "name, line number, source file" — the only practical way
to find *where* a sourced library defined a particular function
when you have many libraries on PATH.

```bash
# scenario: locate every function that came from a sourced library.
#!/usr/bin/env bash
set -euo pipefail
shopt -s extdebug                              # turn on source attribution

# Define a couple of local functions, then source a library.
greet()    { printf 'hello, %s\n' "$1"; }
farewell() { printf 'goodbye, %s\n' "$1"; }
source ./mylib.sh                              # adds mylib::upper, mylib::lower

# extdebug ON: declare -F prints "name lineno path" for each function.
declare -F greet                               # ⇒ greet 5 /tmp/demo.sh
declare -F mylib::upper                        # ⇒ mylib::upper 12 /tmp/mylib.sh (BCS0407)

# without extdebug, the same calls would print just "declare -f greet"

# bulk inspection of namespaced API (here, every mylib::* function):
declare -F | awk '{print $3}' | grep -E '^mylib::'

#fin
```

`extdebug` is also a prerequisite for some completion helpers
(`_init_completion`, §18.10) and for `caller` to report meaningful
function-call sites.

**See also**: §9.7 function tracing (`-T`/`-E` interaction with
`extdebug`), §9.10 naming conventions (`declare -F` filtering by
prefix), §18.8 programmable completion (`compgen -A function`),
§13.8 the ERR trap (using `caller`/`extdebug` for stack walks),
BCS0407 (library patterns), BCS0203 (naming conventions).

#fin
