<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.2 Argument passing

A bash function has no declared parameter list. Arguments arrive
purely by position, mirroring the shell's positional-parameter
mechanism for scripts. Inside the function body, `$1`, `$2`, … refer
to the function's arguments — *not* the script's — and the script's
positionals are temporarily shadowed for the duration of the call.

### The full positional set

| Form | Meaning |
|------|---------|
| `$1`, `$2`, …, `$9` | First nine arguments. |
| `${10}`, `${11}`, … | Tenth and beyond — **braces required**, otherwise `$10` parses as `$1` followed by literal `0`. |
| `$#` | Argument count. |
| `$@` | All arguments. When quoted, expands to *N separate words* preserving each argument's whitespace. |
| `$*` | All arguments. When quoted, expands to a *single string* with arguments joined by `IFS[0]` (a space by default). |
| `$0` | The script's name, **not** the function's. Use `${FUNCNAME[0]}` to learn the running function's name (§9.11). |

`$@` versus `$*` is the one distinction that bites every bash author at
least once. Quoted `"$@"` is the only safe forwarding form; everything
else risks word-splitting on argument-internal whitespace.

### Default values and required arguments

Bash has no formal "default-value" syntax for function parameters, but
parameter expansion fills the gap. `${1:-default}` substitutes
`default` when `$1` is unset or empty; `${1:?message}` aborts the
function with the message when `$1` is unset or empty (and is the
shortest, clearest way to enforce required arguments).

```bash
# scenario: a function with one optional and one required argument
greet() {
  local -- name="${1:?usage: greet NAME [GREETING]}"     # required: dies if missing/empty
  local -- greeting="${2:-Hello}"                        # optional: defaults to Hello
  printf '%s, %s!\n' "$greeting" "$name"
}

greet                # ⇒ bash: 1: usage: greet NAME [GREETING]   (script exits)
greet Alice          # ⇒ Hello, Alice!
greet Bob 'Howdy'    # ⇒ Howdy, Bob!
```

The `:?` form respects strict mode: it raises an error and the
surrounding `set -e` (BCS0101) propagates the failure. `local --`
terminates option processing for `local` so an argument value
beginning with `-` is treated as a value (BCS0202, §9.3).

### Forwarding arguments — `"$@"` versus `"$*"`

A wrapper function that delegates to another command must forward
arguments without mangling them. Quote `"$@"` and nothing else:

```bash
# scenario: argument forwarding — preserve argument boundaries with spaces
trace() { printf '+ %s\n' "$*" >&2; "$@"; }              # log then run

trace ls -l 'My Documents'         # ⇒ + ls -l My Documents
                                   #   (then runs: ls -l "My Documents" — one path arg)

# wrong — unquoted $@ word-splits on the embedded space
trace_bad() { ls -l $@; }
trace_bad 'My Documents'           # ⇒ tries ls -l "My" "Documents" — two paths

# wrong — quoted $* collapses everything into one string
trace_worse() { ls -l "$*"; }
trace_worse a b c                  # ⇒ ls -l "a b c" — single path "a b c"
```

The trace example exploits an asymmetry: inside `printf '%s\n' "$*"`
the merged form is *what you want* (one log line); but the runtime
call `"$@"` keeps each argument as a distinct word. Use each form for
its purpose and nothing else.

### `$0`, `${FUNCNAME[0]}`, and self-naming

`$0` inside a function is still the script's `argv[0]` — *not* the
function's name. To produce a `usage:` string that names the function
correctly, read `${FUNCNAME[0]}`:

```bash
# scenario: the right way to write a usage prefix inside a function
needs_two_args() {
  (( $# >= 2 )) || { printf 'usage: %s ARG1 ARG2\n' "${FUNCNAME[0]}" >&2; return 2; }
  printf 'got: %q %q\n' "$1" "$2"
}
```

`FUNCNAME` is an array; `[0]` is the current function, `[1]` is its
caller, and so on. The full call-stack inspection idiom appears in
§9.11.

### Argument count and shifting

`$#` is the live argument count and decreases as arguments are
consumed via `shift`. Argument loops in functions follow the same
pattern as script-level argument parsing (BCS0801): a `while (($#))`
loop with a `case $1` dispatch, `shift` after each consumed token,
and a final `noarg` check on options that take values. The
`shift_verbose` shopt (BCS0101 strict-mode) makes a shift past the
end of arguments fatal — useful for catching off-by-one errors in
loop bodies.

```bash
# scenario: in-function option loop following the BCS argument-parsing pattern
copy_files() {
  local -i verbose=0
  local -- dest=''
  while (($#)); do case $1 in
    -v|--verbose)  verbose=1 ;;
    -d|--dest)     dest=${2:?--dest needs an argument}; shift ;;
    --)            shift; break ;;
    -*)            printf 'unknown option: %s\n' "$1" >&2; return 22 ;;
    *)             break ;;
  esac; shift; done
  ((verbose)) && printf 'copying to %s\n' "${dest@Q}" >&2
  cp "$@" "$dest"
}
```

The pattern is recognisable across BCS code: standard separators
(`--`), explicit option-value handling, exit code 22 (invalid
argument) on unknown options. Functions that act as miniature CLIs
adopt this shape verbatim.

**See also**: §9.1 (definition syntax), §9.5 (communicating results),
§9.11 (`BASH_SOURCE`/`FUNCNAME`/`BASH_LINENO`), §4.2 (positional
parameters), §15 (command-line processing — argument-loop patterns),
BCS0101 (strict mode incl. `shift_verbose`), BCS0202 (variable
scoping), BCS0411 (subshell return patterns), BCS0801 (standard
parsing pattern), BCS-bash `12_01_Positional-Parameters.md`.

#fin
