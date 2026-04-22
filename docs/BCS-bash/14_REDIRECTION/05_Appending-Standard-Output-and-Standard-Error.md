<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Appending Standard Output and Standard Error

This construct appends both standard output (file descriptor 1) and standard error (file descriptor 2) to the file whose name is the expansion of word.

The format is:

 &>>word

This is semantically equivalent to

 >>word 2>&1
