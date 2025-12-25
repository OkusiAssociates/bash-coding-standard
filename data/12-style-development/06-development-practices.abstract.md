## Development Practices

**ShellCheck is compulsory.** Document all `#shellcheck disable=SCxxxx` directives with reasons.

```bash
#shellcheck disable=SC2046  # Intentional word splitting for flag expansion
```

**End scripts with `#fin` marker** (mandatory).

```bash
main "$@"
#fin
```

**Defensive patterns:** Set defaults with `: "${VAR:=default}"`, validate inputs early (`[[ -n "$1" ]] || die 1 'Required'`), use `set -u`.

**Performance:** Minimize subshells, use built-in string ops over external commands, prefer process substitution over temp files.

**Testing:** Make functions testable, use dependency injection, support verbose/debug modes, return meaningful exit codes.

**Ref:** BCS1306
