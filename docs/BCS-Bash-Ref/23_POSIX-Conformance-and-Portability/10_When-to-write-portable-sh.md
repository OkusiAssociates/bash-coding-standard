<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.10 When to write portable sh

Cases where POSIX-only is the right choice.

- `/bin/sh` scripts in OS init / packaging.
- Build scripts that run before bash is available.
- Embedded systems with only ash/dash.
- Legacy Unix support.
- Most cases: write bash, require bash, document the requirement.

#fin
