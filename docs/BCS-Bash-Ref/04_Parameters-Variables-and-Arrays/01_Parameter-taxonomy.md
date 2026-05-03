<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.1 Parameter taxonomy

Bash uses one umbrella term — *parameter* — for every named storage
slot the shell can substitute into a word. The taxonomy below is the
mental model the rest of Part IV assumes; every later chapter
specialises one branch of this tree.

### The three classes

```text
parameter
├── positional        $0 $1 … $N   $#   "$@"   "$*"   set --, shift
├── special           $? $$ $! $_ $- $0   (single-character, fixed semantics)
└── shell variable
    ├── user-defined  foo=1   declare -- foo=1   local -- foo=1
    └── shell-set     BASH_*  FUNCNAME  COMP_*  HIST*  PWD  IFS  …
```

A *positional* parameter is set by argument passing — script invocation,
function call, or `set --` (§4.2). A *special* parameter has a
single-character name and a fixed meaning carried by Bash itself
(§4.3, Appendix B). A *shell variable* has a user-readable name and is
set by the user, by Bash, or by the environment via `export` (§4.4,
§4.8, Appendix C). Every parameter lives in exactly one bucket.

### One example per class

```bash
# scenario: a single function exercising all three taxonomy branches
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

inspect() {
  # positional: $1, $#, "$@"
  printf 'argc=%d first=%s\n' "$#" "${1:-<none>}"

  # special: $? from the previous command, $$ for the script PID
  true; printf 'exit=%d  pid=%d\n' "$?" "$$"

  # shell variable (user-defined, function-local — §4.6)
  local -- mood='cheerful'
  printf 'mood=%s\n' "$mood"

  # shell variable (Bash-set — Appendix C)
  printf 'BASH_VERSION=%s\n' "$BASH_VERSION"
}

inspect alpha beta
# ⇒ argc=2 first=alpha
# ⇒ exit=0  pid=…
# ⇒ mood=cheerful
# ⇒ BASH_VERSION=5.2.x
```

### Environment versus shell variables

Every shell variable is also an *environment* variable when (and only
when) it carries the export attribute (BCS0204). Marking a variable
exported (`declare -x`, `export`, or assignment-prefix) places it in
the environment passed to child processes; without the attribute the
variable is private to the current shell. Treated in detail in §4.8.

### BCS posture

- Use `declare`/`local` with explicit type flags for every variable
  (BCS0201). Names: `lower_case` for locals, `UPPER_CASE` for globals
  and exports (BCS0203).
- Special parameters are read-only inputs from Bash; never reassign
  `$?`, `$$`, etc.
- Positional forwarding is always `"$@"`, never bare `$@` or `$*`
  (BCS0301).

The full canonical list of special parameters lives in **Appendix B**;
the canonical list of Bash-set shell variables lives in **Appendix C**.

**See also**: §4.2 (positional), §4.3 (special), §4.4 (shell
variables), §4.8 (export and environment), §5.4 (parameter expansion).

#fin
