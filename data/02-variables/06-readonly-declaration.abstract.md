## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

**Anti-pattern:** Omitting `-r` on values that should never change â†' silent bugs from accidental reassignment.

**Ref:** BCS0206
