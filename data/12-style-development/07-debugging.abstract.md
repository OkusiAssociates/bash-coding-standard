## Debugging and Development

**Use `DEBUG` env var with `set -x` and enhanced `PS4` for trace debugging.**

```bash
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
```

**Anti-patterns:** Hardcoded debug flags → use env var; bare `set -x` → loses context without PS4

**Ref:** BCS1207
