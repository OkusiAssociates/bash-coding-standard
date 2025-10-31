## Debugging and Development

**Enable debugging features using `DEBUG` flag and enhanced trace mode.**

**Core pattern:**
```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '

debug() {
  ((DEBUG)) || return 0
  >&2 _msg "$@"
}
```

**Usage:** `DEBUG=1 ./script.sh`

**Key elements:**
- `set -x` ’ trace execution when `DEBUG=1`
- `PS4` ’ shows file:line:function in trace output
- `debug()` ’ conditional debug messages via stderr

**Ref:** BCS1401
