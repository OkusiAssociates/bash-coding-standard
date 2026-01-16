## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory** for all scripts. Use `#shellcheck disable=...` only for documented exceptions.

```bash
# Run shellcheck as part of development workflow
shellcheck -x myscript.sh

# Document intentional violations with reason when necessary
#shellcheck disable=SC2155  # Declare and assign separately is less readable here
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

#### Script Termination
```bash
# Always end scripts with #fin (or #end) marker
main "$@"
#fin

```

#### Defensive Programming
```bash
# Default values for critical variables
: "${VERBOSE:=0}"
: "${DEBUG:=0}"

# Validate inputs early
[[ -n "$1" ]] || die 1 'Argument required'

# Guard against unset variables
set -u
```

#### Performance Considerations
```bash
# Minimize subshells
# Use built-in string operations over external commands
# Batch operations when possible
# Use process substitution over temp files
```

#### Testing Support
```bash
# Make functions testable
# Use dependency injection for external commands
# Support verbose/debug modes
# Return meaningful exit codes
```
