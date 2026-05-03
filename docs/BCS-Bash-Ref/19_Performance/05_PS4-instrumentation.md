<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.5 `PS4` instrumentation

Customise `set -x` trace prefix.

- `PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:-main}: '` — file, line, function.
- `PS4='+[$EPOCHREALTIME] '` — timestamp each traced command.
- `PS4='+ ${BASH_SUBSHELL}: '` — subshell depth.
- Combinations: `'+[$EPOCHREALTIME ${BASH_SOURCE##*/}:${LINENO}] '`.
- Pitfall: `PS4` itself is expanded; `\033[…m` colour codes work but the leading `+ ` is added by bash.

#fin
