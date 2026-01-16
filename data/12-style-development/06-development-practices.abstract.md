## Development Practices

**ShellCheck mandatory; end scripts with `#fin`; program defensively.**

### ShellCheck
- **Compulsory** for all scripts: `shellcheck -x script.sh`
- Disable only with documented reason: `#shellcheck disable=SC2155  # reason`

### Script Termination
```bash
main "$@"
#fin
```

### Defensive Programming
```bash
: "${VERBOSE:=0}"              # Default values
[[ -n "$1" ]] || die 1 'Arg required'  # Validate early
set -u                         # Guard unset vars
```

### Performance
Minimize subshells â†' use builtins over external commands â†' batch ops â†' process substitution over temp files.

### Testing
Testable functions, dependency injection, verbose/debug modes, meaningful exit codes.

**Ref:** BCS1206
