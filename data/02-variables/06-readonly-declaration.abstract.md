## Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155
readonly -- SCRIPT_PATH=$(realpath -- "$0")
```

**Ref:** BCS0206
