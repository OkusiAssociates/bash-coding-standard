## Readonly Declaration
Use `declare -r` or `readonly` for constants to prevent accidental modification.

```bash
declare -ra REQUIRED=(pandoc git md2ansi)
#shellcheck disable=SC2155 # acceptable; if realpath fails then we have much bigger problems
declare -r SCRIPT_PATH=$(realpath -- "$0")
```
