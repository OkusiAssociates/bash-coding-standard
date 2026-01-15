## Debugging

**Use environment-controlled debug mode with enhanced trace output.**

**Rationale:** Environment variable control allows runtime debugging without code changes; enhanced PS4 provides file:line:function context.

```bash
declare -i DEBUG=${DEBUG:-0}
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
```

**Anti-pattern:** Hardcoded debug flags â†' use `DEBUG=${DEBUG:-0}` for runtime control.

**Ref:** BCS1207
