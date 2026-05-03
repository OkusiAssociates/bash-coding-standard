<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.7 The execution environment

The bundle of state that defines a command's runtime context.

- Variables.
- Functions.
- File descriptors.
- Traps.
- Working directory.
- Umask.
- Signal mask.
- Resource limits.
- Subshells inherit (almost) everything; some elements reset (caught signals, DEBUG/ERR/RETURN traps without `-T`/`-E`).

#fin
