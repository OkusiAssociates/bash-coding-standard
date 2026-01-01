## Debugging and Development

Enable debugging via environment variables and trace mode.

```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}
# Usage: DEBUG=1 ./script.sh
```
