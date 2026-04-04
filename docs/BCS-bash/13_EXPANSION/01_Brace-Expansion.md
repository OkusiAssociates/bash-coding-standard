### Brace Expansion

Brace expansion generates arbitrary strings. A pattern takes the form of an optional preamble, followed by either a series of comma-separated strings or a sequence expression between a pair of braces, followed by an optional postscript. The preamble is prefixed to each string within the braces, and the postscript is appended to each resulting string, expanding left to right.

Brace expansions may be nested. Results are not sorted; left to right order is preserved. For example, a{d,c,b}e expands into ade ace abe.

A sequence expression takes the form {x..y[..incr]}, where x and y are either integers or single letters, and incr, an optional increment, is an integer. When integers are supplied, the expression expands to each number between x and y, inclusive. Supplied integers may be prefixed with 0 to force each term to have the same width. When either x or y begins with a zero, the shell attempts to force all generated terms to contain the same number of digits, zero-padding where necessary. When letters are supplied, the expression expands to each character lexicographically between x and y, inclusive, using the default C locale. Both x and y must be of the same type (integer or letter). When the increment is supplied, it is used as the difference between each term. The default increment is 1 or -1 as appropriate.

Brace expansion is performed before any other expansions, and characters special to other expansions are preserved in the result. It is strictly textual. Bash does not apply any syntactic interpretation to the context of the expansion or the text between the braces.

A correctly-formed brace expansion must contain unquoted opening and closing braces, and at least one unquoted comma or a valid sequence expression. Any incorrectly formed brace expansion is left unchanged. A { or , may be quoted with a backslash to prevent its being considered part of a brace expression. To avoid conflicts with parameter expansion, the string ${ is not considered eligible for brace expansion, and inhibits brace expansion until the closing }.

This construct is typically used as shorthand when the common prefix of the strings to be generated is longer than in the example:

 mkdir /usr/local/src/bash/{old,new,dist,bugs}
or
 chown root /usr/{ucb/{ex,edit},lib/{ex?.?*,how_ex}}
