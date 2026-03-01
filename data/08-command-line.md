# Section 8: Command-Line Arguments

## BCS0800 Section Overview

Use `while (($#)); do case $1 in ... esac; shift; done` as the standard argument parsing pattern. This section covers parsing, option bundling, validation, and version output.

## BCS0801 Standard Parsing Pattern

```bash
# correct
while (($#)); do case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -q|--quiet)   VERBOSE=0 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
  -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)    show_help; exit 0 ;;
  --)           shift; FILES+=("$@"); break ;;
  -[vqnoVh]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)           die 22 "Invalid option ${1@Q}" ;;
  *)            FILES+=("$1") ;;
esac; shift; done

# wrong
while [[ $# -gt 0 ]]; do            # use (($#)) instead
```

Key rules:
- `(($#))` is more efficient than `[[ $# -gt 0 ]]`
- The mandatory `shift` at loop end is critical — omitting it causes infinite loops
- For options with arguments: `noarg "$@"; shift; variable=$1`
- For boolean flags: just set, no extra shift needed
- For exit options (`--help`, `--version`): use `exit 0`, no shift needed
- Use `continue` after option disaggregation to re-process expanded options

## BCS0802 Version Output

Format: `scriptname X.Y.Z` without the word "version".

```bash
# correct
echo "$SCRIPT_NAME $VERSION"
# output: myscript 1.0.0

# wrong
echo "$SCRIPT_NAME version $VERSION"
echo "Version: $VERSION"
```

## BCS0803 Argument Validation

Validate option arguments exist before capturing them.

```bash
# correct — noarg checks $2 exists
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# usage
-o|--output) noarg "$@"; shift; OUTPUT=$1 ;;

# wrong — no validation
-o|--output) shift; OUTPUT=$1 ;;     # --output --verbose captures --verbose
```

Always call validators BEFORE `shift` — they must inspect `$2`.

Validate required arguments after parsing:

```bash
((${#FILES[@]})) || die 2 'No input files specified'
[[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 22 "Invalid mode ${mode@Q}"
```

## BCS0804 Parsing Location

Place argument parsing inside `main()` for better testability.

```bash
# correct
main() {
  while (($#)); do case $1 in
    # ...
  esac; shift; done
  readonly -- VERBOSE DRY_RUN OUTPUT

  process_files
}

# acceptable for simple scripts under 200 lines
while (($#)); do case $1 in
  # ...
esac; shift; done
```

Make variables readonly after parsing completes.

## BCS0805 Short Option Bundling

Support bundled short options like `-vvn` expanding to `-v -v -n`.

```bash
# correct — disaggregation pattern (list valid short options explicitly)
-[vqnoVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;

# correct — pure bash method (68% faster, no external deps)
-[vqnoVh]?*)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}"
  ;;
```

Place bundling case before `-*)` invalid option handler and after all explicit option cases. List only valid short options in the pattern to prevent incorrect expansion.

Options requiring arguments cannot be bundled mid-string: `-vno output.txt` works (`-o` is last), but `-von file` fails (`-o` captures `n`).
