<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.2 Positional parameters

Positional parameters are the numbered arguments delivered to a script,
to a function, or to any block introduced by `set --`. Bash treats all
three sources through a single mechanism: the same `$1`, `$2`, `$#`,
`$@`, `$*` apply unchanged, and the same quoting discipline matters in
each context.

### Names and access

- `$0` — script name as invoked. Inside a function `$0` still refers to
  the script, not the function. `$BASH_SOURCE[0]` is the file the code
  was sourced from; `$FUNCNAME[0]` is the current function name. If
  `BASH_ARGV0` is assigned, `$0` reflects the new value.
- `$1` … `$9` — the first nine positionals, accessible without braces.
- `${10}`, `${11}`, … — beyond nine, **braces are required**: `$10`
  parses as `$1` followed by the literal `0`.
- `$#` — count of positionals currently in scope (script, function, or
  `set --` block).
- `set -- a b c` — explicit assignment. `set --` with no further
  arguments clears all positionals.
- `shift [N]` — discards the first `N` (default `1`) positionals and
  renumbers the remainder. Under `shopt -s shift_verbose`, shifting more
  than `$#` is a visible error rather than a silent no-op.

### `"$@"` versus `"$*"` — the load-bearing distinction

Both expand to all positionals, but the quoted forms behave very
differently:

- `"$@"` expands to **N separate words**, one per positional, with
  internal whitespace and globbing characters preserved verbatim.
- `"$*"` expands to **a single word**, the positionals joined by the
  first character of `IFS` (space by default).

Unquoted `$@` and `$*` are essentially never what you want — both
re-split each element on `IFS` and apply pathname expansion. The only
correct forwarding idiom is `"$@"`.

```bash
# scenario: forwarding arguments correctly versus collapsing them
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

show() {
  printf 'count=%d\n' "$#"
  local -i i=1
  for arg in "$@"; do
    printf '  [%d]=<%s>\n' "$i" "$arg"
    i+=1
  done
}

set -- 'first arg' 'second arg' 'third'

printf '== "$@" preserves words ==\n'
show "$@"
# ⇒ count=3, three discrete entries with internal spaces intact

printf '== "$*" collapses to one word ==\n'
show "$*"
# ⇒ count=1, the entry is "first arg second arg third"

# wrong — unquoted $@ re-splits on IFS; demo only
printf '== unquoted $@ re-splits on IFS ==\n'
#shellcheck disable=SC2068
show $@
# ⇒ count=5: "first", "arg", "second", "arg", "third"
```

The collapsing form `"$*"` has narrow legitimate uses — joining
positionals into a log line, building a single shell-quoted string for
display — but for **forwarding** arguments to another command, the only
correct form is `"$@"`.

### Function positionals shadow the script's

When a function is called, its arguments become the active `$1`, `$2`,
…; the script's positionals are inaccessible from inside the function
unless explicitly captured. `return` restores the caller's positional
set.

```bash
greet() {
  printf 'function sees: %d args, first=<%s>\n' "$#" "${1-}"
}

set -- alpha beta gamma
greet one two
# ⇒ function sees: 2 args, first=<one>
# script's $1 is still "alpha" after greet returns
printf 'script sees: %s\n' "$1"
```

The `${1-}` form (with a default) is needed under `set -u` whenever a
positional may legitimately be unset — bare `$1` would abort the script.

### Consuming options with `getopts`

`getopts` walks the positionals one option at a time, populating
`$OPTARG` and `$OPTIND`. After the loop, `shift "$((OPTIND - 1))"`
discards the consumed options, leaving the non-option arguments as the
new `$1`, `$2`, …

```bash
# scenario: getopts consumes options, leaving file arguments
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

verbose=0 output=''
while getopts ':vo:' opt; do
  case $opt in
    v)  verbose=1 ;;
    o)  output=$OPTARG ;;
    \?) printf 'unknown: -%s\n' "$OPTARG" >&2; exit 2 ;;
    :)  printf 'missing arg: -%s\n' "$OPTARG" >&2; exit 2 ;;
  esac
done
shift "$((OPTIND - 1))"

printf 'verbose=%d output=<%s>\n' "$verbose" "$output"
printf 'remaining files: %d\n' "$#"
for f in "$@"; do printf '  %s\n' "$f"; done

# Invoked as: ./script -v -o out.log a.txt b.txt
# ⇒ verbose=1 output=<out.log>, two file arguments remain
```

`getopts` only handles short options (`-v`, `-o arg`, bundled `-vo
arg`); for long options, hand-write the loop or use a dedicated
parser — see §6.4 for the BCS pattern.

### Common pitfalls

- `[[ -z $1 ]]` aborts under `set -u` if `$1` is unset; use `[[ -z
  ${1-} ]]`.
- `for x in $@; do …` is wrong twice over — unquoted, and missing the
  `"$@"` discipline. Always write `for x in "$@"; do …`.
- `shift; shift; shift` is fragile; prefer `shift 3`, or use
  `shift_verbose` and consume options through `getopts`.

### See also

- §4.3 — special parameters (`$#`, `$@`, `$*`, `$?`, …)
- §6.4 — option-parsing patterns and `getopts` idioms
- §4.13 — assignment-prefixed commands and positional inheritance
- BCS0202 (variable scoping), BCS0301 (quoting fundamentals)

#fin
