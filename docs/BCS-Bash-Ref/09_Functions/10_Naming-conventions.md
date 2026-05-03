<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.10 Naming conventions

Convention shapes maintainability. BCS-aligned conventions.

- Lowercase with underscores: `process_file`, `read_config`.
- Private functions prefixed with `_`: `_internal_helper`.
- Library namespaces: `mylib::function` (Bash supports `::` in function names).
- Avoid clashing with builtins (`test`, `read`, `printf`).
- Avoid one-letter names (debugging difficulty).
- Action verb + noun: `validate_input`, `parse_args`, `emit_report`.
- BCS messaging helpers: `info()`, `success()`, `warn()`, `error()`, `die()`.

#fin
