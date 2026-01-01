## Debugging

**Enable debug mode via environment variable with `set -x` trace and enhanced PS4.**

```bash
declare -i DEBUG="${DEBUG:-0}"
((DEBUG)) && set -x ||:
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}():} '
```

**Why:** PS4 shows file:line:function for trace output â†' `DEBUG=1 ./script.sh`

**Anti-pattern:** Hardcoded debug flags â†' use environment variable

**Ref:** BCS1207
