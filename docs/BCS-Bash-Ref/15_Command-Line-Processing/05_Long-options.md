<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.5 Long options

GNU-style long options accept two equivalent value forms: the
space-separated `--file value` and the equals form `--file=value`.
Well-behaved scripts accept both (BCS0806).

### Both forms in one case-block

The canonical pattern dedicates two `case` arms per value-taking long
option — one each for the two forms:

```bash
# scenario: one option, two forms, one parser
parse_args() {
  while (($#)); do
    case $1 in
      -f|--file)       shift; noarg "$@"; FILE=$1 ;;       # space form
      --file=*)        FILE=${1#*=} ;;                     # equals form
      -h|--help)       usage; return 0 ;;
      --)              shift; POSITIONAL+=("$@"); break ;;
      -*)              die 22 "unknown option: $1" ;;
      *)               POSITIONAL+=("$1") ;;
    esac
    shift
  done
}

# all three calls produce FILE=config.yaml
parse_args -f config.yaml
parse_args --file config.yaml
parse_args --file=config.yaml
```

`${1#*=}` is BCS0207 parameter expansion — strip the shortest match of
`*=` from the front of `$1`, leaving everything after the first `=`.
That handles values containing `=` themselves: `--filter=key=value`
captures `key=value` correctly.

### Flag-only long options

Flag-only forms (no value) need only one arm:

```bash
-v|--verbose)        VERBOSE+=1 ;;
-q|--quiet)          VERBOSE=0 ;;
```

Combined with a value-taking arm, the same `case` block handles both
flag-only and value-taking long options without losing readability.

### Consistency rule

Either accept both forms or only one — pick a discipline and stick to
it across the whole script. Mixing (`--file value` works but
`--filter=value` does not) is the single most common CLI bug pattern
in shell scripts.

### Documentation

Help output should show both forms when both are accepted (§15.9):

```text
Options:
  -f, --file FILE          read FILE (or --file=FILE)
```

### See also

- §15.4 — full hand-rolled parser
- §15.7 — `--` end-of-options sentinel
- §15.9 — help text conventions
- BCS0207 (parameter expansion), BCS0806 (standard options)

#fin
