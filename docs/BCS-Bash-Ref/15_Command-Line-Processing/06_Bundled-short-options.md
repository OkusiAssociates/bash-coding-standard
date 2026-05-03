<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.6 Bundled short options

Combining multiple short flags into one argument (`-abc` for
`-a -b -c`) is a long-standing UNIX convention (BCS0805). Bash has no
builtin bundling support; the parser must expand bundles itself.

### The bundling expander

```bash
-[abc]?*)            set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Three pieces, each load-bearing:

| Fragment | Result |
|----------|--------|
| `${1:0:2}` | the leading two chars of `$1` — e.g., `-a` from `-abc` |
| `-${1:2}`  | a hyphen plus the rest — e.g., `-bc` from `-abc` |
| `${@:2}`   | the rest of the original argv slots, unchanged |

Putting them together, `set -- ...` rewrites `$@` so that the next
loop iteration sees the un-bundled head separately from the still-
bundled tail. `continue` (rather than `shift`) skips the trailing
`shift` at the end of the loop body — the rewrite already advanced
the parser.

### Worked input/output

```bash
# scenario: trace a single bundled call through the expander
# initial argv: -abc input.txt
# arm: -[abc]?*) matches because ${1:0:2}=-a, ${1:2}=bc

# after set --:
#   $1=-a   $2=-bc   $3=input.txt

# next iteration: $1=-a hits the -a arm (whatever it is), shift
#   $1=-bc  $2=input.txt
# -[abc]?* matches again: $1=-b, $2=-c, $3=input.txt
# next iteration: -b arm, shift
#   $1=-c   $2=input.txt
# next iteration: -c arm, shift
#   $1=input.txt — matches the * positional arm
```

The expander runs N-1 times for an N-character bundle, splitting one
flag off per iteration. `continue` is critical: a `shift` after the
rewrite would discard the freshly-promoted `-a` before its arm could
fire.

### Character-class extension rule

The class `[abc]` lists every short option that may appear inside a
bundle. To enable `-d` for bundling:

```bash
# wrong — adds -d to the parser but not to the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abc]?*)           set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
# now -dabc is rejected by -*) as unknown

# right — letter appears in both the dispatch and the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abcd]?*)          set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Value-taking short options must **not** appear in the class. `-fconfig`
should be a single value-bearing argument (`-f` with value `config`),
not the bundle `-f -c -o -n -f -i -g`.

### Why this trick works

`${1:0:2}` is a substring expansion (BCS0207). The two-character form
`-a`, `-b`, etc. is exactly two bytes. The trailing `?*` in the case
pattern requires at least one more character after the leading flag,
so a non-bundle like `-a` falls through to the regular `-a` arm.

### See also

- §15.4 — the full hand-rolled parser with bundling
- §15.5 — long-option forms (not bundled)
- BCS0805 (short option bundling), BCS0207 (parameter expansion)

#fin
