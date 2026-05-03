<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.6 The trap table

Per-shell table mapping signals to handler strings.

- Indexed by signal number.
- Inherited at fork; reset (for caught signals) at exec.
- `trap` builtin reads/writes this table.
- Pseudo-signals (EXIT, ERR, DEBUG, RETURN) have separate slots.

#fin
