# Short-Option Disaggregation in Command-Line Processing

## Overview

Short-option disaggregation splits bundled options (`-abc`) into individual options (`-a -b -c`), enabling Unix-standard usage like `script -vvn` instead of `script -v -v -n`.

## Method 1: Iterative Parameter Expansion (Recommended)

```bash
case $1 in
  -[amLpvqVh]?*)  # Bundled short options
    set -- "${1:0:2}" "-${1:2}" "${@:2}"
    continue
    ;;
esac
```

**How it works:**
1. Pattern `-[opts]?*` matches option with additional characters after first option
2. `${1:0:2}` extracts first option (`-v` from `-vvn`)
3. `"-${1:2}"` creates remaining options with dash (`-vn` from `-vvn`)
4. `${@:2}` preserves remaining arguments
5. `continue` restarts loop; terminates naturally when no bundled options remain

**Advantages:** 53-119x faster (~24,000-53,000 iter/sec), no external dependencies, no shellcheck warnings, compact one-liner.

**Limitation:** Requires `continue` (not all loop structures support this).

## Method 2: grep (Alternative)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
    set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}" ;;
```

**Performance:** ~445 iter/sec. Requires external `grep`, SC2046 disable.

## Method 3: fold (Alternative)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
    set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}" ;;
```

**Performance:** ~460 iter/sec (~3% faster than grep). Requires external `fold`, SC2046 disable.

## Method 4: Pure Bash Loop (Alternative for Complex Cases)

```bash
-[amLpvqVh]*) # Split up single options (pure bash loop)
    local -- opt=${1:1}
    local -a new_args=()
    while ((${#opt})); do
      new_args+=("-${opt:0:1}")
      opt=${opt:1}
    done
    set -- '' "${new_args[@]}" "${@:2}" ;;
```

**Performance:** ~318 iter/sec. No external deps, no shellcheck warnings, but more verbose. Superseded by Method 1.

## Performance Comparison

| Method | Iter/Sec | Relative Speed | External Deps | Shellcheck |
|--------|----------|----------------|---------------|------------|
| **Iterative (recommended)** | **~24,000-53,000** | **53-119x faster** | **None** | **Clean** |
| grep | ~445 | Baseline | grep | SC2046 disable |
| fold | ~460 | +3% | fold | SC2046 disable |
| Pure Bash Loop | ~318 | -29% | None | Clean |

## Complete Implementation Example

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

  local -- file
  for file in "${files[@]}"; do
    ((VERBOSE > 1)) && echo "Processing ${file@Q}"
  done
}

main "$@"
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in the middle of a bundle:

```bash
# ✓ Correct - option with argument at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt

# ✗ Wrong - option with argument in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

**Solution:** Document that options requiring arguments should be placed at end of bundle, used separately, or use long-form (`--output`).

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:
- Prevents incorrect disaggregation of unknown options
- Unknown options caught by `-*)` case
- Documents valid short options

```bash
-[ovnVh]*)  # Only -o -v -n -V -h are valid short options

./script -xyz  # Doesn't match pattern, caught by -*) case
               # Error: Invalid option '-xyz'
```

### Special Characters

Bash parameter expansion handles special characters correctly:
- Digits: `-123` → `-1 -2 -3`
- Letters: `-abc` → `-a -b -c`
- Mixed: `-v1n2` → `-v -1 -n -2`

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` happens at end of loop for all cases
- [ ] Document options-with-arguments bundling limitations
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single options, bundled options, mixed long/short, stacking (`-vvv`)

## Usage Examples

```bash
# Single options
./script -v -v -n file.txt

# Bundled short options
./script -vvn file.txt

# Mixed bundled and separate
./script -vv -n file.txt

# Options with arguments
./script -vno output.txt file.txt  # -v -n -o output.txt

# Long options
./script --verbose --verbose --dry-run file.txt
```

## Recommendations

**Use Iterative Parameter Expansion (Method 1) for all scripts.** It offers 53-119x faster performance, no external dependencies, no shellcheck warnings, and compact one-liner implementation.

**Consider grep/fold methods only when:**
1. Loop structure doesn't support `continue`
2. Need to expand all options at once
3. Working with legacy code already using them
