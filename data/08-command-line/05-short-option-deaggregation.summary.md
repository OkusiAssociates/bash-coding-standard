# Short-Option Disaggregation in Command-Line Processing

## Overview

Short-option disaggregation splits bundled options (`-abc`) into individual options (`-a -b -c`), enabling Unix-standard commands like `script -vvn` instead of `script -v -v -n`.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~190 iter/sec | Requires external `grep`, SC2046 disable

### Method 2: fold (Alternative)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046
  set -- '' $(printf -- '-%c ' $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**Performance:** ~195 iter/sec (+2.3%) | Still requires external command

### Method 3: Pure Bash (Recommended)

```bash
-[amLpvqVh]*) # Split up single options (pure bash)
  local -- opt=${1:1}
  local -a new_args=()
  while ((${#opt})); do
    new_args+=("-${opt:0:1}")
    opt=${opt:1}
  done
  set -- '' "${new_args[@]}" "${@:2}"
  ;;
```

**Performance:** ~318 iter/sec (**+68%**) | No external deps, no shellcheck warnings

## Performance Comparison

| Method | Iter/Sec | Speed | External Deps | Shellcheck |
|--------|----------|-------|---------------|------------|
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
}

main "$@"
#fin
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in middle of bundle:

```bash
# ✓ Correct - option with argument at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt

# ✗ Wrong - option with argument in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:
- Prevents incorrect disaggregation of unknown options
- Unknown options caught by `-*)` case
- Documents valid short options

```bash
./script -xyz  # Doesn't match pattern �' "Invalid option '-xyz'"
```

### Special Characters

All methods handle correctly: `-123` �' `-1 -2 -3`, `-v1n2` �' `-v -1 -n -2`

## Anti-Patterns

```bash
# ✗ Missing character set validation
-*)  # Catches everything including valid bundled options

# ✗ Placing disaggregation after invalid option catch
-*)             die 22 "Invalid option" ;;
-[ovnVh]*)      ...  # Never reached!

# ✗ Options with args in middle of bundle
./script -ovn output.txt  # -o captures "v" as value

# ✗ Using grep/fold when performance matters
# 68% slower than pure bash for frequently-called scripts
```

## Implementation Checklist

- [ ] List valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` happens at end of loop
- [ ] Document options-with-arguments bundling limitations
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single, bundled, mixed long/short, stacking (`-vvv`)

## Recommendations

**New Scripts:** Use pure bash method for 68% performance improvement, no external dependencies, no shellcheck warnings.

**Existing Scripts:** Keep grep unless performance critical, frequently called, or running in restricted environments.

**High-Performance Scripts:** Always use pure bash for scripts called in tight loops, build systems, interactive tools, or containers.

#fin
