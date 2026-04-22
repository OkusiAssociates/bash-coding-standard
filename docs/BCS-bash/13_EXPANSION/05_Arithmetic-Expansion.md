<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Arithmetic Expansion

Arithmetic expansion evaluates an expression and substitutes the result:

 $((expression))

The expression undergoes parameter and variable expansion, command substitution, and quote removal. Double quote characters within the expression are not treated specially and are removed. The result is evaluated as an arithmetic expression. Arithmetic expansions may be nested.

Evaluation follows the rules described under ARITHMETIC EVALUATION. If the expression is invalid, bash prints an error and no substitution occurs.
