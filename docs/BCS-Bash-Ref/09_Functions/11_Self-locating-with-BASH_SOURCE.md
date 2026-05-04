<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.11 Self-locating with `BASH_SOURCE`

A function or sourced script frequently needs to know *where on disk
its own file lives* — to find sibling resources, to load configuration
files placed alongside it, or to derive an FHS-compliant data
directory (BCS0104). Bash exposes the necessary metadata through three
parallel call-stack arrays: `BASH_SOURCE`, `FUNCNAME`, and
`BASH_LINENO`.

### The three call-stack arrays

| Array | Index 0 | Index N |
|-------|---------|---------|
| `BASH_SOURCE` | Source file of the currently executing function (or `$0` at top level). | Source file of the call N levels up the stack. |
| `FUNCNAME` | Name of the currently executing function (or `main` / `source` for top-level / sourced contexts). | Name of the function N levels up. |
| `BASH_LINENO` | Line number in the file at depth `N+1` that called depth `N` — note the off-by-one. | … |

The three arrays move in lockstep; index N of all three describes the
same call frame. The off-by-one in `BASH_LINENO` is deliberate and
matches the C-style "where did the call come from" view of a stack
trace — `BASH_LINENO[0]` is the line in the *caller's* file that
issued the current call.

### The canonical self-location idiom

The pattern below resolves the absolute directory containing the file
in which it is *written*, regardless of how the file was invoked
(direct execution, sourced, exec'd through a wrapper, symlinked into
`$PATH`). It is duplicated verbatim in §10.3 for libraries; the two
chapters describe the same idiom from the function-author and
library-author perspectives.

```bash
# scenario: full self-location at script top — derives lib_dir for resource loading
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# BASH_SOURCE[0] is *this* file even when sourced or symlinked (Bash 4.4+).
# realpath resolves any symlink chain to the canonical absolute path.
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r LIB_DIR="${SCRIPT_DIR}/lib"          # sibling lib/ directory
declare -r DATA_DIR="${SCRIPT_DIR%/bin}/share/myapp"  # FHS-style data dir

# Now resources can be loaded relative to the on-disk location.
[[ -f "$LIB_DIR/helpers.sh" ]] && source "$LIB_DIR/helpers.sh"
```

Three details deserve attention. First, `BASH_SOURCE[0]` (not `$0`)
is what makes this idiom robust — `$0` is `bash` when the script is
sourced, or the wrapper's name when exec'd through a launcher.
Second, `realpath --` (BCS prefers `realpath` over `readlink -f`)
canonicalises symlinks so a script symlinked from `/usr/local/bin`
into the real install prefix still finds its data directory. Third,
the `${SCRIPT_DIR%/bin}/share/myapp` substitution is the FHS pattern:
a binary in `…/bin/` derives its data root by stripping the
trailing `bin` segment.

### Pairing with `FUNCNAME[]` for stack traces

Combining the three arrays produces a textbook call-stack dump,
useful inside an ERR trap or a `die` helper.

```bash
# scenario: dump the bash call stack — function name, file, line at every frame
print_stack() {
  local -i i
  echo "stack trace (most recent call first):" >&2
  for ((i = 0; i < ${#FUNCNAME[@]}; i++)); do
    printf '  #%-2d %s () at %s:%s\n' \
      "$i" "${FUNCNAME[i]}" "${BASH_SOURCE[i]}" "${BASH_LINENO[i-1]:-?}" >&2
  done
}

middle() { print_stack; }
outer()  { middle; }
outer
# ⇒ stack trace (most recent call first):
#     #0  print_stack () at ./demo:11
#     #1  middle      () at ./demo:18
#     #2  outer       () at ./demo:19
#     #3  main        () at ./demo:20
```

Note the use of `BASH_LINENO[i-1]` rather than `[i]` — that is the
off-by-one mentioned above. `FUNCNAME` ends with `main` for a script
or `source` for a sourced file; `BASH_SOURCE` at that final index is
the file's own path. The trace is RAG-grade information: with it the
caller knows *which* invocation produced the failure, not merely
*that* it failed.

For the canonical library version of the self-location idiom, see
§10.3. For pseudo-signal-based stack traces (ERR trap), see §12.6.

**See also**: §9.10 (naming conventions), §10.1 (`source`
semantics), §10.3 (self-locating library pattern — same idiom),
§12.6 (ERR/EXIT pseudo-signals), §13.8 (ERR trap), BCS0103 (script
metadata), BCS0104 (FHS compliance), BCS-bash
`12_03_Shell-Variables.md`.

#fin
