<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Moving File Descriptors

The redirection operator

 [n]<&digit-

moves file descriptor digit to file descriptor n, or standard input (file descriptor 0) if n is not specified. digit is closed after being duplicated to n.

Similarly, the redirection operator

 [n]>&digit-

moves file descriptor digit to file descriptor n, or standard output (file descriptor 1) if n is not specified.
