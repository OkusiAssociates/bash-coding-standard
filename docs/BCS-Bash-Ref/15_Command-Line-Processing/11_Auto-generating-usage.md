<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.11 Auto-generating usage

The hardest bug to keep out of a CLI is **drift** between `--help` and
the parser: a new option lands in the case loop but the help text is
not updated, or vice versa. Two BCS-aligned patterns prevent this:
single-source-of-truth (one spec drives both) and the deferred-action
pattern (the parser writes pending mutations into globals, the help
text reads from the same globals).

### Pattern 1 — heredoc co-located with parser

The simplest approach, used by the BCS `complete` template: keep
`show_help` and the parser in the same file, in adjacent functions,
and discipline yourself to edit them together. Tests close the loop.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/} VERSION=1.0.0
declare -i VERBOSE=1 DRY_RUN=0
declare -- FILE=''

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- demo tool

Usage: $SCRIPT_NAME [OPTIONS] ARG

Options:
  -v, --verbose      Enable verbose output (default)
  -q, --quiet        Disable verbose output
  -n, --dry-run      Preview changes without applying
  -f, --file PATH    Input file
  -V, --version      Show version
  -h, --help         Show this help message
HELP
}

main() {
  while (($#)); do
    case $1 in
      -v|--verbose)  VERBOSE=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--file)     noarg "$@"; shift; FILE=$1 ;;
      --file=*)      FILE=${1#*=} ;;
      -V|--version)  printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)     show_help; exit 0 ;;
      -[vqnfVh]?*)   set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)            shift; break ;;
      -*)            die 22 "unknown option: $1" ;;
      *)             break ;;
    esac
    shift
  done
}

main "$@"
#fin
```

Lock the contract with a test:

```bash
# scenario: regression-test that --help mentions every parsed option
for opt in --verbose --quiet --dry-run --file --version --help; do
  myscript --help | grep -qF -- "$opt" \
    || die 1 "help text missing $opt"
done
```

### Pattern 2 — single-source-of-truth spec

For larger CLIs, drive both help and parsing from one declarative
spec. The BCS-friendly form is an indexed array of `tab`-separated
records, walked twice — once to render help, once to build the case
arms via a generated dispatch table.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/}
declare -i VERBOSE=1 DRY_RUN=0
declare -- FILE=''

# spec: short<TAB>long<TAB>arg?<TAB>variable<TAB>description
declare -a OPTSPEC=(
  $'-v\t--verbose\t0\tVERBOSE=1\tEnable verbose output'
  $'-q\t--quiet\t0\tVERBOSE=0\tDisable verbose output'
  $'-n\t--dry-run\t0\tDRY_RUN=1\tPreview changes only'
  $'-f\t--file\t1\tFILE\tInput file'
)

show_help() {
  printf '%s -- demo tool\n\nUsage: %s [OPTIONS]\n\nOptions:\n' \
    "$SCRIPT_NAME" "$SCRIPT_NAME"
  local row short long arg var desc
  for row in "${OPTSPEC[@]}"; do
    IFS=$'\t' read -r short long arg var desc <<<"$row"
    if ((arg)); then
      printf '  %s, %s VALUE   %s\n' "$short" "$long" "$desc"
    else
      printf '  %s, %s          %s\n' "$short" "$long" "$desc"
    fi
  done
}

parse_args() {
  while (($#)); do
    local matched=0 row short long arg var
    for row in "${OPTSPEC[@]}"; do
      IFS=$'\t' read -r short long arg var _ <<<"$row"
      [[ $1 == "$short" || $1 == "$long" ]] || continue
      if ((arg)); then noarg "$@"; shift; printf -v "$var" '%s' "$1"
      else             eval "$var"; fi      # var holds 'NAME=value'
      matched=1; break
    done
    ((matched)) || case $1 in
      -h|--help) show_help; exit 0 ;;
      --)        shift; break ;;
      -*)        die 22 "unknown option: $1" ;;
      *)         break ;;
    esac
    shift
  done
}
```

The spec is the single source of truth. Adding a flag means appending
one row; both help and parser pick it up automatically. The `eval`
target is a string the script itself authored (BCS1004 allows such
constrained use); the value-carrying case uses `printf -v "$var"`
which never evals.

### Trade-offs

| Pattern             | Pros                                 | Cons                          |
|---------------------|--------------------------------------|-------------------------------|
| Heredoc + case      | Simple, readable, BCS template form  | Manual sync; relies on tests  |
| Spec array          | Single source of truth, no drift     | Indirection; harder to debug  |

For most BCS scripts (≤10 options), pattern 1 plus a `--help`
regression test is the right choice. Pattern 2 starts paying off
around 15+ options or when multiple subcommands share option groups.

### See also

- §15.4 — hand-rolled `while case shift`
- §15.8 — subcommand dispatch
- §15.9 — help text conventions
- BCS0801 (parsing pattern), BCS0803 (argument validation),
  BCS0805 (short-option bundling), BCS1004 (constrained `eval`)

#fin
