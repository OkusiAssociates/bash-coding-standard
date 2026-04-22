<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### shift
shift [n]

The positional parameters from n+1 onward are renamed to $1 and so on. Parameters represented by $# down to $#-n+1 are unset. n must be a non-negative number less than or equal to $#. If n is 0, no parameters are changed. If n is not given, it defaults to 1. If n is greater than $#, the positional parameters are not changed.

Returns non-zero if n is greater than $# or less than zero; otherwise 0.
