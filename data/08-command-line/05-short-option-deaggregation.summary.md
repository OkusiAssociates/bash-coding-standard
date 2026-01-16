# Short-Option Disaggregation

Splitting bundled short options (`-abc` �' `-a -b -c`) for Unix-standard command-line parsing.

## Why Needed

```bash
# These should be equivalent:
ls -lha
ls -l -h -a
```

Without disaggregation, `-lha` is treated as single unknown option.

## Methods

### Method 1: Iterative Parameter Expansion (Recommended)

```bash
case $1 in
  -[onvqVh]?*)  # Bundled short options
    set -- "${1:0:2}" "-${1:2}" "${@:2}"
    continue
    ;;
esac
```

**How it works:**
- Pattern `-[opts]?*` matches option with additional chars after first
- `${1:0:2}` extracts first option (e.g., `-v` from `-vvn`)
- `"-${1:2}"` creates remaining with dash (e.g., `-vn`)
- `${@:2}` preserves remaining args; `continue` restarts loop

**Performance:** ~24,000-53,000 iter/sec (53-119x faster than alternatives)

**Pros:** No external deps, no shellcheck warnings, pure bash 4+

### Method 2: grep (Alternative)

```bash
-[cfvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

**Performance:** ~445 iter/sec | Requires external grep, SC2046 disable

### Method 3: fold (Alternative)

```bash
-[opts]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}" ;;
```

**Performance:** ~460 iter/sec | Requires external fold, SC2046 disable

### Method 4: Pure Bash Loop

```bash
-[mjvqVh]*) # Split up single options
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```

**Performance:** ~318 iter/sec | No deps, expands all at once, more verbose

## Performance Summary

| Method | Iter/Sec | External Deps | Shellcheck |
|--------|----------|---------------|------------|
| **Iterative** | **24,000-53,000** | **None** | **Clean** |
| grep | ~445 | grep | SC2046 |
| fold | ~460 | fold | SC2046 |
| Pure Bash Loop | ~318 | None | Clean |

## Complete Example (Iterative Method)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...
Options:
  -o, --output FILE  Output file (required)
  -n, --dry-run      Dry-run mode
  -v, --verbose      Verbose output (stackable)
  -V, --version      Show version
  -h, --help         Show this help
EOF
}

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift; output_file=$1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -q|--quiet)     VERBOSE=0 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;
    -[onvqVh]?*)    set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
    -*)             die 22 "Invalid option ${1@Q}" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

  ((VERBOSE)) && echo "Processing ${#files[@]} files" ||:
  ((DRY_RUN)) && echo "[DRY RUN] Would write to ${output_file@Q}" ||:
}

main "$@"
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in middle of bundle:

```bash
# ✓ Correct - option with argument at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt

# ✗ Wrong - option with argument in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

### Character Set Validation

Pattern `-[ovnVh]*` explicitly lists valid options:
- Prevents disaggregation of unknown options
- Unknown options caught by `-*)` case

```bash
./script -xyz  # Doesn't match pattern, caught by -*)
               # Error: Invalid option '-xyz'
```

## Anti-Patterns

```bash
# ✗ Missing continue in iterative method
-[opts]?*)  set -- "${1:0:2}" "-${1:2}" "${@:2}" ;;  # Won't loop!

# ✗ Pattern without ?* - matches single-char options unnecessarily
-[ovn]*)  # Matches -v even though no splitting needed

# ✗ Using external commands when pure bash suffices
$(grep -o . <<<"${1:1}")  # 50-100x slower than parameter expansion
```

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]?*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Use `continue` with iterative method
- [ ] Document options-with-arguments bundling limitations
- [ ] Test: single, bundled, mixed long/short, stacking (`-vvv`)
