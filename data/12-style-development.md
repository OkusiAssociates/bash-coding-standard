# Section 12: Style & Development

## BCS1200 Section Overview

Code formatting, comments, development practices, debugging, dry-run patterns, and testing support. These conventions ensure consistent, maintainable scripts.

## BCS1201 Code Formatting

```
- 2 spaces for indentation (never tabs)
- Lines under 100 characters (except URLs/paths)
- Use \ for line continuation
```

## BCS1202 Comments

Focus on WHY, not WHAT.

```bash
# correct — explains non-obvious decisions
# PROFILE_DIR hardcoded to /etc/profile.d for system-wide bash integration
declare -r PROFILE_DIR=/etc/profile.d

# correct — documents gotcha
# readarray quirk: single empty element means no results
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0

# wrong — restates the code
# Set verbose to 1
VERBOSE=1
# Check if file exists
[[ -f "$file" ]]
```

Use standard documentation icons: `◉` (info), `⦿` (debug), `▲` (warn), `✓` (success), `✗` (error).

## BCS1203 Blank Lines

- One blank line between functions
- One blank line between logical sections within functions
- One blank line after section comments
- Blank lines before and after multi-line blocks
- Never multiple consecutive blank lines
- No blank lines between short, related statements

## BCS1204 Section Comments

```bash
# correct — lightweight, 2-4 words
# Default values
declare -i VERBOSE=1 DEBUG=0

# Derived paths
declare -- BIN_DIR="$PREFIX"/bin

# Core message function
_msg() { :; }

# wrong — heavy box drawing
#############################
# Default values            #
#############################
```

Reserve 80-dash separators for major script divisions only.

## BCS1205 Language Best Practices

Prefer shell builtins over external commands (10-100x faster).

```bash
# correct — builtins
$((x + y))                          # not $(expr $x + $y)
${path##*/}                         # not $(basename "$path")
${path%/*}                          # not $(dirname "$path")
${var^^}                            # not $(echo "$var" | tr a-z A-Z)
${var,,}                            # not $(echo "$var" | tr A-Z a-z)
[[ condition ]]                     # not [ condition ] or test
var=$(command)                      # not var=`command`
{1..10}                             # not $(seq 1 10)
```

## BCS1206 Static Analysis Directives

ShellCheck compliance is compulsory. Use `#shellcheck disable=SCxxxx` only for documented exceptions. Similarly, use `#bcscheck disable=BCSxxxx` to suppress specific BCS rules on the next line.

```bash
# correct — documented shellcheck exception
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")

# correct — documented bcscheck exception
#bcscheck disable=BCS0606
((DRY_RUN)) && info 'Dry-run mode'
```

Always end scripts with `#fin` after `main "$@"`.

Use defensive programming:

```bash
: "${VERBOSE:=0}"                    # default critical variables
[[ -n "$1" ]] || die 2 'Argument required'
```

Minimize subshells, use built-in string operations, batch operations, use process substitution over temp files.

## BCS1207 Debugging

```bash
# correct
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:

# enhanced trace output
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

# debug function
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }

# runtime activation
DEBUG=1 ./script.sh
```

## BCS1208 Dry-Run Pattern

```bash
# correct
declare -i DRY_RUN=0
# parse: -n|--dry-run) DRY_RUN=1 ;;

deploy() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would deploy to production'
    return 0
  fi
  # actual deployment
}
```

Dry-run maintains identical control flow (same function calls, same logic paths) to verify logic without side effects. Show detailed preview of what would happen with `[DRY-RUN]` prefix.

## BCS1209 Testing Support

```bash
# correct — dependency injection
declare -f FIND_CMD >/dev/null || FIND_CMD() { find "$@"; }
# override in tests: FIND_CMD() { echo 'mocked_file.txt'; }

# correct — test mode flag
declare -i TEST_MODE=${TEST_MODE:-0}

# correct — assert function
assert() {
  local -- expected=$1 actual=$2 msg=${3:-assertion}
  [[ "$expected" == "$actual" ]] || {
    error "FAIL: $msg: expected ${expected@Q}, got ${actual@Q}"
    return 1
  }
}

# correct — test runner
run_tests() {
  local -i passed=0 failed=0
  local -- fn
  while IFS= read -r _ _ fn; do
    if "$fn"; then
      passed+=1
    else
      failed+=1
    fi
  done < <(declare -F | grep 'test_')
  echo "Passed: $passed, Failed: $failed"
  ((failed == 0))
}
```

## BCS1210 Progressive State Management

Separate user intent from runtime state.

```bash
# correct
declare -i BUILTIN_REQUESTED=1       # user asked for it
declare -i INSTALL_BUILTIN=0         # what will actually happen

# validate prerequisites
if ((BUILTIN_REQUESTED)); then
  if build_builtin; then
    INSTALL_BUILTIN=1
  else
    warn 'Builtin build failed, skipping'
  fi
fi

# execute based on final state
((INSTALL_BUILTIN)) && install_builtin ||:
```

Apply state changes in logical order: parse, validate, execute. Never modify flags during execution phase.

## BCS1211 Utility Functions

Common helper functions:

```bash
# Argument validation
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

# Trim whitespace
trim() { local -- v="$*"; v="${v#"${v%%[![:blank:]]*}"}"; echo -n "${v%"${v##*[![:blank:]]}"}" ; }

# Debug variable display
decp() { declare -p "$@" 2>/dev/null | sed 's/^declare -[a-zA-Z-]* //'; }

# Pluralization
s() { (( ${1:-1} == 1 )) || echo -n 's'; }
```
