<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Section 08: Command-Line Arguments

## BCS0800 Section Overview

Use `while (($#)); do case $1 in ... esac; shift; done` as the standard argument parsing pattern. This section covers parsing, standard options, option bundling, validation, and version output.

## BCS0801 Standard Parsing Pattern

**Tier:** core

```bash
# correct
while (($#)); do case $1 in
  -v|--verbose) VERBOSE=1 ;;
  -q|--quiet)   VERBOSE=0 ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -o|--output)  noarg "$@"; shift; OUTPUT=$1 ;;
  -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
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

See also: [Argument Processing Reference](../benchmarks/args-processing-reference.md) — comparison of BCS while/case, getopts, GNU getopt, and simple while/case with benchmark data.

## BCS0802 Version Output

**Tier:** style

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

**Tier:** core

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
[[ $mode =~ ^(normal|fast|safe)$ ]] || die 22 "Invalid mode ${mode@Q}"
```

## BCS0804 Parsing Location

**Tier:** recommended

Place argument parsing inside `main()` for better testability.

```bash
# correct
main() {
  while (($#)); do case $1 in
    # ...
  esac; shift; done
  readonly VERBOSE DRY_RUN OUTPUT

  process_files
}

# acceptable for simple scripts under 200 lines
while (($#)); do case $1 in
  # ...
esac; shift; done
```

Make variables readonly after parsing completes.

## BCS0805 Short Option Bundling

**Tier:** recommended

Support bundled short options like `-vvn` expanding to `-v -v -n`.

```bash
# correct — recommended disaggregation pattern (list valid short options explicitly)
-[vqnoVh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;

# correct — pure bash method (68% faster, no external deps); only use if speed is absolutely essential
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

Include arg-taking options in the character class. They work correctly when last in the bundle — the disaggregation peels them off as a separate `-X` flag, and `shift` in their case handler picks up the argument normally. Example: `-vno output.txt` disaggregates to `-v -n -o`, then `-o` consumes `output.txt` via `shift`. The user must place arg-taking options last; `-von file` would incorrectly disaggregate to `-v -o -n`.

## BCS0806 Standard Options

**Tier:** recommended

Use consistent option letters and variable names across all BCS-compliant scripts. Avoid reassign a standard letter to a different purpose.

**Strongly Recommended** — include in every script that uses options:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-V` | `--version` | — | — | Print version and exit |
| `-h` | `--help` | — | — | Print help and exit |

**Recommended** — include when the script produces output or performs actions:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-v` | `--verbose` | `VERBOSE` | `1` | Enable verbose output |
| `-q` | `--quiet` | `VERBOSE` | `0` | Suppress informational output |

**Optional** — use when the script needs these capabilities:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-n` | `--dry-run` | `DRY_RUN` | `0` or `1` | Preview without changes |
| `-N` | `--not-dry-run` | `DRY_RUN` | `0` | Execute changes (cancels dry-run) |
| `-f` | `--force` | `FORCE` | `0` | Skip confirmation prompts |
| `-D` | `--debug` | `DEBUG` | `0` | Enable debug output |
| `-p` | `--port` | `PORT` | varies | Network port |
| `-P` | `--prefix` | `PREFIX` | varies | Installation prefix |

Key rules:
- **Avoid reassigning** a standard letter to a different purpose — `-v` is always verbose, never version
- **Toggle pairs:** `-n`/`-N` and `-v`/`-q` are complementary toggles sharing a variable
- **DRY_RUN=1 default** for destructive scripts — require `-N` to execute; use `DRY_RUN=0` for non-destructive scripts
- **Use `declare -i`** for all flag variables: `declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0`

```bash
# correct — standard options with consistent letters and variables
declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0

while (($#)); do case $1 in
  -v|--verbose)     VERBOSE=1 ;;
  -q|--quiet)       VERBOSE=0 ;;
  -n|--dry-run)     DRY_RUN=1 ;;
  -N|--not-dry-run) DRY_RUN=0 ;;
  -f|--force)       FORCE=1 ;;
  -D|--debug)       DEBUG=1 ;;
  -V|--version)     echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)        show_help; exit 0 ;;
  --)               shift; FILES+=("$@"); break ;;
  -[vqnNfDVh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
  -*)               die 22 "Invalid option ${1@Q}" ;;
  *)                FILES+=("$1") ;;
esac; shift; done

# wrong — reassigned letters
-d|--debug)         # -d is not standard for debug; use -D
-v|--version)       # -v is verbose, never version; use -V
```

See also: BCS0701 (message control flags), BCS0802 (version output format), BCS1207 (verbose pattern), BCS1208 (dry-run pattern).
