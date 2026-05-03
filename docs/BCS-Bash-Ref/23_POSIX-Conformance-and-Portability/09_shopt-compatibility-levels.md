<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.9 `shopt` compatibility levels

Bash supports limited backward compatibility via `shopt -s compatNN`.

- `compat31`, `compat32`, … `compat51` — emulate that version's behaviour.
- Used for legacy scripts that depend on quirks.
- BCS recommends not using these — fix the script.
- Removed: bash 5.2+ may drop the oldest levels.

#fin
