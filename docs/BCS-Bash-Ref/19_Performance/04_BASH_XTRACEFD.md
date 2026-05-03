<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.4 `BASH_XTRACEFD`

Redirect `set -x` output to a specific fd.

- `exec 3>>trace.log` then `BASH_XTRACEFD=3` — trace to file, not stderr.
- Keeps trace out of the script's user-facing output.
- Combine with `PS4` for rich context (§19.5).
- Available since Bash 4.1.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: timestamped trace to a file, no noise on stderr
exec 3>>"$HOME/trace.$$.log"
export BASH_XTRACEFD=3
export PS4='+ $EPOCHREALTIME ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main} '
set -x

build_index() { :; }
process_data() { :; }

build_index
process_data

# release the fd; trap covers abort paths
cleanup() { exec 3>&-; }
trap cleanup EXIT

#fin
```

The `exec 3>>…` opens a writable fd; `BASH_XTRACEFD=3` retargets the trace
stream so `>&2` user diagnostics stay clean. The `cleanup` trap (BCS0603,
BCS0110) closes the fd on every exit path.

**See also**: §19.5 (PS4 instrumentation), §19.2 (profiling), BCS0110 (cleanup), BCS0603 (traps).

#fin
