<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### continue
continue [n]

Resume the next iteration of the enclosing for, while, until, or select loop. If n is specified, resume at the nth enclosing loop. n must be >= 1. If n is greater than the number of enclosing loops, the outermost loop is resumed.

Returns 0 unless n is less than 1.
