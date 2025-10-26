## Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git md2ansi)
readonly -- SCRIPT_PATH="$(realpath -- "$0")"
```

**Ref:** BCS0206
