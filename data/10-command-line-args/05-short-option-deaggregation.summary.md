# Short-Option Disaggregation in Command-Line Processing Loops

## Overview

Short-option disaggregation splits bundled options (e.g., `-abc`) into individual options (`-a -b -c`) for processing in argument parsing loops, enabling Unix-standard commands like `script -vvn` instead of `script -v -v -n`.

**Why needed:** Without disaggregation, `-lha` is treated as unknown option rather than three options (`-l`, `-h`, `-a`). Makes scripts user-friendly and Unix-compliant.

## The Three Methods

### Method 1: grep (Current Standard)

```bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up aggregated short options
  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}"
  ;;
```

**How:** `${1:1}` removes dash ’ `grep -o .` outputs each char on separate line ’ `printf -- "-%c "` adds dash to each ’ `set --` replaces argument list.

**Pros:** Compact, well-tested, standard
**Cons:** External dependency, ~190 iter/sec, needs shellcheck disable
**Performance:** ~190 iterations/second

### Method 2: fold (Alternative)

```bash
-[amLpvqVh]*) #split up aggregated short options
  set -- '' $(printf -- "-%c " $(fold -w1 <<<"${1:1}")) "${@:2}"
  ;;
```

**How:** `fold -w1` wraps at 1-char width (splits each char to line) ’ `printf` adds dash ’ `set --` replaces args.

**Pros:** 3% faster than grep, semantically correct
**Cons:** External dependency, needs shellcheck disable
**Performance:** ~195 iterations/second

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

**How:** Extract string without dash ’ loop while characters remain ’ extract first char with dash, append to array ’ remove first char ’ replace argument list.

**Pros:** 68% faster (~318 iter/sec), no external deps, no shellcheck warnings, portable
**Cons:** More verbose (6 lines vs 1)
**Performance:** ~318 iterations/second

## Performance Comparison

| Method | Iter/Sec | Relative Speed | External Deps | Shellcheck |
|--------|----------|----------------|---------------|------------|
| grep | 190.82 | Baseline | grep | SC2046 disable |
| fold | 195.25 | +2.3% | fold | SC2046 disable |
| **Pure Bash** | **317.75** | **+66.5%** | **None** | **Clean** |

**Key:** Pure bash is 68% faster with zero dependencies.

## Implementation Examples

### Using grep (Current)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0
declare -- output_file=''
declare -a files=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($#>1)) && error "$@"; exit ${1:-0}; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

main() {
  while (($#)); do case $1 in
    -o|--output)    noarg "$@"; shift; output_file=$1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Short option bundling (grep)
    -[onvVh]*) #shellcheck disable=SC2046
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              files+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN output_file
  readonly -a files

  ((${#files[@]} > 0)) || die 2 'No input files specified'
  [[ -n "$output_file" ]] || die 2 'Output file required (use -o)'
}

main "$@"
#fin
```

### Using Pure Bash (Recommended)

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 PARALLEL=1
declare -- mode='normal'
declare -a targets=()

error() { >&2 echo "$SCRIPT_NAME: error: $*"; }
die() { (($#>1)) && error "$@"; exit ${1:-0}; }
noarg() { (($# > 1)) || die 2 "Option '$1' requires an argument"; }

main() {
  while (($#)); do case $1 in
    -m|--mode)      noarg "$@"; shift; mode=$1 ;;
    -j|--parallel)  noarg "$@"; shift; PARALLEL=$1 ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    -h|--help)      show_help; exit 0 ;;

    # Pure bash disaggregation
    -[mjvVh]*) # Split up single options (pure bash)
                    local -- opt=${1:1}
                    local -a new_args=()
                    while ((${#opt})); do
                      new_args+=("-${opt:0:1}")
                      opt=${opt:1}
                    done
                    set -- '' "${new_args[@]}" "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              targets+=("$1") ;;
  esac; shift; done

  readonly -- VERBOSE PARALLEL mode
  readonly -a targets

  ((${#targets[@]} > 0)) || die 2 'No targets specified'
  [[ "$mode" =~ ^(normal|fast|safe)$ ]] || die 2 "Invalid mode: '$mode'"
  ((PARALLEL > 0)) || die 2 'Parallel jobs must be positive'
}

main "$@"
#fin
```

## Usage Examples

```bash
# Single options
./script -v -v -n file.txt

# Bundled short options
./script -vvn file.txt

# Options with arguments at end of bundle
./script -vno output.txt file.txt  # ’ -v -n -o output.txt

# Long options work normally
./script --verbose --verbose --dry-run file.txt

# Mixed long and short
./script -vv --dry-run -o output.txt file.txt
```

## Edge Cases

### Options Requiring Arguments

Options with arguments cannot be in middle of bundle:

```bash
#  Correct - at end or separate
./script -vno output.txt file.txt    # -v -n -o output.txt
./script -vn -o output.txt file.txt  # -v -n -o output.txt

#  Wrong - in middle
./script -von output.txt file.txt    # -o captures "n" as argument!
```

**Solution:** Options with arguments should be at bundle end, separate, or use long-form.

### Character Set Validation

Pattern `-[amLpvqVh]*` explicitly lists valid options:

```bash
-[ovnVh]*)  # Only these short options valid

./script -xyz  # Doesn't match, caught by -*) case: "Invalid option '-xyz'"
```

Prevents incorrect disaggregation of unknown options.

## Implementation Checklist

- [ ] List all valid short options in pattern: `-[ovnVh]*`
- [ ] Place disaggregation case before `-*)` invalid option case
- [ ] Ensure `shift` at end of loop for all cases
- [ ] Document bundling limitations for options-with-arguments
- [ ] Add shellcheck disable for grep/fold methods
- [ ] Test: single, bundled, mixed long/short options
- [ ] Verify stacking behavior (e.g., `-vvv`)

## Recommendations

### For New Scripts

**Use Pure Bash (Method 3)**

**Reasons:** 68% faster, no external deps, no shellcheck warnings, portable

**Trade-off:** More verbose (6 lines vs 1)

### For Existing Scripts

**Keep grep unless:**
- Performance critical
- Called frequently
- External dependencies problematic
- Restricted environment

### For High-Performance Scripts

**Always use pure bash** when:
- Called in tight loops
- Part of build systems
- Interactive tools (completion, prompts)
- Container/restricted environments
- Called thousands of times per session

## Testing

```bash
# Basic tests
./script -v -v -n file.txt          # Single
./script -vvn file.txt              # Bundled
./script -vno output.txt file.txt  # With arguments
./script -xyz                       # Should error
./script -vvvvv                     # VERBOSE=5
```

## Conclusion

Pure bash method offers 68% performance improvement with zero dependencies while maintaining identical functionality. Recommended for all new scripts unless one-liner brevity is prioritized over performance.

#fin
