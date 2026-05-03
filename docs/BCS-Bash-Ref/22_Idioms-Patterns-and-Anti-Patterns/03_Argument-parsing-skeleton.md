<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.3 Argument-parsing skeleton

The canonical hand-rolled argument parser for BCS scripts. Reach for this
whenever you would otherwise sprinkle `getopts` or `getopt` into a script:
the BCS form costs the same number of lines, but supports long options,
bundled short options, equals-form (`--out=foo`), the `--` end-of-options
sentinel, and explicit per-option argument validation — none of which
`getopts` gives you.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

# --- Defaults (BCS0208: integer flags, BCS0204: env-var override) -------
declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0
declare -- OUTPUT="${OUTPUT:-}"
declare -- MODE='normal'
declare -a FILES=()

die()   { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- example BCS-canonical argument parser.

Usage: $SCRIPT_NAME [OPTIONS] [--] FILE...

Options:
  -v, --verbose       Increase verbosity (default).
  -q, --quiet         Suppress informational output.
  -n, --dry-run       Preview without changes.
  -f, --force         Skip confirmation prompts.
  -D, --debug         Enable debug output.
  -o, --output FILE   Write output to FILE.
  -m, --mode MODE     One of: normal, fast, safe.
  -V, --version       Print version and exit.
  -h, --help          Print this help and exit.
HELP
}

main() {
  while (($#)); do case $1 in
    -v|--verbose)     VERBOSE=1 ;;
    -q|--quiet)       VERBOSE=0 ;;
    -n|--dry-run)     DRY_RUN=1 ;;
    -f|--force)       FORCE=1 ;;
    -D|--debug)       DEBUG=1 ;;
    -o|--output)      noarg "$@"; shift; OUTPUT=$1 ;;
    -o=*|--output=*)  OUTPUT=${1#*=} ;;
    -m|--mode)        noarg "$@"; shift; MODE=$1 ;;
    -m=*|--mode=*)    MODE=${1#*=} ;;
    -V|--version)     printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
    -h|--help)        show_help; exit 0 ;;
    --)               shift; FILES+=("$@"); break ;;
    -[vqnfDomVh]?*)   set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
    -*)               die 22 "Invalid option ${1@Q}" ;;
    *)                FILES+=("$1") ;;
  esac; shift; done

  # Post-parse validation -------------------------------------------------
  ((${#FILES[@]})) || die 2 'No input files specified'
  [[ $MODE =~ ^(normal|fast|safe)$ ]] || die 22 "Invalid mode ${MODE@Q}"
  ((DRY_RUN && FORCE)) && die 22 '--force and --dry-run are mutually exclusive'

  readonly VERBOSE DRY_RUN DEBUG FORCE OUTPUT MODE
  declare -r FILES

  # ... do work ...
}

main "$@"
#fin
```

Walking through the loop top-to-bottom: `(($#))` tests positional count
arithmetically, half the cost of `[[ $# -gt 0 ]]` (BCS0801). Each option
arm is one `case` entry; long and short forms share the arm by listing
both patterns separated by `|`. Boolean toggles (`--verbose`, `--debug`)
just set their flag; argument-taking options (`--output`, `--mode`) call
`noarg "$@"` *before* shifting so the validator can inspect `$2` while it
still exists, and only then `shift; VAR=$1` consumes it (BCS0803). The
equals form has its own arm using `${1#*=}` to strip the prefix; this
keeps `--output=foo` working without a second shift.

The `--` arm hands every remaining argument verbatim to `FILES` and
breaks the loop, so a literal `-x` filename after `--` is never confused
for a flag. The bundling arm `-[vqnfDomVh]?*` matches a short option
followed by extra characters (`-vDn`, `-vno output.txt`); it splices the
input into `${1:0:2}` (`-v`) and `-${1:2}` (`-Dn`) and uses `continue`
to re-enter the loop without `shift` — the `-v` is processed on the next
iteration, then `-Dn` gets disaggregated again. The character class lists
**only** valid short options: any unlisted letter falls through to the
`-*` arm and dies with an "Invalid option" message (BCS0805). The
catch-all `*)` arm collects positional arguments into `FILES`.

After parsing, validate semantics. Required arguments
(`((${#FILES[@]}))`), value-set membership (regex on `$MODE`), and
mutual-exclusion checks belong here, not inside the case arms. Then mark
everything `readonly` so a stray downstream assignment is loud rather
than silent (BCS0205).

**Common bug: missing `shift` at loop end.**

```bash
# wrong — infinite loop on the first arg
while (($#)); do case $1 in
  -v) VERBOSE=1 ;;
esac; done

# correct — terminating `; shift; done`
while (($#)); do case $1 in
  -v) VERBOSE=1 ;;
esac; shift; done
```

The trailing `shift` is part of the idiom, not optional ornament; the
loop has no other way to advance. Cases that exit (`--help`, `--version`)
or that themselves shift (`--`, the noarg-aware arms) don't reach the
final `shift`, which is why they are written to break, exit, or balance
their own shifts.

**See also**: §15.4 for the full discussion of CLI parsing alternatives
(`getopts`, GNU `getopt`, third-party libraries) and benchmark data;
BCS0801 / BCS0803 / BCS0805 / BCS0806 in `BASH-CODING-STANDARD.md` for
the rule-level statement of each component.

#fin
