<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.3 GNU `getopt(1)` external

The external GNU `getopt` parses both short and long options and
re-quotes the result for `eval`. Powerful, portable in theory, brittle
in practice — BCS does not endorse it (§15.4 is preferred).

### Syntax

```bash
# scenario: minimal GNU getopt invocation
parsed=$(getopt -o 'vqf:h' --long 'verbose,quiet,file:,help' -n "$0" -- "$@")
eval set -- "$parsed"
while true; do
  case $1 in
    -v|--verbose) VERBOSE=1; shift ;;
    -q|--quiet)   VERBOSE=0; shift ;;
    -f|--file)    FILE=$2; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    --)           shift; break ;;
    *)            die 22 "internal error: $1" ;;
  esac
done
```

The `-o` short-option list and `--long` long-option list both use `:`
to mark a value-taking option (one colon for required, two for
optional — but optional values are themselves a quoting hazard).

### BSD vs GNU detection

`getopt(1)` exists on both Linux (GNU, util-linux) and BSD/macOS, but
the BSD variant has *no* long-option support and a different argument
order. Detect before invoking:

```bash
# scenario: refuse to run if the local getopt is the BSD flavour
if ! getopt --test >/dev/null 2>&1; (( $? != 4 )); then
  die 18 'GNU getopt(1) required (BSD getopt does not support --long)'
fi
```

GNU getopt's `--test` flag exits with status 4 (a deliberate sentinel)
to signal "I'm the GNU one." Anything else — exit 0, exit 1, or "no
such option" — means the script is on a system without GNU getopt and
must either fall back to a hand-rolled parser (§15.4) or die.

### Why BCS prefers hand-rolled

- Requires `eval` of the re-quoted output — quoting bugs become
  injection vectors (BCS1004).
- Adds an external dependency that may not exist (BSD systems, busybox,
  Alpine without `util-linux`).
- The detection ritual above is more code than the equivalent
  `while case shift` loop.
- Errors are reported by `getopt` itself, before script logic runs;
  customising the message requires disabling `getopt`'s own reporting
  with `+`-prefixed optstring.

### See also

- §15.2 — POSIX `getopts` (builtin, no eval, short options only)
- §15.4 — the BCS canonical hand-rolled parser
- BCS0801 (standard parsing pattern), BCS1004 (eval avoidance)

#fin
