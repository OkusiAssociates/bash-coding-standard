<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.7 Quoting under `set -u`

Quoted unset variables expand to nothing; unquoted may error.

- `"$var"` — expands to empty string if unset (under `set -u`, errors).
- `"${var:-}"` — explicitly default to empty.
- For optional args: `"${1:-}"`.
- For arrays that may be empty: `"${arr[@]:-}"`.
- BCS pattern: declare every variable with `declare` to avoid `set -u` traps (BCS0201).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: argv parser that survives empty argv under set -u
declare -- mode=''
declare -i verbose=0
declare -a files=()

while (($#)); do
  case "${1:-}" in
    -v|--verbose) verbose=1 ;;
    -m|--mode)    shift; mode="${1:?--mode requires an argument}" ;;
    --)           shift; files+=( "${@:-}" ); break ;;
    -*)           printf >&2 'unknown: %s\n' "$1"; exit 22 ;;
    *)            files+=( "$1" ) ;;
  esac
  shift
done

# right — guard array expansion so the loop body is reached even when files is empty
for f in "${files[@]:-}"; do
  [[ -n "$f" ]] || continue
  printf 'process: %s\n' "$f"
done

#fin
```

Three pattern points: `"${1:-}"` in `case` keeps the parser alive when
`$#` is zero; `"${1:?msg}"` after `shift` enforces a required argument
with a tailored error; `"${arr[@]:-}"` lets `for` survive an empty array
under `set -u`. Without the `:-` defaults, each of these would trip a
`unbound variable` exit before your error message ran.

**See also**: §20.6 (input validation), BCS0101 (strict mode), BCS0201 (declarations).

#fin
