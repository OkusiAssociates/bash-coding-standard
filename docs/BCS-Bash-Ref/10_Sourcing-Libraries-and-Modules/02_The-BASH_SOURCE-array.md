<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.2 The `BASH_SOURCE` array

`BASH_SOURCE` is an indexed array tracking the chain of source files
through the call stack. Together with `FUNCNAME` and `BASH_LINENO`
it gives bash its only first-class introspection of "who called
me?".

- `BASH_SOURCE[0]` — file of the *current* execution context.
- `BASH_SOURCE[N]` — file at depth N in the call stack (1 is the
  caller of the function holding 0, etc.).
- Length: `${#BASH_SOURCE[@]}` — equals `${#FUNCNAME[@]}`.
- Top-level script: `BASH_SOURCE[0]` is the script.
- Sourced library: `BASH_SOURCE[0]` is the library file.
- Function within library: `BASH_SOURCE[0]` is still the *library*
  file (the function carries its source attribution).
- Pairs with `FUNCNAME[]` (function name at each level) and
  `BASH_LINENO[]` (line number at each level). All three arrays
  are the same length.

The canonical owner of the *full* `BASH_SOURCE` anatomy is §9.11,
which uses these arrays for self-location idioms and ERR-trap stack
walks. This chapter covers the array shape; §9.11 covers the usage
patterns.

### Walk-the-stack example

The clearest way to see the relationship between the three arrays is
to print them at a function call site that has been reached through
two levels of nesting plus a sourced library.

```bash
# scenario: walk the call stack from inside a deeply-called function.
# ── /tmp/lib.sh ───────────────────────────────────────────────
report_stack() {
  local -i i
  for (( i=0; i < ${#FUNCNAME[@]}; i++ )); do
    printf '#%d  fn=%s  src=%s:%s\n' \
      "$i" \
      "${FUNCNAME[$i]:-MAIN}" \
      "${BASH_SOURCE[$i]}" \
      "${BASH_LINENO[$i]}"
  done                                         # (BCS0410, BCS0603)
}
inner() { report_stack; }
outer() { inner; }
#fin

# ── /tmp/main.sh ──────────────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/lib.sh
outer
#fin
```

Output (line numbers vary):

```
#0  fn=report_stack  src=/tmp/lib.sh:3
#1  fn=inner         src=/tmp/lib.sh:11
#2  fn=outer         src=/tmp/lib.sh:12
#3  fn=source        src=/tmp/main.sh:4
#4  fn=MAIN          src=/tmp/main.sh:0
```

Notice the symmetry: index 0 is *innermost* (the currently executing
function); the outermost frame's `BASH_SOURCE` is the top-level
script. The `source` pseudo-frame at index 3 marks the boundary where
`/tmp/main.sh` sourced `/tmp/lib.sh`, and `BASH_LINENO[3]` is the
line in main.sh where the source happened. This symmetry is the basis
of every usable bash stack trace — see §13.8 ERR-trap reporting and
§9.11 for the production-grade pattern.

**See also**: §9.11 self-locating with `BASH_SOURCE` (canonical
owner of the usage patterns), §10.3 self-locating library pattern,
§9.7 function tracing (interaction with `set -T`), §13.8 the ERR
trap, BCS0410 (recursive function state discipline), BCS0603 (trap
handling).

#fin
