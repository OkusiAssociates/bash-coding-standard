# Short-Option Disaggregation

## Overview

Splits bundled short options (e.g., `-abc`) into individual options (`-a -b -c`) for processing. Enables `script -vvn` instead of `script -v -v -n`, following Unix conventions.

Without disaggregation, `-lha` is treated as unknown single option rather than `-l -h -a`.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**How it works:** `${1:1}` removes leading dash â†' `grep -o .` outputs each char on separate line â†' `printf -- "-%c "` prepends dash â†' `set --` replaces argument list.

**Performance:** ~190 iter/sec | External dep: grep | Requires SC2046 disable

### Method 2: fold

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~195 iter/sec (+2.3%) | External dep: fold | Requires SC2046 disable

### Method 3: Pure Bash (Recommended for Performance)

```bash
-[mjvqVh]*) # Split up single options (pure bash)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}" ;;
```

**Performance:** ~318 iter/sec (+68%) | No external deps | No shellcheck warnings

## Performance Comparison

| Method | Iter/Sec | Relative | External Deps | Shellcheck |
|--------|----------|----------|---------------|------------|
| grep | 190.82 | Baseline | grep | SC2046 |
| fold | 195.25 | +2.3% | fold | SC2046 |
| **Pure Bash** | **317.75** | **+66.5%** | **None** | **Clean** |

## Complete Implementation Example (Pure Bash)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0
declare -i PARALLEL=1
declare -- mode='normal'
declare -a targets=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

show_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS] TARGET...

Options:
  -m, --mode MODE    Processing mode (normal|fast|safe)
  -j, --parallel N   Number of parallel jobs (default: 1)
  -v, --verbose      Verbose output (stackable)
  -q, --quiet        Quiet mode
  -V, --version      Show version
  -h, --help         Show this help
EOF
}

main() {
  while (($#)); do case $1 in
    -m|--mode)      noarg "$@"; shift; mode=$1 ;;
    -j|--parallel)  noarg "$@"; shift; PARALLEL=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -q|--quiet)     VERBOSE=0 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Short option bundling (pure bash)
    -[mjvqVh]*) local -- opt=${1:1}
                local -a new_args=()
                while ((${#opt})); do
                  new_args+=("-${opt:0:1}")
                  opt=${opt:1}
                done
                set -- '' "${new_args[@]}" "${@:2}" ;;
    -*)         die 22 "Invalid option '$1'" ;;
    *)          targets+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE PARALLEL mode
  readonly -a targets

  ((${#targets[@]} > 0)) || die 2 'No targets specified'
  [[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"
  ((PARALLEL > 0)) || die 2 'Parallel jobs must be positive'

  local -- target
  for target in "${targets[@]}"; do
    ((VERBOSE)) && echo "Processing '$target'"
  done
}

main "$@"
#fin
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be mid-bundle:

```bash
# âœ“ Correct - argument option at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt

# âœ— Wrong - argument option in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:
- Prevents disaggregation of unknown options
- Unknown options caught by `-*)` case
- Documents valid short options

```bash
-[ovnVh]*)  # Only these are valid short options

./script -xyz  # Doesn't match, caught by -*) â†' Error: Invalid option '-xyz'
```

### Special Characters

All methods handle correctly: digits (`-123` â†' `-1 -2 -3`), letters, mixed (`-v1n2` â†' `-v -1 -n -2`).

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` at end of loop for all cases
- [ ] Document options-with-arguments bundling limitations
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single options, bundled, mixed long/short, stacking (`-vvv`)

## Recommendations

**Use grep method** unless:
- Performance is critical (loops, build systems, interactive tools)
- External dependencies are a concern
- Running in restricted environments

**Use Pure Bash** for high-performance scripts called frequently or in containers.
