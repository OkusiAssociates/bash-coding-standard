<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.10 Arithmetic operators and precedence

Bash arithmetic supports a rich operator set with C-like precedence. Full table is in Appendix H; this is the structural overview.

- Unary: `++`, `--` (pre and post), `+`, `-`, `!`, `~`.
- Multiplicative: `*`, `/`, `%`.
- Additive: `+`, `-`.
- Shift: `<<`, `>>`.
- Comparison: `<`, `<=`, `>`, `>=`.
- Equality: `==`, `!=`.
- Bitwise: `&`, `^`, `|`.
- Logical: `&&`, `||`.
- Conditional: `cond ? then : else`.
- Assignment: `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`.
- Comma: `,` — evaluate left, return right.
- Exponentiation: `**`.

#fin
