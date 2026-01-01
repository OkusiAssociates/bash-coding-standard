## Development Practices

**ShellCheck is compulsory; document all `disable=` directives with rationale. End scripts with `#fin` marker.**

### Core Patterns

```bash
#shellcheck disable=SC2046  # Intentional word splitting
shellcheck -x myscript.sh   # Run during development

: "${VERBOSE:=0}"           # Default critical vars
[[ -n "$1" ]] || die 1 'Argument required'
set -u                      # Guard unset variables

main "$@"
#fin
```

### Performance & Testing

- Minimize subshells; prefer builtins over external commands
- Use process substitution over temp files
- Return meaningful exit codes; support debug modes

`undocumented disable=` â†' silent violations | missing `#fin` â†' incomplete script

**Ref:** BCS1206
