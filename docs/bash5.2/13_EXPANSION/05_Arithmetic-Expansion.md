### Arithmetic Expansion

Arithmetic expansion allows the evaluation of an arithmetic expression and the substitution of the result.
The format for arithmetic expansion is:

 $((expression))

The old format $[expression] is deprecated and will be removed in upcoming versions of bash.

The expression undergoes the same expansions as if it were within double quotes, but double quote characters
in expression are not treated specially and are removed. All tokens in the expression undergo parameter and
variable expansion, command substitution, and quote removal.  The result is treated as the arithmetic
expression to be evaluated.  Arithmetic expansions may be nested.

The evaluation is performed according to the rules listed below under ARITHMETIC EVALUATION.  If expression is
invalid, bash prints a message indicating failure and no substitution occurs.

