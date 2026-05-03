<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.7 Common optimisations

Patterns that reliably speed up scripts.

- Replace external commands with builtins (§19.10).
- Replace pipes with redirection where possible (§19.9).
- Avoid `$(…)` in tight loops.
- Use parameter expansion instead of `sed`/`awk` for simple substitutions (§19.8).
- Batch external calls: one `awk` over many lines vs many `awk`s over one line each.
- Use arrays instead of repeated string parsing.
- Use `mapfile` instead of `while read` loops.

#fin
