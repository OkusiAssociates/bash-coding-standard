## Readonly Declaration

**Use `readonly` for constants to prevent accidental modification.**

```bash
readonly -a REQUIRED=(pandoc git)
readonly -- SCRIPT_PATH=$(realpath -- "$0")
```

**Anti-pattern:** Omitting `readonly` for values that should never change â†' silent bugs from accidental overwrites.

**Ref:** BCS0206
