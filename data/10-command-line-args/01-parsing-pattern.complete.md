### Standard Argument Parsing Pattern

**Complete pattern with short option support:**

\`\`\`bash
while (($#)); do case $1 in
  -a|--add)       noarg "$@"; shift
                  process_argument "$1" ;;
  -m|--depth)     noarg "$@"; shift
                  max_depth="$1" ;;
  -L|--follow-symbolic)
                  symbolic='-L' ;;

  -p|--prompt)    PROMPT=1; VERBOSE=1 ;;
  -v|--verbose)   VERBOSE+=1 ;;

  -q|--quiet)     VERBOSE=0 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;

  -h|--help)      show_help; exit 0 ;;
  -[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
\`\`\`

**Pattern breakdown and rationale:**

**1. Loop structure: `while (($#)); do ... done`**
- `(($#))` - Arithmetic test, true while arguments remain
- More efficient than `while [[ $# -gt 0 ]]`
- Exits when no arguments left

**2. Case statement: `case $1 in ... esac`**
- Matches current argument (`$1`) against patterns
- Supports multiple patterns per branch: `-a|--add`
- More readable than nested if/elif chains

**3. Options with arguments:**
\`\`\`bash
-m|--depth)     noarg "$@"; shift
                max_depth="$1" ;;
\`\`\`
- `noarg "$@"` - Validates argument exists (prevents "missing argument" errors)
- `shift` - Moves to next argument (the value)
- `max_depth="$1"` - Captures the value
- Second `shift` at end of loop moves past the value

**4. Options without arguments (flags):**
\`\`\`bash
-p|--prompt)    PROMPT=1; VERBOSE=1 ;;
-v|--verbose)   VERBOSE+=1 ;;
\`\`\`
- Just set variables, no shift needed (handled at loop end)
- Can set multiple variables per option
- `VERBOSE+=1` allows stacking: `-vvv` = `VERBOSE=3`

**5. Options that exit immediately:**
\`\`\`bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
-h|--help)      show_help; exit 0 ;;
\`\`\`
- Print information and exit
- No shift needed (script exits)
- Use `exit 0` (success exit code)

**6. Short option bundling:**
\`\`\`bash
-[amLpvqVh]*) #shellcheck disable=SC2046 #split up single options
              set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
\`\`\`
- **Purpose**: Allows `-vpL` instead of `-v -p -L`
- **Pattern**: `-[amLpvqVh]*` matches any short option combination
- **Mechanism**: Splits bundled options into separate arguments
- **Example**: `-vpL file` becomes `-v -p -L file`
- **How it works:**
  1. `${1:1}` - Remove leading dash (e.g., `-vpL` → `vpL`)
  2. `grep -o .` - Split into individual characters
  3. `printf -- "-%c "` - Add dash before each character
  4. `set --` - Replace argument list with expanded options

**7. Invalid option handling:**
\`\`\`bash
-*)             die 22 "Invalid option '$1'" ;;
\`\`\`
- Catches any unrecognized option starting with `-`
- Uses exit code 22 (EINVAL - invalid argument)
- Shows which option was invalid

**8. Positional arguments:**
\`\`\`bash
*)              Paths+=("$1") ;;
\`\`\`
- Default case: Not an option, must be positional argument
- Append to array for later processing
- Allows unlimited positional arguments

**9. Mandatory shift at end:**
\`\`\`bash
esac; shift; done
\`\`\`
- `shift` after every iteration moves to next argument
- Critical: Without this, infinite loop!
- Placed after `esac` to handle all branches uniformly

**The `noarg` helper function:**

\`\`\`bash
noarg() {
  (($# > 1)) || die 2 "Option '$1' requires an argument"
}
\`\`\`

- **Purpose**: Validates that option requiring an argument has one
- **Check**: `(($# > 1))` - At least 2 args (option + value)
- **Usage**: Always call before shifting to capture argument value
- **Example**: `./script -m` (missing value) → "Option '-m' requires an argument"

**Complete example with all features:**

\`\`\`bash
#!/usr/bin/env bash
set -euo pipefail

VERSION='1.0.0'
SCRIPT_NAME=$(basename "$0")

# Helper function
noarg() {
  (($# > 1)) || die 2 "Option '$1' requires an argument"
}

# Default values
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -- output_file=''
declare -a files=()

# Parse arguments
while (($#)); do case $1 in
  -o|--output)    noarg "$@"; shift
                  output_file=$1 ;;
  -v|--verbose)   VERBOSE+=1 ;;
  -n|--dry-run)   DRY_RUN=1 ;;
  -V|--version)   echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
  -h|--help)      show_help; exit 0 ;;

  # Short option bundling support
  -[ovnVh]*)    #shellcheck disable=SC2046
                  set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              files+=("$1") ;;
esac; shift; done

# Validate required arguments
((${#files[@]} > 0)) || die 2 'No input files specified'
[[ -n "$output_file" ]] || die 2 'Output file required (use -o)'

# Use parsed arguments
((VERBOSE)) && echo "Processing ${#files[@]} files"
((DRY_RUN)) && echo '[DRY RUN] Would write to:' "$output_file"
\`\`\`

**Short option bundling examples:**

\`\`\`bash
# These are equivalent:
./script -v -n -o output.txt file.txt
./script -vno output.txt file.txt

# These are equivalent:
./script -v -v -v file.txt
./script -vvv file.txt

# Mixed long and short:
./script --verbose -no output.txt --dry-run file.txt
\`\`\`

**Anti-patterns to avoid:**

\`\`\`bash
# ✗ Wrong - using while [[ ]] instead of (())
while [[ $# -gt 0 ]]; do  # Verbose, less efficient

# ✓ Correct
while (($#)); do

# ✗ Wrong - not calling noarg before shift
-o|--output)    shift
                output_file=$1 ;;  # Fails if no argument!

# ✓ Correct
-o|--output)    noarg "$@"; shift
                output_file=$1 ;;

# ✗ Wrong - forgetting shift at loop end
while (($#)); do case $1 in
  ...
esac; done  # Infinite loop!

# ✓ Correct
while (($#)); do case $1 in
  ...
esac; shift; done

# ✗ Wrong - using if/elif chains instead of case
if [[ "$1" == '-v' ]] || [[ "$1" == '--verbose' ]]; then
  VERBOSE+=1
elif [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
  show_help
  ...
fi

# ✓ Correct - use case statement
case $1 in
  -v|--verbose) VERBOSE+=1 ;;
  -h|--help)    show_help; exit 0 ;;
  ...
esac
\`\`\`

**Rationale for this pattern:**

1. **Consistent**: Same structure works for all scripts
2. **Flexible**: Handles options with/without arguments, bundled shorts
3. **Safe**: Validates arguments exist before using them
4. **Readable**: Case statement is more scannable than if/elif chains
5. **Efficient**: Arithmetic test `(($#))` faster than `[[ ]]`
6. **Standard**: Follows Unix conventions (short/long options, bundling)
