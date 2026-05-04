<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.2 `getopts` builtin

POSIX shell builtin for short-option parsing. Strictly less capable
than the BCS hand-rolled `while case` loop (§15.4) — no long options,
no value validation hooks — but adequate for small scripts that only
need traditional one-char options. The patterns below cover the two
features users most often miss: silent error mode and `OPTIND` reset.

### Syntax and globals

- `getopts OPTSTRING name [args]` — parse one option per call,
  storing the option letter in `name`.
- `OPTSTRING` — string of recognised option letters; a `:` after a
  letter means the option takes a value (placed in `OPTARG`).
- `OPTIND` — index of the next argument to process. Bash initialises
  it to 1; reset to 1 manually before re-parsing.
- `OPTARG` — the option's value, or (in silent mode) the offending
  letter.
- `OPTERR=0` — suppress the builtin's own error messages (alternative
  to silent mode).

### Default error mode

When the first character of `OPTSTRING` is *not* `:`, getopts prints
its own diagnostics on illegal options and missing values, sets
`name` to `?`, and continues. This is rarely what you want in a BCS
script — the messages bypass your `error()` helper and ignore
`SCRIPT_NAME` formatting.

### Silent error mode (recommended)

Prefix `OPTSTRING` with `:`. getopts then becomes silent: on an
illegal option `name=?` and `OPTARG=<bad letter>`; on a missing
value `name=:` and `OPTARG=<letter>`. The script controls all
diagnostic output.

```bash
# scenario: full getopts loop with silent mode
parse_args() {
  local OPTIND opt
  OPTIND=1                                    # always reset for safety
  while getopts ':vqf:h' opt; do
    case $opt in
      v) VERBOSE=1 ;;
      q) VERBOSE=0 ;;
      f) FILE=$OPTARG ;;
      h) show_help; return 0 ;;
      :) die 22 "option -$OPTARG requires a value" ;;
      \?) die 22 "unknown option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))                       # consume parsed options
  POSITIONAL=("$@")
}
```

Notes:

- `local OPTIND opt` — `OPTIND` is **global** by default; localising
  it inside a function lets the function be called repeatedly without
  manual reset and protects the caller's parser state.
- `\?` is the catch-all for unknown letters; `:` is the missing-value
  case — these only fire because `OPTSTRING` begins with `:`.
- `shift $((OPTIND - 1))` after the loop drops the consumed
  options; the remaining `$@` is positional arguments.
- `die 22` follows the BCS exit-code convention (BCS0801,
  exit code 22 = invalid argument).

### Re-parsing the same arguments

`getopts` resumes from `OPTIND` on every call, so re-parsing requires
an explicit reset. The pattern matters when a subcommand re-parses
its own slice of the arguments:

```bash
# scenario: outer parse, then reset for inner subcommand
declare -i outer_v=0
declare -A inner_flags=()

OPTIND=1
while getopts ':v' opt; do
  case $opt in v) outer_v=1 ;; esac
done

OPTIND=1                              # reset before second parse
while getopts ':abc' opt; do
  case $opt in a|b|c) inner_flags[$opt]=1 ;; esac
done
```

### Bundling and value-taking options

`getopts` handles short-option bundling automatically: `-vqf file` is
equivalent to `-v -q -f file`. Value-taking options must appear at the
end of the bundle (`-vqf file`, not `-fvq file` — the latter sets
`f`'s value to `vq`).

For BCS scripts that need long options as well, do not try to extend
`getopts`; switch to the hand-rolled `while case` pattern in §15.4
which uses the BCS bundling expansion explicitly:

```bash
# scenario: BCS bundling pattern (hand-rolled, NOT getopts)
case $1 in
  -[vqfh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
esac
```

The character class `[vqfh]` lists exactly the recognised short
options (BCS0805) — extending the parser means extending this class
too.

### Strict-mode interactions

- `getopts` returns non-zero on EOF; `while getopts ...; do` is the
  loop condition, so this exit is ignored by `errexit` (the same
  exemption as `while read -r`).
- An explicit non-zero from inside a `case` arm (e.g. `:)` or `\?)`)
  is *not* exempt; wrap with `||` or call `die` which handles its
  own exit.
- `OPTERR=0` is an alternative to the leading `:`, but they are not
  cumulative — pick one mechanism. Silent mode (`:` prefix) is the
  BCS recommendation because it lets you distinguish missing-value
  (`:`) from unknown-option (`?`) cases.

### When *not* to use getopts

- You need long options (`--verbose`, `--file=PATH`).
- You need to validate option arguments before they reach the case.
- You want consistent BCS messaging on errors.
- The script has more than ~5 options — the case readability
  advantage of the hand-rolled pattern dominates.

### See also

- §15.4 — BCS hand-rolled `while case shift` (recommended default)
- §15.6 — bundled short options
- §15.7 — `--` end-of-options marker
- BCS0801 (parsing pattern), BCS0803 (argument validation),
  BCS0805 (short-option bundling)

#fin
