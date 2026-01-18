## Readonly Declaration

**Use `declare -r` or `readonly` for constants to prevent accidental modification.**

```bash
declare -ar REQUIRED=(pandoc git md2ansi)
declare -r SCRIPT_PATH=$(realpath -- "$0")
```

Anti-pattern: Mutable constants → `CONST=value` without `-r` allows reassignment.

**Ref:** BCS0206
