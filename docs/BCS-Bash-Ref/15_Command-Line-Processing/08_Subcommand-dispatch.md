<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 15.8 Subcommand dispatch

Multi-command CLIs (like `git`, `bcs`, `kubectl`) dispatch a
subcommand to a handler function (BCS0801).

### Top-level dispatcher

```bash
main() {
  case ${1:-} in
    init)    shift; cmd_init "$@" ;;
    build)   shift; cmd_build "$@" ;;
    deploy)  shift; cmd_deploy "$@" ;;
    help)    shift; cmd_help "$@" ;;
    ''|-h|--help)  usage; exit 0 ;;
    *)       die 22 "unknown subcommand: $1" ;;
  esac
}
main "$@"
```

- One function per subcommand: `cmd_NAME`.
- `${1:-}` defends against `set -u` when called with no args.
- The `''` arm (empty string) and `-h`/`--help` share usage output.

### Per-subcommand option parsing

Each `cmd_NAME` parses its own options independently — top-level
options (e.g., `--verbose`) parse before the subcommand, while
subcommand-specific options (e.g., `--target=...` for `deploy`) parse
inside the handler:

```bash
cmd_deploy() {
  local -- target='' env='prod'
  while (($#)); do
    case $1 in
      -t|--target)     shift; noarg "$@"; target=$1 ;;
      --target=*)      target=${1#*=} ;;
      -e|--env)        shift; noarg "$@"; env=$1 ;;
      --env=*)         env=${1#*=} ;;
      -[teh]?*)        set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      -h|--help)       show_deploy_help; return 0 ;;
      --)              shift; break ;;
      -*)              die 22 "deploy: unknown option: $1" ;;
      *)               break ;;
    esac
    shift
  done
  [[ -n $target ]] || die 22 'deploy: --target required'
  do_deploy "$target" "$env" "$@"
}
```

Note the bundling class `[teh]` matches the short forms of every
flag-only or boolean-toggle option in this subcommand — the value-
taking `-t` and `-e` are *also* in the class because they have both
short and long forms; the bundle expander separates the leading `-t`
or `-e` and the regular arm sees the value in `$2`.

### `bcs` itself uses this pattern

The `bcs` script dispatches `display`, `template`, `check`, `codes`,
`generate`, and `help`; each is implemented as `cmd_NAME` with a
matching `show_NAME_help`. The same `case` shape, the same option
loop, and the same `-[abc]?*` bundling expansion appear in every
handler — the dispatcher pattern scales by repetition without any
extra mechanism. See `bcs:main()` and the per-subcommand helpers it
delegates to.

### Help routing

A subcommand-aware help helper resolves `mytool help deploy` to
`show_deploy_help`:

```bash
cmd_help() {
  case ${1:-} in
    init)    show_init_help ;;
    build)   show_build_help ;;
    deploy)  show_deploy_help ;;
    '')      usage ;;
    *)       die 22 "unknown subcommand: $1" ;;
  esac
}
```

### See also

- §15.4 — option parsing inside `cmd_*` handlers
- §15.9 — per-subcommand `--help`
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

#fin
