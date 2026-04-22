<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Redirecting Standard Output and Standard Error

This construct redirects both standard output (file descriptor 1) and standard error (file descriptor 2) to the file whose name is the expansion of word.

There are two formats:

 &>word
and
 >&word

The first form is preferred. This is semantically equivalent to

 >word 2>&1

When using the second form, word may not expand to a number or -. If it does, other redirection operators apply (see Duplicating File Descriptors) for compatibility reasons.
