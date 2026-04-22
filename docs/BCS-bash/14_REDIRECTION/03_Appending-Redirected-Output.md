<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Appending Redirected Output

Redirection of output in this fashion causes the file whose name results from the expansion of word to be opened for appending on file descriptor n, or standard output (file descriptor 1) if n is not specified. If the file does not exist it is created.

The general format for appending output is:

 [n]>>word
