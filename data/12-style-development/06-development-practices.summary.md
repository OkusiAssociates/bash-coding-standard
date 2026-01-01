## Development Practices

#### ShellCheck Compliance
ShellCheck is **compulsory**. Document exceptions with `#shellcheck disable=...` and reason:

```bash
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
set -- '' $(printf -- '-%c ' $(grep -o . <<<"${1:1}")) "${@:2}"

shellcheck -x myscript.sh
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
Minimize subshells; prefer built-in string operations; batch operations; use process substitution over temp files.

#### Testing Support
Make functions testable with dependency injection, verbose/debug modes, and meaningful exit codes.
