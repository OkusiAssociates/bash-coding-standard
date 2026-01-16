## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory** for all scripts. Use `#shellcheck disable=...` only for documented exceptions.

```bash
shellcheck -x myscript.sh

#shellcheck disable=SC2155  # Declare and assign separately is less readable here
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

#### Script Termination
```bash
main "$@"
#fin
```

#### Defensive Programming
```bash
: "${VERBOSE:=0}"
: "${DEBUG:=0}"
[[ -n "$1" ]] || die 1 'Argument required'
set -u
```

#### Performance Considerations
- Minimize subshells; prefer built-in string operations over external commands
- Batch operations; use process substitution over temp files

#### Testing Support
- Make functions testable with dependency injection
- Support verbose/debug modes; return meaningful exit codes
