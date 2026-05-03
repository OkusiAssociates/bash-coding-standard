<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.4 Hand-rolled `while case shift`

The BCS canonical pattern (BCS0801, BCS0805). Handles long-with-equals,
bundled short options, and end-of-options uniformly inside a single
`case` block, with no external dependency and no `eval`.

```bash
parse_args() {
  while (($#)); do
    case $1 in
      -h|--help)        usage; return 0 ;;
      -v|--verbose)     VERBOSE=1 ;;
      -q|--quiet)       VERBOSE=0 ;;
      -n|--dry-run)     DRY_RUN=1 ;;
      -f|--file)        shift; noarg "$@"; FILE=$1 ;;
      --file=*)         FILE=${1#*=} ;;
      -[abc]?*)         set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)               shift; POSITIONAL+=("$@"); break ;;
      -*)               die 22 "unknown option: $1" ;;
      *)                POSITIONAL+=("$1") ;;
    esac
    shift
  done
}
```

### Per-arm walkthrough

| Arm | Purpose |
|-----|---------|
| `-h\|--help` | dual short/long help; returns 0 (BCS0806) |
| `-v\|--verbose`, `-q\|--quiet`, `-n\|--dry-run` | flags — toggle a global, no value |
| `-f\|--file` | value-taking option, space form: `shift` past flag, validate next arg, capture |
| `--file=*` | value-taking option, equals form: strip prefix with `${1#*=}` |
| `-[abc]?*` | bundling expander (see below) |
| `--` | end-of-options sentinel (§15.7) |
| `-*` | unknown option catch-all (BCS0602: exit 22) |
| `*` | positional accumulator |

`while (($#))` (BCS0501) is the loop guard — it does not invoke `shift`
itself, so `shift_verbose` (warn-on-empty-shift) never triggers; each
arm shifts deliberately.

### The `noarg` helper — definition

`noarg` validates that a value-taking option actually has a value to
take. The BCS-canonical implementation:

```bash
# helper used by every -f|--file style arm
noarg() {
  if (($# < 1)) || [[ ${1:0:1} == - ]]; then
    die 22 "option requires an argument"
  fi
}
```

Why `[[ ${1:0:1} == - ]]` rather than `[[ $1 == -* ]]`: under `set -u`
both are safe because `${1:0:1}` returns empty when `$1` is unset, but
the substring form matches faster and is unambiguous about treating
`$1=""` as "no value." The default-expansion `${1:-}` is *not* needed
inside `[[ ... ]]` because bash treats unset positionals as empty
inside that compound — but BCS still recommends `${1:-}` for clarity
when the arm is called outside a guarded `(($#))` loop.

### Bundling-class character set

`-[abc]?*` only catches bundles built from the listed flag-only short
options. To extend it, add the new short letter to the character class
*and* ensure that letter has a flag-only arm above the bundling line:

```bash
# scenario: add -d (dry-run shorthand) to the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abcd]?*)          set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Never add a value-taking short letter (`-f` here) to the class — the
bundling expander would split `-fname` into `-f` and `-name`, but the
`-f` arm expects the *next* argv slot, not the remainder of the
bundled string. See §15.6 for the expander semantics.

### Strict-mode interactions

- `(($#))` is the loop *condition*, exempt from `set -e`.
- `shift` past the last positional is a no-op — `shift_verbose` would
  warn but the `(($#))` guard prevents that case.
- `noarg`'s `die` exits the script with code 22 (BCS0602).

### See also

- §15.5 — long-option forms (space and equals)
- §15.6 — bundling expansion, deeply explained
- §15.7 — end-of-options sentinel
- BCS0801 (standard parsing pattern), BCS0805 (short option bundling),
  BCS0803 (argument validation)

#fin
